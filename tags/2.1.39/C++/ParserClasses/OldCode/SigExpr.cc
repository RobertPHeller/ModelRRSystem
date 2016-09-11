/* 
 * ------------------------------------------------------------------
 * SigExpr.cc - Signal Expression
 * Created by Robert Heller on Sun Aug  6 17:16:20 1995
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.1  2007/02/01 20:00:52  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.1.1.1  2002/07/14 18:09:37  heller
 * Modification History: Imported Sources
 * Modification History:
 * Modification History: Revision 2.6  2000/11/10 00:24:34  heller
 * Modification History: *** empty log message ***
 * Modification History:
 * Modification History: Revision 2.5  1995/09/04 02:04:27  heller
 * Modification History: Minor typo.
 * Modification History:
// Revision 2.4  1995/09/04  01:56:36  heller
// Fix output functions to match parser.
//
// Revision 2.3  1995/09/04  00:16:24  heller
// Update parsing to use tree table
//
// Revision 2.2  1995/08/09  00:12:56  heller
// Minor fixes.
//
// Revision 2.1  1995/08/08  16:42:08  heller
// *** empty log message ***
//
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995  Robert Heller D/B/A Deepwoods Software
 * 			51 Locke Hill Road
 * 			Wendell, MA 01379-9728
 * 
 *     This program is free software; you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation; either version 2 of the License, or
 *     (at your option) any later version.
 * 
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 * 
 *     You should have received a copy of the GNU General Public License
 *     along with this program; if not, write to the Free Software
 *     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 *  
 */

static char rcsid[] = "$Id$";

#include <MRRSigExpr.tab.h>
#include <Turnout.h>
#include <Block.h>
#include <Table.h>
#include <Tree.h>

bool TurnExpr::eval()
{
	if (turnout == NULL) return (false);
	int state = turnout->EvalScript(turnout->ReadStateScript(),"");
	if (state == turnstate) return(true);
	else return (false);
}

void TurnExpr::print (ostream& stream)
{
	stream << "(turnout ";
	if (turnout != NULL)
	{
		const char * name = turnout->Name();
		TurnoutTable *tt = turnout->MyTable();
		if (tt == NULL) stream << name;
		else
		{
			Tree *tr = tt->MyTree();
			if (tr == NULL) stream << name;
			else
			{
				const char * trname = tr->Name();
				stream << trname << "::" << name;
			}
		}
		stream << " ";
	}
	switch (turnstate)
	{
		case Turnout::MAIN: stream << "main"; break;
		case Turnout::DIVERGENCE1: stream << "divergence 1"; break;
		case Turnout::DIVERGENCE2: stream << "divergence 2"; break;
	}
	stream << ")";
}

bool BlockExpr::eval()
{
        if (block == NULL) return (false);
        int occupied = block->EvalScript(block->OccupiedScript(),"");
        if (occupied) return(true);
        else return (false);
}

void BlockExpr::print (ostream& stream)
{
	stream << "(block ";
	if (block != NULL)
	{
		const char * name = block->Name();
		BlockTable *tt = block->MyTable();
		if (tt == NULL) stream << name;
		else
		{
			Tree *tr = tt->MyTree();
			if (tr == NULL) stream << name;
			else
			{
				const char * trname = tr->Name();
				stream << trname << "::" << name;
			}
		}
	}
	stream << ")";
}

bool TableExpr::eval()
{
	if (table == NULL) return (false);
	int state = table->EvalScript(table->ReadStateScript(),"");
	if (state == pointnumber) return(true);
	else return (false);
}

void TableExpr::print (ostream& stream)
{
	stream << "(table ";
	if (table != NULL)
	{
		const char * name = table->Name();
		TableTable *tt = table->MyTable();
		if (tt == NULL) stream << name;
		else
		{
			Tree *tr = tt->MyTree();
			if (tr == NULL) stream << name;
			else
			{
				const char * trname = tr->Name();
				stream << trname << "::" << name;
			}
		}
		stream << " ";
	}
	stream << "point " << pointnumber << ")";
}

ostream& operator << (ostream& stream,Expr& ex)
{
	ex.print(stream);
	return(stream);
}

ostream& operator << (ostream& stream,NotExpr& ex)
{
	ex.print(stream);
	return(stream);
}

ostream& operator << (ostream& stream,OrExpr& ex)
{
	ex.print(stream);
	return(stream);
}

ostream& operator << (ostream& stream,AndExpr& ex)
{
	ex.print(stream);
	return(stream);
}

ostream& operator << (ostream& stream,TurnExpr& ex)
{
	ex.print(stream);
	return(stream);
}

ostream& operator << (ostream& stream,BlockExpr& ex)
{
	ex.print(stream);
	return(stream);
}

ostream& operator << (ostream& stream,TableExpr& ex)
{
	ex.print(stream);
	return(stream);
}

SigExpr::~SigExpr() {}

int SigExpr::Parse()
{
	return parser->yyparse();
}

void SigExpr::ParseError(char *m)
{
	parser->yyerror(m);
}

