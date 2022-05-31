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
#include "libsolutil/AnsiColorized.h"
#include <libsolidity/lsp/ReferenceCollector.h>
#include <libsolidity/lsp/Utils.h>

#include <libsolidity/ast/AST.h>
#include <libsolidity/lsp/LanguageServer.h>

#include <fmt/format.h>

using namespace solidity::frontend;
using namespace solidity::langutil;
using namespace std::string_literals;
using namespace std;

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

}

ReferenceCollector::ReferenceCollector(
	Declaration const& _declaration,
	std::string const& _sourceIdentifierName
):
	m_declaration{_declaration},
	m_sourceIdentifierName{_sourceIdentifierName.empty() ? _declaration.name() : _sourceIdentifierName}
{
}

std::vector<Reference> ReferenceCollector::collect(
	Declaration const* _declaration,
	ASTNode const& _ast,
	std::string const& _sourceIdentifierName
)
{
	if (!_declaration)
		return {};

    ReferenceCollector collector(*_declaration, _sourceIdentifierName);
    _ast.accept(collector);
    return move(collector.m_result);
}

std::vector<Reference> ReferenceCollector::collect(
	ASTNode const* _sourceNode,
	SourceUnit const& _sourceUnit
)
{
	if (!_sourceNode)
		return {};

	auto output = vector<Reference>{};

	if (auto const* identifier = dynamic_cast<Identifier const*>(_sourceNode))
	{
		lspDebug(fmt::format("semanticHighlight: Identifier: {}", identifier->name()));
		for (auto const* declaration: allAnnotatedDeclarations(identifier))
		{
			lspDebug(fmt::format("semanticHighlight: Identifier: adding annotated decl: {} ({})", declaration->name(), typeid(*declaration).name()));
			//output += collect(declaration, _sourceUnit, declaration->name());
			output += collect(declaration, _sourceUnit, identifier->name());
		}
	}
	else if (auto const* identifierPath = dynamic_cast<IdentifierPath const*>(_sourceNode))
	{
		lspDebug(fmt::format("semanticHighlight: IdentifierPath: back: {}", identifierPath->path().back()));
		solAssert(identifierPath->path().size() >= 1, "");
		output += collect(identifierPath->annotation().referencedDeclaration, _sourceUnit, identifierPath->path().back());
	}
	else if (auto const* memberAccess = dynamic_cast<MemberAccess const*>(_sourceNode))
	{
		Type const* type = memberAccess->expression().annotation().type;
		lspDebug(fmt::format("semanticHighlight: member type is: "s + (type ? typeid(*type).name() : "NULL")));
		output += collect(memberAccess->annotation().referencedDeclaration, _sourceUnit, memberAccess->memberName());
	}
	else if (auto const* declaration = dynamic_cast<Declaration const*>(_sourceNode))
	{
		lspDebug(fmt::format("semanticHighlight: Declaration: {}", typeid(*_sourceNode).name()));
		output += collect(declaration, _sourceUnit, declaration->name());
	}
	else
	{
		lspDebug(fmt::format("semanticHighlight: not handled: {}", typeid(*_sourceNode).name()));
	}

	return output;
}

bool ReferenceCollector::visit(ImportDirective const& _import)
{
	if (_import.name() == m_sourceIdentifierName)
		return true;
	return false;
}

void ReferenceCollector::endVisit(ImportDirective const& _import)
{
	for (auto const& symbolAlias: _import.symbolAliases())
		if (
			m_sourceIdentifierName == *symbolAlias.alias &&
			symbolAlias.symbol &&
			symbolAlias.symbol->annotation().referencedDeclaration == &m_declaration
		)
		{
			lspDebug(fmt::format("Found symbol alias: {}", m_sourceIdentifierName));
			m_result.emplace_back(Reference{symbolAlias.location, DocumentHighlightKind::Read});
			break;
		}
		else if (m_sourceIdentifierName == *symbolAlias.alias)
		{
			lspDebug(fmt::format("Found symbol alias by text compare: {}", m_sourceIdentifierName));
			m_result.emplace_back(Reference{symbolAlias.location, DocumentHighlightKind::Text});
		}
		else
		{
			lspDebug(fmt::format("SKIPPING symbol alias by text compare: {} != {}", *symbolAlias.alias, m_sourceIdentifierName));
		}
}

bool ReferenceCollector::tryAddReference(Declaration const* _declaration, SourceLocation const& _location)
{
	if (&m_declaration != _declaration)
		return false;

	m_result.emplace_back(Reference{_location, m_kind});
	return true;
}

void ReferenceCollector::endVisit(Identifier const& _identifier)
{
	if (auto const* declaration = _identifier.annotation().referencedDeclaration)
		tryAddReference(declaration, _identifier.location());

	for (auto const* declaration: _identifier.annotation().candidateDeclarations + _identifier.annotation().overloadedDeclarations)
		tryAddReference(declaration, _identifier.location());
}


void ReferenceCollector::endVisit(IdentifierPath const& _identifierPath)
{
	tryAddReference(_identifierPath.annotation().referencedDeclaration, _identifierPath.location());
}

void ReferenceCollector::endVisit(MemberAccess const& _memberAccess)
{
	if (_memberAccess.annotation().referencedDeclaration == &m_declaration)
		m_result.emplace_back(Reference{_memberAccess.location(), m_kind});
}

bool ReferenceCollector::visit(Assignment const& _node)
{
	auto const oldKind = m_kind;
	m_kind = DocumentHighlightKind::Write;
	_node.leftHandSide().accept(*this);
	m_kind = DocumentHighlightKind::Read;
	_node.rightHandSide().accept(*this);
	m_kind = oldKind;
	return false;
}

bool ReferenceCollector::visit(VariableDeclaration const& _node)
{
	if (&_node == &m_declaration)
	{
		m_result.emplace_back(Reference{_node.nameLocation(), DocumentHighlightKind::Write});
	}
	return true;
}

bool ReferenceCollector::visitNode(ASTNode const& _node)
{
	if (&_node == &m_declaration)
	{
		if (auto const* declaration = dynamic_cast<Declaration const*>(&_node))
			m_result.emplace_back(Reference{declaration->nameLocation(), m_kind});
		else
			m_result.emplace_back(Reference{_node.location(), DocumentHighlightKind::Read});
	}

	return true;
}

}
