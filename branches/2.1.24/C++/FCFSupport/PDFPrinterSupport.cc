/* 
 * ------------------------------------------------------------------
 * PDFPrinterSupport.cc - PDF Support structures
 * Created by Robert Heller on Sun Nov 13 18:35:30 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.7  2007/02/01 20:00:51  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.6  2005/11/21 07:32:06  heller
 * Modification History: Fix Ambigious compare
 * Modification History:
 * Modification History: Revision 1.4  2005/11/21 03:01:35  heller
 * Modification History: Lockdown
 * Modification History:
 * Modification History: Revision 1.3  2005/11/20 10:16:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/20 09:46:33  heller
 * Modification History: Nov. 20, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/14 23:14:22  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2002/07/28 14:03:50  heller
 * Modification History: Add it copyright notice headers
 * Modification History:
 * ------------------------------------------------------------------
 * Contents:
 * ------------------------------------------------------------------
 *  
 *     Model RR System, Version 2
 *     Copyright (C) 1994,1995,2002-2005  Robert Heller D/B/A Deepwoods Software
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

static char Id[] = "$Id$";

#include <stdio.h>
#include <iostream>
#include <PDFPrinterSupport.h>

namespace FCFSupport {

using namespace PDFFileStructures;

unsigned long int CrossReferenceTable::lastObjectNumber = 0L;

CrossReferenceTable::CrossReferenceTable()
{
	objectTable[0] = new FreedObject(0,65535,this);
}

void CrossReferenceTable::AddIndirectObjectToTable(IndirectObject *obj)
{
	lastObjectNumber++;
#ifdef DEBUG
	cerr << "*** CrossReferenceTable::AddIndirectObjectToTable: lastObjectNumber = " << lastObjectNumber << endl;
#endif
	objectTable[lastObjectNumber] = obj;
#ifdef DEBUG
	cerr << "*** CrossReferenceTable::AddIndirectObjectToTable: obj->ObjectNumber() = " << obj->ObjectNumber() << endl;
#endif
	obj->SetObjectNumber(lastObjectNumber,this);
}

void CrossReferenceTable::FreeObject(unsigned long int objNum)
{
	objectMap::iterator ox = objectTable.find(objNum);
	if (ox == objectTable.end()) return;
	(ox->second) = new FreedObject(0,65535,this);
}

struct range {
	unsigned long int first;
	unsigned long int last;
}; 

streampos CrossReferenceTable::WriteTable(ostream &stream) const
{
	objectMap::const_iterator index;
	vector<range> ranges;
	vector<range>::const_iterator irange;
	range temp;
	unsigned long int count;
	unsigned long int digitmult;
	unsigned long int value;
	unsigned long int blockindex;
	streampos fileOffset = stream.tellp();

	temp.first = 0;
	temp.last  = 0;
	
	for (index = objectTable.begin();
	     index != objectTable.end();
	     index++)
	{
		if ((index->first) > temp.last+1) {
			ranges.push_back(temp);
			temp.last = temp.first = index->first;
		} else {
			temp.last = index->first;
		}
	}
	ranges.push_back(temp);
	stream << "xref" << endl;
	for (irange = ranges.begin(); irange < ranges.end(); irange++) {
		count = (*irange).last - (*irange).first + 1;
		stream << (*irange).first << " " << count << endl;
		for (blockindex = (*irange).first; blockindex <= (*irange).last; blockindex++)
		{
			bool isNormalP;
			index = objectTable.find(blockindex);
			assert(index != objectTable.end());
			const IndirectObject *obj = index->second;
			value = (unsigned long int) obj->FileOffset();
			if (value == 0) {
				value = obj->ObjectNumber();
				isNormalP = false;
			} else isNormalP = true;
			for (digitmult = 1000000000; digitmult > 0; digitmult /= 10)
			{
				stream << ((value / digitmult) % 10);
			}
			stream << " ";
			value = obj->GenerationNumber();
			for (digitmult = 10000; digitmult > 0; digitmult /= 10)
			{
				stream << ((value / digitmult) % 10);
			}
			if (isNormalP) stream << " n";
			else stream << " f";
#ifndef __WIN32__
			stream << " ";
#endif
			stream << endl;			
		}
	}
	return fileOffset;
}
	
	


ostream & operator<< (ostream & stream,const PDFNameArray &pnarray) {
	stream << "[ ";
	for (vector<string>::const_iterator i = pnarray.begin();
	     i != pnarray.end(); i++) {stream << "/" << *i << " ";}
	stream << "]";
	return stream;
}

ostream& ResourceDictionary::WriteDictionaryElements(ostream &stream) const
{
	if (extGState.Size() > 0) {
		stream << "/ExtGState ";
		if (!extGState.HasOffset()) {
			extGState.WriteDirect(stream);
		} else {
			extGState.WriteIndirectReference(stream);
		}
	}
	if (colorSpace.Size() > 0) {
		stream << "/ColorSpace ";
		if (!colorSpace.HasOffset()) {
			colorSpace.WriteDirect(stream);
		} else {
			colorSpace.WriteIndirectReference(stream);
		}
	}
	if (pattern.Size() > 0) {
		stream << "/Pattern ";
		if (!pattern.HasOffset()) {
			pattern.WriteDirect(stream);
		} else {
			pattern.WriteIndirectReference(stream);
		}
	}
	if (shading.Size() > 0) {
		stream << "/Shading ";
		if (!shading.HasOffset()) {
			shading.WriteDirect(stream);
		} else {
			shading.WriteIndirectReference(stream);
		}
	}
	if (xObject.Size() > 0) {
		stream << "/XObject ";
		if (!xObject.HasOffset()) {
			xObject.WriteDirect(stream);
		} else {
			xObject.WriteIndirectReference(stream);
		}
	}
	if (font.Size() > 0) {
		stream << "/Font ";
		if (!font.HasOffset()) {
			font.WriteDirect(stream);
		} else {
			font.WriteIndirectReference(stream);
		}
	}
	if (properties.Size() > 0) {
		stream << "/Properties ";
		if (!properties.HasOffset()) {
			properties.WriteDirect(stream);
		} else {
			properties.WriteIndirectReference(stream);
		}
	}
	if (procSets.size() > 0) {
		stream << "/ProcSet " << procSets << endl;
	}
	return stream;
}

ostream & PDFStream::WriteDirect(ostream &stream) const
{
	const std::string bytes = this->str();
	int length = bytes.size();
	stream << "<< /Length " << length << " >>" << endl;
	stream << "stream\r\n";
	int ibyte;
	for (ibyte = 0; ibyte < length; ibyte++) stream << bytes[ibyte];
	stream << endl << "endstream" << endl;
	return stream;
}

ostream & Page::WriteDictionaryElements(ostream &stream) const
{
	WriteDictionaryType(stream);
	if (parent != NULL) {
		stream << "/Parent ";
		parent->WriteIndirectReference(stream) << endl;
	}
	if (contents.size() > 0) {
		stream << "/Contents ";
		if (contents.size() == 1) {
			contents[0]->WriteIndirectReference(stream) << endl;
		} else {
			stream << " [ ";
			PDFStreamVector::const_iterator streamIndex;
			for (streamIndex = contents.begin(); streamIndex != contents.end(); streamIndex++) {
				(*streamIndex)->WriteIndirectReference(stream) << endl;
			}
			stream << " ]" << endl;
		}
	}
	if (resources != NULL) {
		stream << "/Resources ";
		if (!resources->HasOffset()) {
			resources->WriteDirect(stream) << endl;
		} else {
			resources->WriteIndirectReference(stream) << endl;
		}
	}
	if (mediaBox != NULL) {
		stream << "/MediaBox ";
		if (!mediaBox->HasOffset()) {
			mediaBox->WriteDirect(stream) << endl;
		} else {
			mediaBox->WriteIndirectReference(stream) << endl;
		}
	}
	if (cropBox != NULL) {
		stream << "/CropBox ";
		if (!cropBox->HasOffset()) {
			cropBox->WriteDirect(stream) << endl;
		} else {
			cropBox->WriteIndirectReference(stream) << endl;
		}
	}
	return stream;
}

ostream & PageTree::WriteDictionaryElements(ostream &stream) const
{
	WriteDictionaryType(stream);
	if (parent != NULL) {
		stream << "/Parent ";
		parent->WriteIndirectReference(stream) << endl;
	}
	vector<TypedDictionary *>::const_iterator kid;
	stream << "/Kids [ ";
	for (kid = pagenodes.begin(); kid != pagenodes.end(); kid++) {
		(*kid)->WriteIndirectReference(stream) << endl;
	}
	stream << "]" << endl;
	stream << "/Count " << pagenodes.size() << endl;
	if (resources != NULL) {
		stream << "/Resources ";
		if (!resources->HasOffset()) {
			resources->WriteDirect(stream) << endl;
		} else {
			resources->WriteIndirectReference(stream) << endl;
		}
	}
	if (mediaBox != NULL) {
		stream << "/MediaBox ";
		if (!mediaBox->HasOffset()) {
			mediaBox->WriteDirect(stream) << endl;
		} else {
			mediaBox->WriteIndirectReference(stream) << endl;
		}
	}
	if (cropBox != NULL) {
		stream << "/CropBox ";
		if (!cropBox->HasOffset()) {
			cropBox->WriteDirect(stream) << endl;
		} else {
			cropBox->WriteIndirectReference(stream) << endl;
		}
	}
	return stream;
}

ostream & PageLabelDictionary::WriteDictionaryElements(ostream &stream) const
{
	WriteDictionaryType(stream);
	if (style != None) {
		stream << "/S /" << ((char)style) << " ";
	}
	if (prefix != "") {
		stream << "/P (" << QuotePDFString(prefix) << ") ";
	}
	if (start != 1) {
		stream << "/St " << start << " ";
	}
	return stream;
}

void PageLabelTree::GetKidLimits(int& lower, int& upper) const
{
	int temp_lower, temp_upper;
	if (kids.size() == 0) {
		lower = nums.begin()->first;
		upper = lower;
		PageLabelDictionaryNumMap::const_iterator element;
		for (element = nums.begin(); element != nums.end(); element++) {
			upper = element->first;
		}
	} else {
		PageLabelTreeKidVector::const_iterator kid;
		for (kid = kids.begin(); kid != kids.end(); kid++) {
			(*kid)->GetKidLimits(temp_lower,temp_upper);
			if (kid == kids.begin()) {
				lower = temp_lower;
				upper = temp_upper;
			} else {
				if (temp_lower < lower) lower = temp_lower;
				if (temp_upper > upper) upper = temp_upper;
			}
		}
	}
}

ostream & PageLabelTree::WriteDictionaryElements(ostream &stream) const	
{
	if (!isRoot) {
		int lower, upper;
		GetKidLimits(lower,upper);
		stream << "/Limits [" << lower << " " << upper << "]" << endl;
	}
	if (kids.size() > 0) {
		stream << "/Kids [";
		PageLabelTreeKidVector::const_iterator kid;
		for (kid = kids.begin(); kid != kids.end(); kid++) {
			if (!(*kid)->HasOffset()) {
				(*kid)->WriteDirect(stream) << endl;
			} else {
				(*kid)->WriteIndirectReference(stream) << endl;
			}
		}
		stream << "]" << endl;
	} else {
		PageLabelDictionaryNumMap::const_iterator element;
		stream << "/Nums [";
		for (element = nums.begin(); element != nums.end(); element++) {
			stream << element->first << " ";
			if (!(element->second)->HasOffset()) {
				(element->second)->WriteDirect(stream) << endl;
			} else {
				(element->second)->WriteIndirectReference(stream) << endl;
			}
		}
		stream << "]" << endl;
	}			
	return stream;
}

ostream & CatalogDictionary::WriteDictionaryElements(ostream &stream) const
{
	WriteDictionaryType(stream);
	assert(pages != NULL);
	assert(pages->HasOffset());
	stream << "/Pages ";
	pages->WriteIndirectReference(stream) << endl;
	if (labels != NULL && labels->Size() > 0) {
		stream << "/PageLabels ";
		if (!labels->HasOffset()) {
			labels->WriteDirect(stream);
		} else {
			labels->WriteIndirectReference(stream);
		}
	}
	return stream;
}

ostream & InformationDirectory::WriteDictionaryElements(ostream &stream) const
{
	struct tm brokendown;
	char buffer[22];

	if (title != "") {
		stream << "/Title (" << QuotePDFString(title) << ")" << endl;
	}
	if (author != "") {
		stream << "/Author (" << QuotePDFString(author) << ")" << endl;
	}
	if (subject != "") {
		stream << "/Subject (" << QuotePDFString(subject) << ")" << endl;
	}
	if (keywords != "") {
		stream << "/Keywords (" << QuotePDFString(keywords) << ")" << endl;
	}
	if (creater != "") {
		stream << "/Creater (" << QuotePDFString(creater) << ")" << endl;
	}
	if (producer != "") {
		stream << "/Producer (" << QuotePDFString(producer) << ")" << endl;
	}
	if (creationDate > 0) {
		localtime_r(&creationDate,&brokendown);
		sprintf(buffer,"D:%04d%02d%02d%02d%02d%02d",
			brokendown.tm_year,brokendown.tm_mon+1,
			brokendown.tm_mday,brokendown.tm_hour,
			brokendown.tm_min,brokendown.tm_sec);
		stream << "/CreationDate (" << buffer << ")" << endl;
	}
	if (modificationDate > 0) {
		localtime_r(&modificationDate,&brokendown);
		sprintf(buffer,"D:%04d%02d%02d%02d%02d%02d",
			brokendown.tm_year,brokendown.tm_mon+1,
			brokendown.tm_mday,brokendown.tm_hour,
			brokendown.tm_min,brokendown.tm_sec);
		stream << "/ModDate (" << buffer << ")" << endl;
	}
	return stream;
}

ostream & Type1FontDictionary::WriteDictionaryElements(ostream &stream) const
{
	WriteDictionaryType(stream);
	WriteFontType(stream);
	stream << "/BaseFont /" << baseFont << endl;
	if (widths != NULL) {
		stream << "/FirstChar " << firstChar << endl;
		stream << "/LastChar " << lastChar << endl;
		stream << "/Width ";
		if (!widths->HasOffset()) {
			widths->WriteDirect(stream) << endl;
		} else {
			widths->WriteIndirectReference(stream) << endl;
		}
	}
	if (fontDescriptor != NULL) {
		stream << "/FontDescriptor ";
		assert(fontDescriptor->HasOffset());
		fontDescriptor->WriteIndirectReference(stream) << endl;
	}
	if (encodingDictionary != NULL) {
		stream << "/Encoding ";
		if (!encodingDictionary->HasOffset()) {
			encodingDictionary->WriteDirect(stream) << endl;
		} else {
			encodingDictionary->WriteIndirectReference(stream) << endl;
		}
	} else if (encodingName != "") {
		stream << "/Encoding /" << encodingName << endl;
	}		
	return stream;
}

string PDFFileStructures::QuotePDFString(const string& str)
{
	string result = "";
	string::const_iterator i;
	for (i = str.begin(); i != str.end(); i++) {
		unsigned int ch = (((unsigned char) *i) & 0x00FF);
#ifdef DEBUG
		cerr << "*** QuotePDFString: ch = " << ch << endl;
#endif
		if (ch == '\n') {
			result += "\\n";
		} else if (ch == '\r') {
			result += "\\r";
		} else if (ch == '\t') {
			result += "\\t";
		} else if (ch == '\b') {
			result += "\\b";
		} else if (ch == '\f') {
			result == "\\f";
		} else if (ch < ' ' || ch >= 127) {
			result += "\\";
			result += (char)(((ch >> 6) % 8) + '0');
			result += (char)(((ch >> 3) % 8) + '0');
			result += (char)(( ch       % 8) + '0');
		} else if (ch == '(') {
			result += "\\(";
		} else if (ch == ')') {
			result += "\\)";
		} else if (ch == '\\') {
			result += "\\\\";
		} else {
			result += ch;
		}
#ifdef DEBUG
		cerr << "*** QuotePDFString: result = '" << result << "'" << endl;
#endif
	}
	return result;
}

}
