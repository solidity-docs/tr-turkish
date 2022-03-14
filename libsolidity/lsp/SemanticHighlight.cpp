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
#include <libsolidity/lsp/SemanticHighlight.h>

using namespace std;
using namespace solidity;
using namespace solidity::lsp;
using namespace solidity::frontend;

namespace
{

vector<Declaration const*> allAnnotatedDeclarations(Identifier const* _identifier)
{
	vector<Declaration const*> output;
	output.push_back(_identifier->annotation().referencedDeclaration);
	output += _identifier->annotation().candidateDeclarations;
	return output;
}

}

void SemanticHighlight::operator()(MessageID _id, Json::Value const& _args)
{
	auto const [sourceUnitName, lineColumn] = extractSourceUnitNameAndLineColumn(_args);
	ASTNode const* sourceNode = m_server.astNodeAtSourceLocation(sourceUnitName, lineColumn);

	Json::Value jsonReply = Json::arrayValue;
	for (auto const& [location, kind]: semanticHighlight(sourceNode, sourceUnitName))
	{
		Json::Value item = Json::objectValue;
		item["range"] = toRange(location);
		if (kind != DocumentHighlightKind::Unspecified)
			item["kind"] = int(kind);
		jsonReply.append(item);
	}
	client().reply(_id, jsonReply);
}

vector<Reference> SemanticHighlight::semanticHighlight(ASTNode const* _sourceNode, string const& _sourceUnitName)
{
	if (!_sourceNode)
		return {};

	SourceUnit const& sourceUnit = m_server.ast(_sourceUnitName);

	vector<Reference> output;
	if (auto const* declaration = dynamic_cast<Declaration const*>(_sourceNode))
	{
		output += ReferenceCollector::collect(declaration, sourceUnit, declaration->name());
	}
	else if (auto const* identifier = dynamic_cast<Identifier const*>(_sourceNode))
	{
		for (auto const* declaration: allAnnotatedDeclarations(identifier))
			output += ReferenceCollector::collect(declaration, sourceUnit, identifier->name());
	}
	else if (auto const* identifierPath = dynamic_cast<IdentifierPath const*>(_sourceNode))
	{
		solAssert(!identifierPath->path().empty(), "");
		output += ReferenceCollector::collect(identifierPath->annotation().referencedDeclaration, sourceUnit, identifierPath->path().back());
	}
	else if (auto const* memberAccess = dynamic_cast<MemberAccess const*>(_sourceNode))
	{
		Type const* type = memberAccess->expression().annotation().type;
		if (auto const* ttype = dynamic_cast<TypeType const*>(type))
		{
			auto const memberName = memberAccess->memberName();

			if (auto const* enumType = dynamic_cast<EnumType const*>(ttype->actualType()))
			{
				// find the definition
				for (ASTPointer<EnumValue> const& enumMember: enumType->enumDefinition().members())
					if (enumMember->name() == memberName)
						output += ReferenceCollector::collect(enumMember.get(), sourceUnit, enumMember->name());

				// TODO: find uses of the enum value
			}
		}
		else if (auto const* structType = dynamic_cast<StructType const*>(type))
		{
			(void) structType; // TODO
			// TODO: highlight all struct member occurrences.
			// memberAccess->memberName()
			// structType->
		}
		else
		{
			// TODO: EnumType, ...
			//log("semanticHighlight: member type is: "s + (type ? typeid(*type).name() : "NULL"));
		}
	}
	return output;
}

