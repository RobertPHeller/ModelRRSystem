/* 
 * ------------------------------------------------------------------
 * PDFPrinterSupport.h - PDF Support code
 * Created by Robert Heller on Sun Nov 13 12:26:05 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.8  2007/04/19 17:23:20  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.7  2007/02/01 20:00:51  heller
 * Modification History: Lock down for Release 2.1.7
 * Modification History:
 * Modification History: Revision 1.6  2006/01/03 15:30:21  heller
 * Modification History: Lockdown
 * Modification History:
 * Modification History: Revision 1.5  2005/11/21 07:27:52  heller
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

#ifndef _PDFPRINTERSUPPORT_H_
#define _PDFPRINTERSUPPORT_H_

#include <assert.h>
#include <time.h>
#include <PDFPrinterSupport.h>
#if !HAVE_LOCALTIME_R
extern "C" struct tm *localtime_r(const time_t *, struct tm *);
#endif
#if !HAVE_ASCTIME_R
extern "C" char *asctime_r(const struct tm *, char *);
#endif

#include <Common.h>
#include <iostream>
#include <sstream>
#include <map>
#include <vector>

/** @memo PDF File support structures.
  * @doc These classes and structures are designed to implement some of the
  * functionallity described in Adobe's PDF Reference Fifth Edition version 1.6.
  */
namespace PDFFileStructures {
	/** @memo The cross reference table object.
          * @doc The stricture holds the cross-reference table, which
	  * is used to index and access indirect objects of various sorts.
	 */
	class CrossReferenceTable {
	public:
		friend class IndirectObject;
		/** @memo Constructor.
  	          * @doc Initialize a cross reference table object.
  	          */
		CrossReferenceTable();
		/** @memo Destructor.
		  * @doc Cleans things up.
		  */
		~CrossReferenceTable() {}
		/** Add an indirect object to the cross reference table.
		  * @param obj The object to add.
		  */
		void AddIndirectObjectToTable(IndirectObject *obj);
		/** Write this cross reference table out. Returns the file
		  * position.
		  * @param stream The stream to write to.
		  */
		streampos WriteTable(ostream &stream) const;
		/** Return the highest object number.
		  */
		unsigned long int HighestObjectNumber() const
		{
			return lastObjectNumber;
		}
private:
		/** Free up a object slot in the cross reference table.
		  * @param objNum The object number to free up.
		  */
		void FreeObject(unsigned long int objNum);
		/** The last used object number.
		  */
		static unsigned long int lastObjectNumber;
		/** The object table type.
		  */
		typedef map<unsigned long int, IndirectObject*, less<unsigned long int> >
			objectMap;
		/** The table of objects.
		  */
		objectMap objectTable;
	};
	/** Indirect object base class.  All PDF objects that might be
	  *  referenced as indirect objects are derived from this class.
	  */
	class IndirectObject {
	public:
		/** @memo Constructor.
		  * @doc Perform base initialization.
		  * @param objNum The object number.  Zero means no object number yet.
		  * @param genNum The generation number. Zero means first generation.
		  * @param tab The cross reference table we are in.
		  */
		IndirectObject(unsigned long int objNum = 0L,
			       unsigned short int genNum = 0,
			       CrossReferenceTable *tab = NULL)
		{
			objectNumber = objNum;
			generationNumber = genNum;
			table = tab;
			fileOffset = 0;
		}
		/** @memo Destructor.
	          * @doc Clean everything up.
	          */
		~IndirectObject() {
			if (table != NULL && objectNumber != 0)
				table->FreeObject(objectNumber);
		}
		/** Write an object indirectly.  The first time this is called,
		  *  an obj ... endobj block is written.  Later times an indirect
		  *  reference is written.
		  * @param stream The output stream to write to.
		  */
		ostream& WriteObjectToFile (ostream& stream)
		{
			assert(objectNumber != 0);
			if (!HasOffset()) {
				fileOffset = stream.tellp();
				stream << objectNumber << " " << generationNumber
				       << " obj" << endl;
				WriteDirect(stream);
				stream << endl << "endobj" << endl;
			} else {
				stream << objectNumber << " " << generationNumber
				       << " R";
			}
			return stream;
		}
		/** Write an object indirectly.  Assumes that the non-const
		  * version has already been called.  This version only writes 
		  * an indirect reference.
		  * @param stream The output stream to write to.
		  */
		ostream& WriteIndirectReference (ostream& stream) const
		{
			assert(objectNumber != 0);
			//assert(fileOffset != 0);
			stream << objectNumber << " " << generationNumber
				       << " R";
			return stream;
		}
		/** Write an object directly. Needs to be overloaded by derived
		  * classes.
		  * @param stream The output stream to write to.
		  */
		virtual ostream& WriteDirect (ostream& stream) const = 0;
		friend class CrossReferenceTable;
		/** Return this object's object number.
		  */
		unsigned long int ObjectNumber() const {return objectNumber;}
		/** Return this object's generation number.
		  */
		unsigned short int GenerationNumber() const {
			return generationNumber;
		}
		/** Return this object's file offset.
		  */
		streampos FileOffset() const {return fileOffset;}
		/** Does the object have a file offset?
		  */
		bool HasOffset() const {return fileOffset != (streampos) 0;}
	private:
		/** Set this object's object number.  Should only be called when
		  * this object is inserted into a cross reference table.
		  *  The object number cannot be reset!
		  * @param on The object number to set this object to.  Can't
		  *	    be zero.  If the object number is already set, this
		  *	    can be the same number, in which case the
		  *	    generation number gets incremented.
		  * @param tab The cross reference table this object is being added
		  *	 to.
		  */
		void SetObjectNumber(unsigned long int on,
				     CrossReferenceTable *tab) {
			assert(on != 0);
			assert(tab != NULL);
			assert(objectNumber == 0 || objectNumber == on);
			assert(table == NULL);
			if (objectNumber == 0) {
				objectNumber = on;
			} else if (objectNumber == on) {
				generationNumber++;
			} else {}
			table = tab;
		}
		/** Increment the generation number.
		  */
		void IncrementGenerationNumber() {generationNumber++;}
		/** The object number.
		  */
		unsigned long int objectNumber;
		/** The generation number.
		  */
		unsigned short int generationNumber;
		/** The file position.
		  */
		streampos fileOffset;
		/** The cross referece table we are in.
		  */
		CrossReferenceTable *table;
	};
	/** @memo A deleted indirect object.
	  * @doc Just a place holder in the linked list  of freed indirect
	  * objects.
	  */
	class FreedObject : public IndirectObject {
	public:
		/** @memo Constructor.
	  	  * @doc Create a freed object.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		 FreedObject(unsigned long int objNum,
		 	     unsigned short int genNum,
		 	     CrossReferenceTable *tab
			     )
			: IndirectObject(objNum,genNum,tab) {}
		/** @memo Destructor.
		  * @doc Clean everything up.
		  */
		~FreedObject() {}
		/** Dummy function for direct writing (should never be called).
		  * @param stream The output stream to write to.
		  */		
		virtual ostream& WriteDirect (ostream& stream) const {}
	};
	/** PDF Dictionary class. This base class is useless by itself.
	  *  Real specific dictionaries will be derived from this class.
	  */
	class Dictionary : public IndirectObject {
	public:
		/** @memo Constructor.
		  * @doc Create a new dictonary.
		  * @param objNum The next object number.
		  * @param genNum The generation number.
		  * @param tab The cross reference table we are in.
		  */
		Dictionary(unsigned long int objNum = 0L,
			       unsigned short int genNum = 0,
			       CrossReferenceTable *tab = NULL)
		  : IndirectObject(objNum,genNum,tab) {}
		/** @memo Destructor.
		  * @doc Clean everything up.
		  */
		~Dictionary() {}
		/** Write an object directly.
		  * @param stream The output stream to write to.
		  */
		virtual ostream& WriteDirect (ostream& stream) const {
		  stream << "<< ";
		  WriteDictionaryElements(stream);
		  stream << " >>";
		}
	protected:
		/** Write the elements of a dictionary.
		  * @param stream The output stream to write to.
		  */
		virtual ostream& WriteDictionaryElements(ostream &stream) const {}
	};
	/** PDF Name array.  Used with resource dictionaries.
	  */
	class PDFNameArray : public vector<string> {
	public:
		/** @memo Constructor.
		  */
		PDFNameArray() {}
		/** @memo Destructor.
		  */
		~PDFNameArray() {}
	};
	/** Typed dictionary.  A dictionary with a /Type field.
	  */
	class TypedDictionary : public Dictionary {
	public:
		/** @memo Constructor.
		  * @doc Set the type member.
		  *  @param t The type of this dictionary.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		TypedDictionary(
			string t,
			unsigned long int objNum = 0L,
			unsigned short int genNum = 0,
			CrossReferenceTable *tab = NULL			
		) : Dictionary(objNum,genNum,tab) {type = t;}
		/// Destructor.
		~TypedDictionary() {}
	protected:
		/** Write the dictionary's type.
		  * @param stream The output stream to write to.
		  */
		ostream & WriteDictionaryType(
			ostream &stream
		) const {stream << " /Type /" << type << endl;return(stream);}
		/** Write this dictionary's elements.  Start with its type.
		  * @param stream The output stream to write to.
		  */
		virtual ostream & WriteDictionaryElements(
			ostream &stream
		) const {return WriteDictionaryType(stream);}
	private:
		/** The dictionary's type name.
		  */
		string type;
	};
	/** A ``vector'' of named indirect objects, implemented as a map.
	  * The elements are ndexed by name.
	  */
	typedef map<string, IndirectObject *, less<string> > NamedIndirectObjectMap;
	/** PDF Indirect Object Dictionary, used for named resources in a
	  *  Resource Dictionary.
	  */
	class IndirectObjectDictionary : public Dictionary {
	public:
		/** @memo Constructor.
		  * @doc Create a new dictonary.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		IndirectObjectDictionary(unsigned long int objNum = 0L,
			       unsigned short int genNum = 0,
			       CrossReferenceTable *tab = NULL)
		: Dictionary(objNum,genNum,tab) {}
		/** @memo Destructor.
		  * @doc Clean everything up.
		  */
		~IndirectObjectDictionary() {}
		/** Add an indirect object.
		  * @param name The name of the object.
		  * @param obj  The object itself.
		  */
		void AddIndirectObject(const string name,IndirectObject *obj)
		{
			elements[name] = obj;
		}
		/** Return the number of elements in this dictionary.
		  */
		int Size() const {return elements.size();}
	protected:
		/** Write the elements of a dictionary.
		  * @param stream The output stream to write to.
		  */
		virtual ostream& WriteDictionaryElements(ostream &stream) const
		{
			NamedIndirectObjectMap::const_iterator iox;
			for (iox = elements.begin(); iox != elements.end(); iox++)
			{
				stream << " /" << iox->first << " ";
				IndirectObject *obj = iox->second;
				if (!obj->HasOffset()) {
					obj->WriteDirect(stream);
				} else {
					obj->WriteIndirectReference(stream);
				}
				stream << endl;
			}
		}
	private:
		/** The elements in this dictionary.
		  */
		NamedIndirectObjectMap elements;
	};
	/** Resource dictionary.  Holds various named resources for indirect
	  * access.
	  */
	class ResourceDictionary : public Dictionary {
	public:
		/** @memo Constructor.
		  * @doc Create a new dictonary.
		  * @param objNum The next object number.
		  * @param genNum The generation number.
		  * @param tab The cross reference table we are in.
		  */
		ResourceDictionary(unsigned long int objNum = 0L,
			       unsigned short int genNum = 0,
			       CrossReferenceTable *tab = NULL)
		: Dictionary(objNum,genNum,tab) {}
		/** @memo Destructor.
		  */
		~ResourceDictionary() {}
		/** Add a procedure set.
		  * @param pname The name of the prodecure set to add.
		  */
		void AddProcSet (
			string pname
		) {procSets.push_back(pname);}
		/** Add an External Graphics State resource.
		  * @param name The resource name.
		  * @param obj The indirect object.
		  */
		void AddExternalGraphicsState(const string name,IndirectObject *obj)
		{
			extGState.AddIndirectObject(name,obj);
		}
		/** Add an Color Space resource.
		  * @param name The resource name.
		  * @param obj The indirect object.
		  */
		void AddColorSpace(const string name,IndirectObject *obj)
		{
			colorSpace.AddIndirectObject(name,obj);
		}
		/** Add an Pattern resource.
		  * @param name The resource name.
		  * @param obj The indirect object.
		  */
		void AddPattern(const string name,IndirectObject *obj)
		{
			pattern.AddIndirectObject(name,obj);
		}
		/** Add an Shading resource.
		  * @param name The resource name.
		  * @param obj The indirect object.
		  */
		void AddShading(const string name,IndirectObject *obj)
		{
			shading.AddIndirectObject(name,obj);
		}
		/** Add an External Object resource.
		  * @param name The resource name.
		  * @param obj The indirect object.
		  */
		void AddXObject(const string name,IndirectObject *obj)
		{
			xObject.AddIndirectObject(name,obj);
		}
		/** Add an Font resource.
		  * @param name The resource name.
		  * @param obj The indirect object.
		  */
		void AddFont(const string name,IndirectObject *obj)
		{
			font.AddIndirectObject(name,obj);
		}
		/** Add an Properties resource.
		  * @param name The resource name.
		  * @param obj The indirect object.
		  */
		void AddProperties(const string name,IndirectObject *obj)
		{
			properties.AddIndirectObject(name,obj);
		}
	protected:
		/** Write the elements of a dictionary.
		  * @param stream The output stream to write to.
		  */
		virtual ostream & WriteDictionaryElements(
			ostream &stream
		) const;
	private:
		/** A dictionary that maps resource names to graphics state
		  *  parameters dictionaries.
		  */
		IndirectObjectDictionary extGState;
		/** A dictionary that maps each resource name to either the
		  *  name of a device-dependent color space or to an array
		  *  describing a color space.
		  */
		IndirectObjectDictionary colorSpace;
		/** A Dictionary that maps resource names to pattern objects.
		  */
		IndirectObjectDictionary pattern;
		/** A Dictionary that maps resource names to shading
		  * dictionaries.
		  */
		IndirectObjectDictionary shading;
		/** A Dictionary that maps resource names to external objects.
		  */
		IndirectObjectDictionary xObject;
		/** A Dictionary that maps resource names to font
		  * dictionaries.
		  */
		IndirectObjectDictionary font;
		/** A Dictionary that maps resource names to property list
		  * dictionaries for marked content.
		  */
		IndirectObjectDictionary properties;
		/** An array of predefined preseture set names.
		  */
		PDFNameArray procSets;
	};
	/** A rectangle object.
	  */
	class Rectangle : public IndirectObject {
	public:
		/** @memo Constructor.
		  * @doc Create a fresh Rectangle object.
		  *  @param x_1 First X coordinate.
		  *  @param y_1 First Y coordinate.
		  *  @param x_2 Second X coordinate.
		  *  @param y_2 Second Y coordinate.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		Rectangle(double x_1, double y_1, double x_2, double y_2,
			  unsigned long int objNum = 0L,
			  unsigned short int genNum = 0,
			  CrossReferenceTable *tab = NULL)
		: IndirectObject(objNum,genNum,tab)
		{
			x1 = x_1; y1 = y_1; x2 = x_2; y2 = y_2;
		}
		/** @memo Destructor.
		  */
		~Rectangle() {}
		/** Return the first X coordinate.
		  */
		double X1() const {return x1;}
		/** Return the first Y coordinate.
		  */
		double Y1() const {return y1;}
		/** Return the second X coordinate.
		  */
		double X2() const {return x2;}
		/** Return the second Y coordinate.
		  */
		double Y2() const {return y2;}
		/** Write an object directly.
		  *  @param stream The output stream to write to.
		  */
		virtual ostream& WriteDirect (ostream& stream) const
		{
			stream << "[" << x1 << " " << y1
			       << " " << x2 << " " << y2 << "]";
		}
	private:
		/** First X coordinate.
		  */
		double x1;
		/** First Y coordinate.
		  */
		double y1;
		/** Second X coordinate.
		  */
		double x2;
		/** Second Y coordinate.
		  */
		double y2;
	};
	class PageTree;
	/** Stream object.
	  */
	class PDFStream : public IndirectObject,
			public std::ostringstream
	{
	public:
		/** Constructor. Create a stream object.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		 PDFStream (unsigned long int objNum = 0L,
			unsigned short int genNum = 0,
			CrossReferenceTable *tab = NULL
		) : IndirectObject(objNum,genNum,tab) {}
		/** @memo Destructor.
		  */
		~PDFStream() {}
		/** Write an object directly.
		  *  @param stream The output stream to write to.
		  */
		virtual ostream & WriteDirect(ostream &stream) const;	
	private:
	};
	/** A vector of PDF Streams.
	  */
	typedef vector<PDFStream *> PDFStreamVector;
	/** Describes a single page.
	  */
	class Page : public TypedDictionary {
	public:
		friend class PageTree;
		/** Constructor.  Create a fresh Page object.
		  *  @param r Resource Dictionary.
		  *  @param mBox Media box.
		  *  @param cBox Crop box.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		Page (
			ResourceDictionary *r = NULL,
			Rectangle *mBox = NULL,
			Rectangle *cBox = NULL,
			unsigned long int objNum = 0L,
			unsigned short int genNum = 0,
			CrossReferenceTable *tab = NULL
		) : TypedDictionary("Page",objNum,genNum,tab)
		{
			parent = NULL; resources = r; 
			mediaBox = mBox; cropBox = cBox;
		}
		/** @memo Destructor.
		  */
		~Page() {}
		/** Append a stream to the page.
		  *  @param s The stream to append.
		  */
		void AppendStream(
			PDFStream *s
		) { contents.push_back(s);}		
	protected:
		/** Write an object directly.
		  *  @param stream The output stream to write to.
		  */
		virtual ostream & WriteDictionaryElements(
			ostream &stream
		) const;	
	private:
		/** The page's parent page tree.
		  */
		PageTree *parent;
		/** The page's resources.
		  */
		ResourceDictionary *resources;
		/** This page's media box.
		  */
		Rectangle *mediaBox;
		/** This page's crop box.
		  */
		Rectangle *cropBox;
		/** This page's contents vector.
		  */
		PDFStreamVector contents;		
	};
	/** A tree of pages.
	  */
	class PageTree : public TypedDictionary {
	public:
		/** Constructor.  Create a fresh Pager object.
		  *  @param r Resource Dictionary.
		  *  @param mBox Media box.
		  *  @param cBox Crop box.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		PageTree(
			ResourceDictionary *r = NULL,
			Rectangle *mBox = NULL,
			Rectangle *cBox = NULL,
			unsigned long int objNum = 0L,
			unsigned short int genNum = 0,
			CrossReferenceTable *tab = NULL
		) : TypedDictionary("PageTree",objNum,genNum,tab)
		{parent = NULL; resources = r; mediaBox = mBox; cropBox = cBox;}
		/** @memo Destructor.
		  */
		~PageTree() {}
		/** Add a page.
		  *  @param thepage The page to add.
		  */
		void AddPage(
			Page *thepage
		) {pagenodes.push_back((TypedDictionary*)thepage);
		   thepage->parent = this;}
		/** Add a tree of pages.
		  *  @param thepagetree The page tree to add.
		  */
		void AddPageTree(
			PageTree *thepagetree
		){pagenodes.push_back((TypedDictionary*)thepagetree);
		  thepagetree->parent = this;}
	protected:
		/** Write an object directly.
		  *  @param stream The output stream to write to.
		  */
		virtual ostream & WriteDictionaryElements(
			ostream &stream
		) const;	
	private:
		/** This page tree's parent.
		  */
		PageTree *parent;
		/** Resources for this page tree.
		  */
		ResourceDictionary *resources;
		/** Media box for this page tree.
		  */
		Rectangle *mediaBox;
		/** Crop box for this page tree.
		  */
		Rectangle *cropBox;
		/** The children of this page tree node.
		  */
		vector<TypedDictionary *> pagenodes;
	};
	/** Page label dictionary.
	  */
	class PageLabelDictionary : public TypedDictionary {
	public:
		/** Numbering style.
		  */
		enum NumberStyle {
			/** None.
			  */
			None = 0,
			/** Decimal arabic numerals.
			  */
			Decimal = 'D',
			/** Uppercase roman numerals.
			  */
			UpperRoman = 'R',
			/** Lowercase roman numerals.
			  */
			LowerRoman = 'r',
			/** Uppercase letters.
			  */
			UpperLetters = 'A',
			/** Lowercase letters.
			  */
			LowerLetters = 'a'
		};
		/** Constructor.  Create a fresh Pager object.
		  *  @param s Numbering style.
		  *  @param p Page label prefix string.
		  *  @param st Page number starting value for this range.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		PageLabelDictionary(NumberStyle s = None,const string p="",
				    int st = 1,unsigned long int objNum = 0L,
			unsigned short int genNum = 0,
			CrossReferenceTable *tab = NULL
		) : TypedDictionary("PageLabel",objNum,genNum,tab)
		{ style = s; prefix = p; start = st;}
		/** @memo Destructor.
		  */
		~PageLabelDictionary() {}
	protected:
		/** Write an object directly.
		  *  @param stream The output stream to write to.
		  */
		virtual ostream & WriteDictionaryElements(
			ostream &stream
		) const;	
	private:
		/** Page numbering style.
		  */
		NumberStyle style;
		/** Prefix string.
		  */
		string prefix;
		/** Page numbering start.
		  */
		int start;
	};
	class PageLabelTree;
	/** Map of PageLabelTree kids.
	  */
	typedef vector<PageLabelTree*> PageLabelTreeKidVector;
	/** Map of PageLabelDictionary numbers.
	  */
	typedef map<int, PageLabelDictionary*, less<int> > PageLabelDictionaryNumMap;
	/** A tree of page label dictionaries.
	  */
	class PageLabelTree : public Dictionary {
	public:
		/** Constructor.  Create a new page label tree.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		PageLabelTree(unsigned long int objNum = 0L,
			      unsigned short int genNum = 0,
			      CrossReferenceTable *tab = NULL)
		: Dictionary(objNum,genNum,tab) {isRoot = true;}
		/** @memo Destructor.
		  */
		~PageLabelTree() {}
		/** Add a page label tree node.
		  *  @param node The page label tree node.
		  */
		void AddPageLabelTree(PageLabelTree *node)
		{
			node->isRoot = false;
			kids.push_back(node);
		}
		/** Add a page label dictionary.
		  *  @param number The page label dictionary start page number.
		  *  @param pld Page label dictionary pointer.
		  */
		void AddPageLabelDictionary(int number,PageLabelDictionary *pld)
		{
			nums[number] = pld;
		}
		/** Return the number of sub-nodes in this page label tree.
		  */
		int Size() const {
			if (kids.size() == 0) return nums.size();
			else return kids.size();
		}
	protected:
		/** Write an object directly.
		  *  @param stream The output stream to write to.
		  */
		virtual ostream & WriteDictionaryElements(
			ostream &stream
		) const;	
	private:
		/** Get limits of the kids vector.
		  *  @param lower Lower end.
		  *  @param upper Upper end.
		  */
		void GetKidLimits(int& lower, int& upper) const;
		/** Root flag.
		  */
		bool isRoot;
		/** Kid nodes.
		  */
		PageLabelTreeKidVector kids;
		/** Num nodes.
		  */
		PageLabelDictionaryNumMap nums;
	};
	/** A Font dictionary object
	  */
	class FontDictionary : public TypedDictionary {
	public:
		/** Constructor.  Create a generic font dictionary.
		  *  @param subtype The type of the font.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		 FontDictionary (const string subtype,
			unsigned long int objNum = 0L,
			unsigned short int genNum = 0,
			CrossReferenceTable *tab = NULL
		) : TypedDictionary("Font",objNum,genNum,tab) {
			subType = subtype;
		}
		/** @memo Destructor.
		  */
		~FontDictionary() {}
	protected:
		/** Write the font's subtype.
		  *  @param stream The output stream to write to.
		 */
		ostream & WriteFontType(ostream &stream) const {
			stream << " /Subtype /" << subType << endl;
			return(stream);
		}
		/** Write this dictionary's elements.  Start with its type.
		  *  @param stream The output stream to write to.
		  */
		virtual ostream & WriteDictionaryElements(
			ostream &stream
		) const {
			WriteDictionaryType(stream);
			WriteFontType(stream);
			return stream;
		}
	private:
		/** The type of the font.
		  */
		string subType;
	};
	/** Indirect array of floats.
	  */
	class IndirectFloatVector : public IndirectObject, public vector<float> {
	public:
		/** Constructor.  Create an indirect object of floats.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		IndirectFloatVector(unsigned long int objNum = 0L,
				    unsigned short int genNum = 0,
				    CrossReferenceTable *tab = NULL
		) : IndirectObject(objNum,genNum,tab) {}
		/** @memo Destructor.
		  */
		~IndirectFloatVector();
		/** Write an object directly. Needs to be overloaded by derived
		  * classes.
		  *  @param stream The output stream to write to.
		  */
		virtual ostream& WriteDirect (ostream& stream) const
		{
			int count = 0;
			vector<float>::const_iterator i;
			stream << "[";
			for (i = begin(); i != end(); i++) {
				stream << " " << *i;
				count++;
				if (count == 20) {
					stream << endl;
					count = 0;
				}
			}
			stream << "]";
		}
	};		
	/** Type 1 Font dictionary.
	  */
	class Type1FontDictionary : public FontDictionary {
	public:
		/** Constructor.  Build a Type 1 font.
		  *  @param basefont Name of the base font.
		  *  @param firstchar The first character code.
		  *  @param lastchar The last character code.
		  *  @param widths_ The widths of the characters.
		  *  @param fontdescriptor The font description.
		  *  @param encoding The encoding of the font.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		Type1FontDictionary(const string basefont,
				    int firstchar,int lastchar,
				    IndirectFloatVector *widths_,
				    TypedDictionary *fontdescriptor,
				    const string encoding = "",
				    unsigned long int objNum = 0L,
				    unsigned short int genNum = 0,
				    CrossReferenceTable *tab = NULL
		) : FontDictionary("Type1",objNum,genNum,tab) {
			baseFont = basefont;
			firstChar = firstchar;
			lastChar = lastchar;
			widths = widths_;
			fontDescriptor = fontdescriptor;
			encodingName = encoding;
			encodingDictionary = NULL;
		}
		/** Constructor.  Build a Type 1 font.
		  *  @param basefont Name of the base font.
		  *  @param firstchar The first character code.
		  *  @param lastchar The last character code.
		  *  @param widths_ The widths of the characters.
		  *  @param fontdescriptor The font description.
		  *  @param encoding The encoding of the font.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		Type1FontDictionary(const string basefont,
				    int firstchar,int lastchar,
				    IndirectFloatVector *widths_,
				    TypedDictionary *fontdescriptor,
				    TypedDictionary *encoding,
				    unsigned long int objNum = 0L,
				    unsigned short int genNum = 0,
				    CrossReferenceTable *tab = NULL
		) : FontDictionary("Type1",objNum,genNum,tab) {
			baseFont = basefont;
			firstChar = firstchar;
			lastChar = lastchar;
			widths = widths_;
			fontDescriptor = fontdescriptor;
			encodingDictionary = encoding;
			encodingName = "";
		}
		/** @memo Destructor.
		  */
		~Type1FontDictionary() {}
	protected:
		/** Write an object directly.
		  *  @param stream The output stream to write to.
		  */
		virtual ostream & WriteDictionaryElements(
			ostream &stream
		) const;	
	private:
		/** Base font name.
		  */
		string baseFont;
		/** First character in widths array;
		  */
		int firstChar;
		/** Last character in widths array.
		  */
		int lastChar;
		/** Widths array.
		  */
		IndirectFloatVector *widths;
		/** Font Descriptor.
		  */
		TypedDictionary *fontDescriptor;
		/** Encoding as a name.
		  */
		string encodingName;
		/** Encoding as a dictionary.
		  */
		TypedDictionary *encodingDictionary;
	};
	/** A standard Type1 PostScript font dictionary.
	  */
	class PostScriptStandardType1FontDictionary
		: public Type1FontDictionary {
	public:
		/** Constructor.  Construct one of the 14 standard PostScript
		  *    fonts.
		  *  @param name The name of the PostScript font.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		PostScriptStandardType1FontDictionary(const string name,
				unsigned long int objNum = 0L,
				unsigned short int genNum = 0,
				CrossReferenceTable *tab = NULL
		) : Type1FontDictionary(name,0,0,NULL,NULL,"",objNum,genNum,
					tab) {}
		/** @memo Destructor.
		  */
		~PostScriptStandardType1FontDictionary() {}
	};
	/** Master catalog of the PDF file.
	  */
	class CatalogDictionary : public TypedDictionary {
	public:
		/** Constructor.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
                CatalogDictionary(unsigned long int objNum = 0L,
			      unsigned short int genNum = 0,
			      CrossReferenceTable *tab = NULL)
			: TypedDictionary("Catalog",objNum,genNum,tab)
		{pages = NULL;labels = NULL;}
		/** @memo Destructor.
		  */
		~CatalogDictionary() {}
		/** Add a page.
		  *  @param thepage The page to add.
		  */
		void AddPage(
			Page *thepage
		) {assert(pages != NULL);pages->AddPage(thepage);}
		/** Add a tree of pages.
		  *  @param thepagetree The page tree to add.
		  */
		void AddPageTree(
			PageTree *thepagetree
		){if (pages == NULL) pages = thepagetree;
		  else pages->AddPageTree(thepagetree);}
		/** Add a page label tree node.
		  *  @param node The page label tree node.
		  */
		void AddPageLabelTree(PageLabelTree *node)
		{
			if (labels == NULL) labels = node;
			else labels->AddPageLabelTree(node);
		}
		/** Add a page label dictionary.
		  *  @param number The page label dictionary start page number.
		  *  @param pld Page label dictionary pointer.
		  */
		void AddPageLabelDictionary(int number,PageLabelDictionary *pld)
		{
			assert(labels != NULL);
			labels->AddPageLabelDictionary(number,pld);
		}
	protected:
		/** Write an object directly.
		  *  @param stream The output stream to write to.
		  */
		virtual ostream & WriteDictionaryElements(
			ostream &stream
		) const;	
        private:
        	/** Pages.
        	  */
        	PageTree *pages;
		/** Page labels.
		  */
        	PageLabelTree *labels;
        };
	/** Information directory.  Contains random extra information about
	  *  the document.
	  */
	class InformationDirectory : public Dictionary {
	public:
		/** Constructor.  Create a basic information directory.
		  *  @param objNum The next object number.
		  *  @param genNum The generation number.
		  *  @param tab The cross reference table we are in.
		  */
		InformationDirectory(unsigned long int objNum = 0L,
			       unsigned short int genNum = 0,
			       CrossReferenceTable *tab = NULL)
		: Dictionary(objNum,genNum,tab) {
			title = "";
			author = "";
			subject = "";
			keywords = "";
			creater = "";
			producer = "";
			creationDate = 0;
			modificationDate = 0;
		}
		/** @memo Destructor.
		  */
		~InformationDirectory() {}
		/** The title.
		  */
		string title;
		/** The author.
		  */
		string author;
		/** The subject.
		  */
		string subject;
		/** The keywords.
		  */
		string keywords;
		/** The creater.
		  */
		string creater;
		/** The producer.
		  */
		string producer;
		/** The creationDate.
		  */
		time_t creationDate;
		/** The modificationDate.
		  */
		time_t modificationDate;
	protected:
		/** Write an object directly.
		  *  @param stream The output stream to write to.
		  */
		virtual ostream & WriteDictionaryElements(
			ostream &stream
		) const;	
	};
	/** Quote a string (protect special character with a backslash).
	  * @param str The string to quote.
	  */
	string QuotePDFString(const string& str);
};

/** Output stream operator for PDFNameArrays.
  * @param stream The stream to write to.
  * @param pnarray The array to write.
  */
ostream & operator<< (ostream & stream,
			const PDFFileStructures::PDFNameArray &pnarray);


#endif // _PDFPRINTERSUPPORT_H_


