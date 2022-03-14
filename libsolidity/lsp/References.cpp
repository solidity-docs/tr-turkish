/*
	This file is part of solidity.

	solidity is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	solidity is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with solidity.  If not, see <http://www.gnu.org/licenses/>.
*/
// SPDX-License-Identifier: GPL-3.0
#include <libsolidity/lsp/References.h>
#include <libsolidity/lsp/ReferenceCollector.h>
#include <libsolidity/lsp/LanguageServer.h>
#include <libsolidity/lsp/Utils.h>

#include <libsolutil/CommonData.h>

#include <vector>

using namespace std;
using namespace solidity::langutil;
using namespace solidity::frontend;

namespace solidity::lsp
{

namespace
{

vector<Declaration const*> allAnnotatedDeclarations(Identifier const* _identifier)
{
	vector<Declaration const*> output;
	output.push_back(_identifier->annotation().referencedDeclaration);
	output += _identifier->annotation().candidateDeclarations;
	return output;
}

vector<SourceLocation> findAllReferences(
	Declaration const* _declaration,
	string const& _sourceIdentifierName,
	SourceUnit const& _sourceUnit
)
{
	vector<SourceLocation> output;
	for (auto& reference: ReferenceCollector::collect(_declaration, _sourceUnit, _sourceIdentifierName))
		output.emplace_back(move(get<SourceLocation>(reference)));
	return output;
}

}

void References::operator()(MessageID _id, Json::Value const& _args)
{
	auto const [sourceUnitName, lineColumn] = extractSourceUnitNameAndLineColumn(_args);

	ASTNode const* sourceNode = m_server.astNodeAtSourceLocation(sourceUnitName, lineColumn);
	if (!sourceNode)
	{
		Json::Value emptyResponse = Json::arrayValue;
		client().reply(_id, emptyResponse); // reply with "No references".
		return;
	}
	SourceUnit const& sourceUnit = m_server.ast(sourceUnitName);

	auto output = vector<SourceLocation>{};
	if (auto const* identifier = dynamic_cast<Identifier const*>(sourceNode))
	{
		for (auto const* declaration: allAnnotatedDeclarations(identifier))
			output += findAllReferences(declaration, declaration->name(), sourceUnit);
	}
	else if (auto const* identifierPath = dynamic_cast<IdentifierPath const*>(sourceNode))
	{
		if (auto decl = identifierPath->annotation().referencedDeclaration)
			output += findAllReferences(decl, decl->name(), sourceUnit);
	}
	else if (auto const* memberAccess = dynamic_cast<MemberAccess const*>(sourceNode))
	{
		output += findAllReferences(memberAccess->annotation().referencedDeclaration, memberAccess->memberName(), sourceUnit);
	}
	else if (auto const* declaration = dynamic_cast<Declaration const*>(sourceNode))
	{
		output += findAllReferences(declaration, declaration->name(), sourceUnit);
	}

	Json::Value jsonReply = Json::arrayValue;
	for (SourceLocation const& location: output)
		jsonReply.append(toJson(location));
	client().reply(_id, jsonReply);
}

}
