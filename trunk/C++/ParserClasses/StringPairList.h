// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Wed Feb 22 14:12:07 2017
//  Last Modified : <170222.1446>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//    Copyright (C) 2017  Robert Heller D/B/A Deepwoods Software
//			51 Locke Hill Road
//			Wendell, MA 01379-9728
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program; if not, write to the Free Software
//    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
// 
//
//////////////////////////////////////////////////////////////////////////////

#ifndef __STRINGPAIRLIST_H
#define __STRINGPAIRLIST_H

#ifdef SERIALIZATION
#include <boost/config.hpp>
#include <boost/serialization/access.hpp>
#endif 

/** @addtogroup ParserClasses
 * @{
 */

namespace Parsers {

/** The @c StringPairList class implements a linked list of pairs of strings,
 * used for signal aspects.
 * 
 * @author Robert Heller \<heller\@deepsoft.com\>
 *
 */

class StringPairList {
private:
    /**  The current asppect name.
     */
    char *name;
    /**  The current asppect script.
     */
    char *script;
    /**  The pointer to the next element.
     */
    StringPairList *next;
#ifdef SERIALIZATION
    friend class boost::serialization::access;
    template<class Archive>
          void serialize(Archive & ar, const unsigned int version)
    {
        ar & name;
        ar & script;
        ar & next;
    }
#endif
public:
    /** @brief Base constructor.
     */
    StringPairList(char *car_name = NULL, char *car_script = NULL, 
                   StringPairList *cdr=NULL)
    {
        name = car_name;
        script = car_script;
        next = cdr;
    }
    /**  Add an element to the {\em end} of the list.
     */
    static inline StringPairList* StringPairAppend(StringPairList *head, 
                                                   char *newTail_name, 
                                                   char *newTail_script)
    {
        StringPairList **prev;
        if (head == NULL) return new StringPairList(newTail_name,
                                                    newTail_script,NULL);
        for (prev = &head->next; *prev != NULL; prev = &((*prev)->next) ) ;
        *prev = new StringPairList(newTail_name,newTail_script,NULL);
        return head;
    }
    /**  Free up used memory.
     */
    static inline void CleanUpStringPairList(StringPairList *list, 
                                             bool freestrings = false)
    {
        StringPairList *ni;
        for (;list != NULL;list = ni) {
            ni = list->next;
            if (freestrings) {
                delete list->name;
                delete list->script;
            }
            delete list;
        }
    }
    /** Copy function.
     */
    static inline StringPairList *CopyList(const StringPairList *src,
                                           bool copystrings = false)
    {
        StringPairList *copy = NULL;
        while (src != NULL) {
            char *_name = src->name;
            char *_script = src->script;
            if (copystrings) {
                _name = new char [strlen(src->name)+1];
                strcpy(_name,src->name);
                _script = new char [strlen(src->script)+1];
                strcpy(_script,src->script);
            }
            copy = StringPairAppend(copy,_name,_script);
            src = src->next;
        }
        return copy;
    }
    /**  Output operator.
     */
    friend inline ostream& operator << (ostream& stream,StringPairList *list)
    {
        stream << '(' << '"' << list->name << '"' << ',' 
              << '"' << list->script << '"' << ')';
        if (list->next != NULL) stream << " " << list->next;
        return stream; 
    }
    /**  Name element accessor.
     */
    char *Name() const {return name;}
    /**  Script element accessor.
     */
    char *Script() const {return script;}
    /**  Next pointer accessor (Const version).
     */
    const StringPairList* Next() const {return next;}
    /**  Next pointer accessor (non-Const version).
     */
    StringPairList* Next() {return next;}
};

};

/** @} */
       
#endif // __STRINGPAIRLIST_H

