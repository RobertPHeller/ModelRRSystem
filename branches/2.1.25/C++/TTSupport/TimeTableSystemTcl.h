/** @addtogroup TimeTableSystem
  * @{
  */

/** @defgroup TimeTableSystemTcl TimeTableSystemTcl
  * @brief Tcl Helper functions.
  *
  * These are top level Tcl support functions for the TimeTableSystem
  * class.  They are only available from Tcl, C++ programs have other API
  * functions, including overloaded constructors and iterator methods.
  *
  * @author Robert Heller \<heller\@deepsoft.com\>
  *
  * @{
  */


/** @brief Tcl constructor to create a new TimeTable.
  *
  * Tcl constructor to create a new TimeTable.  Calls the new time table 
  * constructor.
  *  @param name The name of the time table system.
  *  @param timescale Number of time units per 24 hours.  There are
  *	1440 minutes in 24 hours.
  *  @param timeinterval The tick frequency in time units.
  *  @returns A TimeTableSystem object.
  */

TimeTableSystem *NewCreateTimeTable(const char *name,int timescale,int timeinterval);
/** @brief Tcl constructor to create a time table system from an existing file.
  *
  * Tcl constructor to create a time table system from an existing file. The 
  * file is read in and the class is properly initialized 
  * from the data in the file.
  *  @param filename The name of the file to load. 
  *  @returns A TimeTableSystem object.
  */
TimeTableSystem *OldCreateTimeTable(const char *filename,char **outmessage = NULL);

%apply int MyTcl_Result { int ForEveryStation };
%apply int MyTcl_Result { int ForEveryCab };
%apply int MyTcl_Result { int ForEveryTrain };
%apply int MyTcl_Result { int ForEveryNote };
%apply int MyTcl_Result { int ForEveryPrintOption };
%apply int MyTcl_Result { int TT_StringListToList }
%apply int MyTcl_Result { int TT_ListToStringListString };

/** @brief Tcl looping construct for Stations.
  *
  * Tcl looping construct that loops over the stations in timetable, setting 
  * variable to the Station pointer and evaluates body.
  *  @param timetable The time table object.
  *  @param variable The loop variable.
  *  @param body The body script.
  *  @returns An empty string.
  */
int ForEveryStation(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variable,Tcl_Obj *body);
/** @brief Tcl looping construct for Cabs.
  *
  * Tcl looping construct that loops over the cabs in timetable, setting 
  * variable to the Cab pointer and evaluates body.
  *  @param timetable The time table object.
  *  @param variable The loop variable.
  *  @param body The body script.
  *  @returns An empty string.
  */
int ForEveryCab(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variable,Tcl_Obj *body);
/** @brief Tcl looping construct for Trains.
  *
  * Tcl looping construct that loops over the stations in timetable, setting 
  * variable to the Train pointer and evaluates body.
  *  @param timetable The time table object.
  *  @param variable The loop variable.
  *  @param body The body script.
  *  @returns An empty string.
  */
int ForEveryTrain(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variable,Tcl_Obj *body);
/** @brief Tcl looping construct for notes.
  *
  * Tcl looping construct that loops over the notes in timetable, setting 
  * variable to the note string and evaluates body.
  *  @param timetable The time table object.
  *  @param variable The loop variable.
  *  @param body The body script.
  *  @returns An empty string.
  */
int ForEveryNote(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variable,Tcl_Obj *body);
/** @brief Tcl looping construct for print options.
  *
  * Tcl looping construct that loops over the stations in timetable, setting 
  * variable to the print option key and evaluates body.
  *  @param timetable The time table object.
  *  @param variable The loop variable.
  *  @param body The body script.
  *  @returns An empty string.
  */
int ForEveryPrintOption(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variable,Tcl_Obj *body);

/** @brief Tcl function to convert a serialized string list to a Tcl list.
  *
  * Used to convert serialized C++ string lists to a Tcl list.
  * @param stringList A serialized string list.
  * @returns A Tcl list.
  */
int TT_StringListToList(Tcl_Interp *interp,const char *stringList);

/** @brief Tcl function to convert a Tcl list to a serialized string list.
  *
  * Used to convert Tcl lists to a form that the C++ code can deal with
  * portably.
  * @param list A Tcl list.
  * @returns A serialized string list.
  */
int TT_ListToStringListString(Tcl_Interp *interp,Tcl_Obj *list);

/** @} */

/** @} */

%{
namespace TTSupport {
static TimeTableSystem *NewCreateTimeTable(const char *name,int timescale,int timeinterval)
{
	return new TimeTableSystem(name,timescale,timeinterval);
}
static TimeTableSystem *OldCreateTimeTable(const char *filename,char **outmessage = NULL)
{
	return new TimeTableSystem(filename,outmessage);
}

static int ForEveryStation(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	int istation;

	for (istation = 0; istation < timetable->NumberOfStations(); istation++) {
	  Tcl_Obj *valuePtr, *varValuePtr;
	  valuePtr = SWIG_NewInstanceObj((void *) timetable->IthStation(istation),
					SWIGTYPE_p_TTSupport__Station,0);
	  varValuePtr = Tcl_ObjSetVar2(interp,variableName,NULL,valuePtr,0);
	  if (varValuePtr == NULL) {
	    Tcl_DecrRefCount(valuePtr);
	    Tcl_ResetResult(interp);
	    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
	    	"couldn't set loop variable: \"",
		Tcl_GetString(variableName),"\"", (char *) NULL);
	    result = TCL_ERROR;
	    break;
	  }
	  result = Tcl_EvalObjEx(interp, bodyPtr, 0);
	  if (result != TCL_OK) {
	    if (result == TCL_CONTINUE) {
	      result = TCL_OK;
	    } else if (result == TCL_BREAK) {
	      result = TCL_OK;
	      break;
	    } else if (result == TCL_ERROR) {
	      char msg[64 + TCL_INTEGER_SPACE];
	      sprintf(msg, "\n    (\"ForEveryStation\" body line %d)",
	      		interp->errorLine);
	      Tcl_AddObjErrorInfo(interp, msg, -1);
	      break;
	    } else {
	      break;
	    }
	  }
	  
	}
	if (result == TCL_OK) {
	  Tcl_ResetResult(interp);
	}
	return result;
}

static int ForEveryCab(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	CabNameMap::const_iterator Cx;

	for (Cx = timetable->FirstCab();Cx != timetable->LastCab(); Cx++) {
	  Tcl_Obj *valuePtr, *varValuePtr;
	  valuePtr = SWIG_NewInstanceObj((void *) Cx->second, SWIGTYPE_p_TTSupport__Cab,0);
	  varValuePtr = Tcl_ObjSetVar2(interp,variableName,NULL,valuePtr,0);
	  if (varValuePtr == NULL) {
	    Tcl_DecrRefCount(valuePtr);
	    Tcl_ResetResult(interp);
	    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
	    	"couldn't set loop variable: \"",
		Tcl_GetString(variableName),"\"", (char *) NULL);
	    result = TCL_ERROR;
	    break;
	  }
	  result = Tcl_EvalObjEx(interp, bodyPtr, 0);
	  if (result != TCL_OK) {
	    if (result == TCL_CONTINUE) {
	      result = TCL_OK;
	    } else if (result == TCL_BREAK) {
	      result = TCL_OK;
	      break;
	    } else if (result == TCL_ERROR) {
	      char msg[64 + TCL_INTEGER_SPACE];
	      sprintf(msg, "\n    (\"ForEveryCab\" body line %d)",
	      		interp->errorLine);
	      Tcl_AddObjErrorInfo(interp, msg, -1);
	      break;
	    } else {
	      break;
	    }
	  }
	  
	}
	if (result == TCL_OK) {
	  Tcl_ResetResult(interp);
	}
	return result;
}

static int ForEveryTrain(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	TrainNumberMap::const_iterator Tx;

	for (Tx = timetable->FirstTrain();Tx != timetable->LastTrain(); Tx++) {
#ifdef DEBUG
	  cerr << "*** ForEveryTrain(): Tx = " << Tx->second << endl;
#endif
	  Tcl_Obj *valuePtr, *varValuePtr;
	  valuePtr = SWIG_NewInstanceObj((void *) Tx->second, SWIGTYPE_p_TTSupport__Train,0);
#ifdef DEBUG
	  cerr << "*** ForEveryTrain(): valuePtr is {" << Tcl_GetString(valuePtr) << "}" << endl;
	  cerr << "*** ForEveryTrain(): variableName is {" << Tcl_GetString(variableName) << "}" << endl;
#endif
	  varValuePtr = Tcl_ObjSetVar2(interp,variableName,NULL,valuePtr,0);
	  if (varValuePtr == NULL) {
	    Tcl_DecrRefCount(valuePtr);
	    Tcl_ResetResult(interp);
	    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
	    	"couldn't set loop variable: \"",
		Tcl_GetString(variableName),"\"", (char *) NULL);
	    result = TCL_ERROR;
	    break;
	  }
#ifdef DEBUG
	  cerr << "*** ForEveryTrain(): varValuePtr is {" << Tcl_GetString(varValuePtr) << "}" << endl;
	  cerr << "*** ForEveryTrain(): bodyPtr is {" << Tcl_GetString(bodyPtr) << "}" << endl;
#endif
	  result = Tcl_EvalObjEx(interp, bodyPtr, 0);
#ifdef DEBUG
	  cerr << "*** ForEveryTrain(): result = " << result << endl;
#endif
	  if (result != TCL_OK) {
	    if (result == TCL_CONTINUE) {
	      result = TCL_OK;
	    } else if (result == TCL_BREAK) {
	      result = TCL_OK;
	      break;
	    } else if (result == TCL_ERROR) {
#ifdef DEBUG
	      cerr << "*** ForEveryTrain(): TCL_ERROR: " << Tcl_GetString(Tcl_GetObjResult(interp)) << endl;
	      cerr << "*** ForEveryTrain(): TCL_ERROR: at " << interp->errorLine << endl;
#endif
	      char msg[64 + TCL_INTEGER_SPACE];
	      sprintf(msg, "\n    (\"ForEveryTrain\" body line %d)",
	      		interp->errorLine);
	      Tcl_AddObjErrorInfo(interp, msg, -1);
	      break;
	    } else {
	      break;
	    }
	  }
	  
	}
	if (result == TCL_OK) {
	  Tcl_ResetResult(interp);
	}
	return result;
}

static int ForEveryNote(Tcl_Interp *interp,TimeTableSystem *timetable,Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	int inote;

	for (inote = 1; inote <= timetable->NumberOfNotes(); inote++) {
	  Tcl_Obj *valuePtr, *varValuePtr;
	  valuePtr = Tcl_NewStringObj(timetable->Note(inote),-1);
	  varValuePtr = Tcl_ObjSetVar2(interp,variableName,NULL,valuePtr,0);
	  if (varValuePtr == NULL) {
	    Tcl_DecrRefCount(valuePtr);
	    Tcl_ResetResult(interp);
	    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
	    	"couldn't set loop variable: \"",
		Tcl_GetString(variableName),"\"", (char *) NULL);
	    result = TCL_ERROR;
	    break;
	  }
	  result = Tcl_EvalObjEx(interp, bodyPtr, 0);
	  if (result != TCL_OK) {
	    if (result == TCL_CONTINUE) {
	      result = TCL_OK;
	    } else if (result == TCL_BREAK) {
	      result = TCL_OK;
	      break;
	    } else if (result == TCL_ERROR) {
	      char msg[64 + TCL_INTEGER_SPACE];
	      sprintf(msg, "\n    (\"ForEveryNote\" body line %d)",
	      		interp->errorLine);
	      Tcl_AddObjErrorInfo(interp, msg, -1);
	      break;
	    } else {
	      break;
	    }
	  }
	  
	}
	if (result == TCL_OK) {
	  Tcl_ResetResult(interp);
	}
	return result;
}

static int ForEveryPrintOption(Tcl_Interp *interp,TimeTableSystem *timetable,
			Tcl_Obj *variableName,Tcl_Obj *bodyPtr)
{
	int result = TCL_OK;
	OptionHashMap::const_iterator Ox;

	for (Ox = timetable->FirstPrintOption();Ox != timetable->LastPrintOption(); Ox++) {
#ifdef DEBUG
	  cerr << "*** ForEveryPrintOption: Ox->first = '" << Ox->first << "', Ox->second = '" << Ox->second << "'" << endl;
#endif
	  Tcl_Obj *valuePtr, *varValuePtr;
	  valuePtr = Tcl_NewStringObj(Ox->first,-1);
	  varValuePtr = Tcl_ObjSetVar2(interp,variableName,NULL,valuePtr,0);
	  if (varValuePtr == NULL) {
	    Tcl_DecrRefCount(valuePtr);
	    Tcl_ResetResult(interp);
	    Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
	    	"couldn't set loop variable: \"",
		Tcl_GetString(variableName),"\"", (char *) NULL);
	    result = TCL_ERROR;
	    break;
	  }
	  result = Tcl_EvalObjEx(interp, bodyPtr, 0);
	  if (result != TCL_OK) {
	    if (result == TCL_CONTINUE) {
	      result = TCL_OK;
	    } else if (result == TCL_BREAK) {
	      result = TCL_OK;
	      break;
	    } else if (result == TCL_ERROR) {
	      char msg[64 + TCL_INTEGER_SPACE];
	      sprintf(msg, "\n    (\"ForEveryPrintOption\" body line %d)",
	      		interp->errorLine);
	      Tcl_AddObjErrorInfo(interp, msg, -1);
	      break;
	    } else {
	      break;
	    }
	  }
	  
	}
	if (result == TCL_OK) {
	  Tcl_ResetResult(interp);
	}
	return result;
}

static int TT_ListToStringListString(Tcl_Interp *interp,Tcl_Obj *list)
{
	int objc,iobj;
	Tcl_Obj **objv;
	StringList sl;
	int status = Tcl_ListObjGetElements(interp,list,&objc,&objv);
	if (status != TCL_OK) return status;
	for (iobj = 0; iobj < objc; iobj++) {
	  sl.push_back(Tcl_GetStringFromObj(objv[iobj],NULL));
	}
	string result = StringListToString(sl);
	Tcl_Obj *resultObj = Tcl_NewStringObj(result.c_str(),-1);
	Tcl_SetObjResult(interp,resultObj);
	return TCL_OK;	
}

static int TT_StringListToList(Tcl_Interp *interp,const char *stringList)
{
	StringList slist;
	StringList::const_iterator Sx;
	if (StringListFromString(stringList,slist)) {
	  Tcl_Obj *tcl_result = Tcl_NewListObj(0,NULL);
	  for (Sx = slist.begin(); Sx != slist.end(); Sx++) {
	    if (Tcl_ListObjAppendElement(interp,tcl_result,
	    				 Tcl_NewStringObj((*Sx).c_str(),-1))
	    	  != TCL_OK) return TCL_ERROR;
	  }
	  Tcl_SetObjResult(interp,tcl_result);
	  return TCL_OK;
	} else {
	  Tcl_ResetResult(interp);
	  Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),
				 "Syntax error in string List: ",
				 stringList,NULL);
	  return TCL_ERROR;
	}
}
};
%}
