/* 
 * ------------------------------------------------------------------
 * PathName.h - Pathname class
 * Created by Robert Heller on Thu Aug 25 11:01:43 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
 * Modification History: Revision 1.3  2007/04/19 17:23:22  heller
 * Modification History: April 19 Lock Down
 * Modification History:
 * Modification History: Revision 1.2  2006/05/17 23:42:37  heller
 * Modification History: May 17, 2006 Lock down
 * Modification History:
 * Modification History: Revision 1.1  2006/01/03 15:30:21  heller
 * Modification History: Lockdown
 * Modification History:
 * Modification History: Revision 1.2  2005/11/14 20:28:44  heller
 * Modification History: Nov 14, 2005 Lockdown
 * Modification History:
 * Modification History: Revision 1.1  2005/11/04 19:41:57  heller
 * Modification History: Nov 4, 2005 Lockdown
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

#ifndef _PATHNAME_H_
#define _PATHNAME_H_

#include <Common.h>

/** @name  Pathname class and support types.
  * @doc  \TEX{\typeout{Generated from $Id$.}}
  * This class implements a pathname object in a portable, cross platform way.
  */
  

//@{

/** A Vector of strings.  Used as the list of path list in a PathName
  * instance.
  **/
typedef vector<string> stringVector;

/**  A Class that portably represents a pathname.
  */
class PathName {
public:
	/**  Default constructor.
	  */
	PathName () {pathname = "";}
	/**  Constructor, given a plain C string.
	  * @param p  The plain C string.
	  */
	PathName (const char *p) {
		pathname = p;
	}
	/**  Constructor, given a STL basic\_string.
	  * @param p  The STL basic\_string.
	  */
	PathName (string p) {pathname = p;}
	/**  Copy constructor.
	  * @param other The other instance.
	  */
	PathName (const PathName &other) {
		pathname = other.pathname;
	}
	///  Destructor.
	~PathName() {}
	/**  Assignment operator, from another pathname.
	  * @param other The other instance.
	  */
	PathName & operator= (PathName other) {
		pathname = other.pathname;
		return *this;
	}
	/**  Assignment operator, from a string.
	  * @param name The STL basic\_string.
	  */
	PathName & operator= (string name) {
		pathname = name;
		return *this;
	}
	/**  Equality operator.
	  * @param other The other instance.
	  */
	bool operator== (const PathName other) const {
		return (pathname == other.pathname);
	}
	/**  Less than operator.
	  * @param other The other instance.
	  */
	bool operator< (const PathName other) const {
		return (pathname < other.pathname);
	}
	/**  Greater than operator.
	  * @param other The other instance.
	  */
	bool operator> (const PathName other) const {
		return (pathname > other.pathname);
	}
	/**  Less than or equal operator.
	  * @param other The other instance.
	  */
	bool operator<= (const PathName other) const {
		return (pathname <= other.pathname);
	}
	/**  Greater than or equal operator.
	  * @param other The other instance.
	  */
	bool operator>= (const PathName other) const {
		return (pathname >= other.pathname);
	}
	/**  Are the two pathnames in the same directory?
	  * @param other The other instance.
	  */
	bool SameDirectory (const PathName other) const {
		return (Dirname() == other.Dirname());
	}
	/**  Return the last pathname component.
	  */
	string Tail() const;
	/**  Return only the directory name.
	  */
	string Dirname() const;
	/**  Return only the extension.
	  */
	string Extension() const;
	/**  Return the full pathname.
	  */
	string FullPath() const {return pathname;}
	/**  Return a list of pathname components.
	  */
	stringVector Split() const;
	/**  Return the pathname separater character.
	  */
	char   PathSeparator() const;
	/**  Concatenate pathnames.
	  * @param other The other instance.
	  */
	PathName   operator+ (const PathName other);
	/**  Concatenate a string to the tail of a pathname.
	  * @param tail The STL basic\_string.
	  */
	PathName   operator+ (string tail);
	/**  Append a pathname.
	  * @param other The other instance.
	  */
	PathName & operator+= (const PathName other);
	/**  Append a string.
	  * @param tail The STL basic\_string.
	  */
	PathName & operator+= (string tail);
private:
	/**  The pathname string.
	  */
	string pathname;
};

//@}

#endif // _PATHNAME_H_

