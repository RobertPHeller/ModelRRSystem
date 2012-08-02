/* 
 * ------------------------------------------------------------------
 * CallBack.h - Message Callback classes
 * Created by Robert Heller on Wed Aug 31 17:02:32 2005
 * ------------------------------------------------------------------
 * Modification History: $Log$
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

#ifndef _CALLBACK_H_
#define _CALLBACK_H_

#ifndef SWIG
#include <Common.h>

#endif

/** @name  Various callback classes.
    @doc  \TEX{\typeout{Generated from $Id$.}}
	These classes are used to provide a means for various class members
	to access code in the outer application to handle message passing and
	related activies. */
//@{

/**   Work In Progress Callback.  Provides a callback to manage a work in
	progress display.  This class is a dummy base class.  Applications
	can define member functions that manage an application specific
	work in progress display.
 */
class WorkInProgressCallback {
public:
	///  Constructor.
	WorkInProgressCallback() {}
	///  Destructor.
	virtual ~WorkInProgressCallback() {}
#ifndef SWIG
	/**  Start up the work in progress display.
	  @param Message An initial message string.*/
	virtual void ProgressStart(const string Message) const {}
	/**  Update the progress meter.
	  @param Percent The completion percentage, between 0 and 100.
		  A value of 100 indicates that the job is done.
	  @param Message A message to display, typically something
		  identifing what tasks have been completed.*/
	virtual void ProgressUpdate(int Percent,const string Message) const {}
	/**  Mark the process meter as done.
	  @param Message A message to display.*/
	virtual void ProgressDone(const string Message) const {}
#endif
};

/**   A callback to log a message. */
class LogMessageCallback {
public:
#ifndef SWIG
	///  The three types of messages.
	enum MessageType {
		///  Random informational messages.
		Infomational=1,
		///  Warning messages.
		Warning=2,
		///  Error messages.
		Error=3
	};
#endif
	///  Constructor.
	LogMessageCallback() {}
	///  Destructor.
	virtual ~LogMessageCallback() {}
#ifndef SWIG
	/**  Log message callback function.
	  @param Type The message type.
	  @param Message The message itself.*/
	virtual void LogMessage(MessageType Type,const string Message) const {}
#endif
};

///  Display a page heading type message on the screen.
class ShowBannerCallback {
public:
	///  Constructor.
	ShowBannerCallback() {}
	///  Destructor.
	virtual ~ShowBannerCallback() {}
#ifndef SWIG
	///  Display the banner.
	virtual void ShowBanner() const {}
#endif
};

///  Callback to manage a train status display.
class TrainDisplayCallback {
public:
	///  Constructor.
	TrainDisplayCallback() {}
	///  Destructor.
	virtual ~TrainDisplayCallback() {}
#ifndef SWIG
	/**   Initialize the train status display.  Set the train name,
	      the station count, max length and the maximum number of cars.
	  @param name Name of the train.
	  @param stationCount The station count (number of stops).
	  @param maxLength Maximum train length.
	  @param maxCars Maximum number of cars.*/
	virtual void InitializeTrainDisplay(string name,int stationCount,
		int maxLength,int maxCars) const {}
	///  Close the train display.
	virtual void CloseTrainDisplay() const {}
	///  Grab the train display.
	virtual void GrabTrainDisplay() const {}
	///  Release the train display.
	virtual void ReleaseTrainDisplay() const {}
	/**  Update the train display.
	  @param currentStationName The current station name.
	  @param currentStopName The current stop name.
	  @param trainLength The current train length.
	  @param numberCars The current number of cars.
	  @param trainTons The current number of tons.
	  @param trainLoads The current number of loaded cars.
	  @param trainEmpties The current number of empty cars.
	  @param trainLongest The longest the train has been.
	  @param currentStop The current stop number.*/
	virtual void UpdateTrainDisplay(string currentStationName,
		string currentStopName,int trainLength,int numberCars,
		int trainTons,int trainLoads,int trainEmpties,
		int trainLongest,int currentStop) const {}
#endif
};

///  The Pause callback.
class PauseCallback {
public:
	///  The constructor.
	PauseCallback() {}
	///  The destructor.
	virtual ~PauseCallback() {}
#ifndef SWIG
	/**  Display a message pause (wait for a user response).
	  @param message The message to display when pausing.*/
	virtual void Pause(string message) const {}
#endif
};


#ifdef SWIG
class Tcl8WorkInProgressCallback : public WorkInProgressCallback {
public:
	Tcl8WorkInProgressCallback(Tcl_Interp *interp,const char *start_,
				   const char *update_, const char *done_) {}
	virtual ~Tcl8WorkInProgressCallback() {}
};

%{
///  Swig Tcl 8.x derived class for work in progress handling.
class Tcl8WorkInProgressCallback : public WorkInProgressCallback {
public:
	/**   Constructor.  Gets passed in the Tcl Interpreter, plus a
	   collection of strings containing Tcl commands or procedures.
	   @param interp_ Tcl Interpreter to use.
	   @param start_ Start prodedure. This command gets one argument,
		  the message string for the work in progress startup.
	   @param update_ Update prodedure. This command gets two arguments,
		  the percent done (as an integer between 0 and 100), and an
		  update message string.
 	   @param done_ Done procedure.  This command gets one argument,
		  the done message string.*/
	Tcl8WorkInProgressCallback(Tcl_Interp *interp_,const char *start_,
		const char *update_,const char *done_) {
		interp = interp_;
		start  = start_;
		update = update_;
		done   = done_;
	}
	///  Destructor.
	virtual ~Tcl8WorkInProgressCallback() {}
	/**  Startup member function.
	  @param Message Startup message.*/
	virtual void ProgressStart(const string Message) const;
	/**  Update member function.
	  @param Percent Percent done, 0 to 100.
	  @param Message Update message.*/
	virtual void ProgressUpdate(int Percent,const string Message) const;
	/**  Done member function.
	  @param Message Completion message.*/
	virtual void ProgressDone(const string Message) const;
private:
	///  Interpreter to use for Tcl callbacks.
	Tcl_Interp *interp;
	///  Start procedure or command.
	string start;
	///  Update procedure or command.
	string update;
	///  Done procedure or command.
	string done;	
};

void Tcl8WorkInProgressCallback::ProgressStart(const string Message) const {
#ifdef DEBUG
	cerr << "*** Tcl8WorkInProgressCallback::ProgressStart(" << Message << ")" << endl;
#endif
	Tcl_Obj *striptObj = Tcl_NewListObj(0,NULL);
	if (Tcl_ListObjAppendElement(interp,striptObj,Tcl_NewStringObj((char *)start.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,striptObj,Tcl_NewStringObj((char *)Message.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
#ifdef DEBUG
	cerr << "*** Tcl8WorkInProgressCallback::ProgressStart: striptObj is " << Tcl_GetStringFromObj(striptObj,NULL) << endl;
#endif
	int result = Tcl_EvalObjEx(interp,striptObj,TCL_EVAL_GLOBAL);
#ifdef DEBUG
	cerr << "*** Tcl8WorkInProgressCallback::ProgressStart: result = " << result << endl;
#endif
	if (result != TCL_OK) Tcl_BackgroundError(interp);
}

void Tcl8WorkInProgressCallback::ProgressUpdate(int Percent,const string Message) const {
#ifdef DEBUG
	cerr << "*** Tcl8WorkInProgressCallback::ProgressUpdate(" << Percent << "," << Message << ")" << endl;
#endif
	Tcl_Obj *striptObj = Tcl_NewListObj(0,NULL);
	if (Tcl_ListObjAppendElement(interp,striptObj,Tcl_NewStringObj((char *)update.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,striptObj,Tcl_NewIntObj(Percent)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,striptObj,Tcl_NewStringObj((char *)Message.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
#ifdef DEBUG
	cerr << "*** Tcl8WorkInProgressCallback::ProgressUpdate: striptObj is " << Tcl_GetStringFromObj(striptObj,NULL) << endl;
#endif
	int result = Tcl_EvalObjEx(interp,striptObj,TCL_EVAL_GLOBAL);
#ifdef DEBUG
	cerr << "*** Tcl8WorkInProgressCallback::ProgressUpdate: result = " << result << endl;
#endif
	if (result != TCL_OK) Tcl_BackgroundError(interp);
}

void Tcl8WorkInProgressCallback::ProgressDone(const string Message) const {
#ifdef DEBUG
	cerr << "*** Tcl8WorkInProgressCallback::ProgressDone(" << Message << ")" << endl;
#endif
	Tcl_Obj *striptObj = Tcl_NewListObj(0,NULL);
	if (Tcl_ListObjAppendElement(interp,striptObj,Tcl_NewStringObj((char *)done.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,striptObj,Tcl_NewStringObj((char *)Message.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
#ifdef DEBUG
	cerr << "*** Tcl8WorkInProgressCallback::ProgressDone: striptObj is " << Tcl_GetStringFromObj(striptObj,NULL) << endl;
#endif
	int result = Tcl_EvalObjEx(interp,striptObj,TCL_EVAL_GLOBAL);
#ifdef DEBUG
	cerr << "*** Tcl8WorkInProgressCallback::ProgressDone: result = " << result << endl;
#endif
	if (result != TCL_OK) Tcl_BackgroundError(interp);
}
	
%}

class Tcl8LogMessageCallback : public LogMessageCallback {
public:
	Tcl8LogMessageCallback(Tcl_Interp *interp,const char *stript_) {}
	virtual ~Tcl8LogMessageCallback() {}
};

%{
///  Swig Tcl 8.x derived class for handling log messages.
class Tcl8LogMessageCallback : public LogMessageCallback {
public:
	/**   Constructor.  Gets the current Tcl interpreter and a
	   command or procedure to handle the log message.
	  @param interp_ The Tcl interpreter.
	  @param script_ The command or procedure to handle the log message. */
	Tcl8LogMessageCallback(Tcl_Interp *interp_,const char *script_) {
		interp = interp_;
		script = script_;
	}
	///  Destructor.
	virtual ~Tcl8LogMessageCallback() {}
	/**  Member function to handle log messages.
	  @param Type The message type.
	  @param Message The message itself.*/
	virtual void LogMessage(MessageType Type,const string Message) const ;
private:
	///  The saved Tcl interpreter.
	Tcl_Interp *interp;
	///  The saved command or procedure to handle the messages.
	string script;
};

void Tcl8LogMessageCallback::LogMessage(MessageType Type,const string Message) const {
	Tcl_Obj *scriptObj = Tcl_NewListObj(0,NULL);
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj((char *)script.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	switch (Type) {
		case Infomational:
			if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj(":informational",-1)) != TCL_OK) {
				Tcl_BackgroundError(interp);
			}
			break;
		case Warning:
			if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj(":warning",-1)) != TCL_OK) {
				Tcl_BackgroundError(interp);
			}
			break;
		case Error:
			if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj(":error",-1)) != TCL_OK) {
				Tcl_BackgroundError(interp);
			}
			break;
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj((char *)Message.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	int result = Tcl_EvalObjEx(interp,scriptObj,TCL_EVAL_GLOBAL);
	if (result != TCL_OK) Tcl_BackgroundError(interp);
}

%}		

class Tcl8ShowBannerCallback : public ShowBannerCallback {
public:
	Tcl8ShowBannerCallback(Tcl_Interp *interp,const char *showScript_) {}
	virtual ~Tcl8ShowBannerCallback() {}
};

%{
///  A Swig Tcl 8.0 derived class to handle the show banner callback.
class Tcl8ShowBannerCallback : public ShowBannerCallback {
public:
	/**   Constructor.  Gets the current Tcl interpreter and a
	  script to show the banner.
	  @param interp_ The Tcl interpreter.
	  @param showScript_ The script to show the banner.*/
	Tcl8ShowBannerCallback(Tcl_Interp *interp_,const char *showScript_) {
		interp = interp_;
		showScript = showScript_;
	}
	///  Destructor.
	virtual ~Tcl8ShowBannerCallback() {}
	///  Member function to show the banner.
	virtual void ShowBanner() const;
private:
	///  The saved Tcl interpreter.
	Tcl_Interp *interp;
	///  The script to show the banner.
	string showScript;	
};

void Tcl8ShowBannerCallback::ShowBanner() const {
	Tcl_Obj *scriptObj = Tcl_NewStringObj((char *)showScript.c_str(),-1);
	int result = Tcl_EvalObjEx(interp,scriptObj,TCL_EVAL_GLOBAL);
	if (result != TCL_OK) Tcl_BackgroundError(interp);
}
%}

class Tcl8TrainDisplayCallback : public TrainDisplayCallback {
public:
	Tcl8TrainDisplayCallback(Tcl_Interp *interp,const char *init_,
				 const char *close_,const char *grab_,
				 const char *release_,const char *update_);
	virtual ~Tcl8TrainDisplayCallback() {}
};

%{
///  A Swig Tcl 8.0 derived class for handling train status displays.
class Tcl8TrainDisplayCallback : public TrainDisplayCallback {
public:
	/**   Constructor.  Gets the Tcl interpreter and a collection of
	   commands or scripts to handle the various aspects of the train
	   status display.
	  @param interp_ The Tcl interpreter.
	  @param init_ The intitializing command or procedure.
	  @param close_ The close script.
	  @param grab_ The grab script.
	  @param release_ The release script.
	  @param update_ The update command or procedure.*/
	Tcl8TrainDisplayCallback(Tcl_Interp *interp_,const char *init_,
		const char *close_,const char *grab_,const char *release_,
		const char *update_) {
		interp = interp_;
		init = init_;
		closefn = close_;
		grab = grab_;
		release = release_;
		update = update_;
	}
	///  Destructor.
	virtual ~Tcl8TrainDisplayCallback() {}
	/**  The initialization member function.
	  @param name The name of the train.
	  @param stationCount The number of station stops the train makes.
	  @param maxLength The maximum length the train can be.
	  @param maxCars The maximum number of cars the train can carry.*/
	virtual void InitializeTrainDisplay(string name,int stationCount,
		int maxLength,int maxCars) const;
	///  Close the train status display.
	virtual void CloseTrainDisplay() const;
	///  Grab the train status display.
	virtual void GrabTrainDisplay() const;
	///  Release the train status display.
	virtual void ReleaseTrainDisplay() const;
	/**  Update the train status display.
	  @param currentStationName Current station name.
	  @param currentStopName Current stop name.
	  @param trainLength The current train length.
	  @param numberCars The current number of cars in the train.
	  @param trainTons The current weight of the train.
	  @param trainLoads The current number of loaded cars in the train.
	  @param trainEmpties The current number of empty cars in the train.
	  @param trainLongest The longest the train has been.
	  @param currentStop The current stop number.*/
	virtual void UpdateTrainDisplay(string currentStationName,
		string currentStopName,int trainLength,int numberCars,
		int trainTons,int trainLoads,int trainEmpties,
		int trainLongest,int currentStop) const;
private:
	///  The saved Tcl interpter.
	Tcl_Interp *interp;
	///  The initialize procedure.
	string init;
	///  The close script.
	string closefn;
	///  The grab script.
	string grab;
	///  The release script.
	string release;
	///  The update procedure.
	string update;
};

void Tcl8TrainDisplayCallback::InitializeTrainDisplay(string name,
						      int stationCount,
						      int maxLength,
						      int maxCars) const
{
	Tcl_Obj *scriptObj = Tcl_NewListObj(0,NULL);
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj((char *)init.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj((char *)name.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewIntObj(stationCount)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewIntObj(maxLength)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewIntObj(maxCars)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	int result = Tcl_EvalObjEx(interp,scriptObj,TCL_EVAL_GLOBAL);
	if (result != TCL_OK) Tcl_BackgroundError(interp);
}

void Tcl8TrainDisplayCallback::CloseTrainDisplay() const
{
	Tcl_Obj *scriptObj = Tcl_NewStringObj((char *)closefn.c_str(),-1);
	int result = Tcl_EvalObjEx(interp,scriptObj,TCL_EVAL_GLOBAL);
	if (result != TCL_OK) Tcl_BackgroundError(interp);
}

void Tcl8TrainDisplayCallback::GrabTrainDisplay() const
{
	Tcl_Obj *scriptObj = Tcl_NewStringObj((char *)grab.c_str(),-1);
	int result = Tcl_EvalObjEx(interp,scriptObj,TCL_EVAL_GLOBAL);
	if (result != TCL_OK) Tcl_BackgroundError(interp);
}

void Tcl8TrainDisplayCallback::ReleaseTrainDisplay() const
{
	Tcl_Obj *scriptObj = Tcl_NewStringObj((char *)release.c_str(),-1);
	int result = Tcl_EvalObjEx(interp,scriptObj,TCL_EVAL_GLOBAL);
	if (result != TCL_OK) Tcl_BackgroundError(interp);
}

void Tcl8TrainDisplayCallback::UpdateTrainDisplay(string currentStationName,
						  string currentStopName,
						  int trainLength,
						  int numberCars,int trainTons,
						  int trainLoads,
						  int trainEmpties,
						  int trainLongest,
						  int currentStop) const
{
	Tcl_Obj *scriptObj = Tcl_NewListObj(0,NULL);
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj((char *)update.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj((char *)currentStationName.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj((char *)currentStopName.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewIntObj(trainLength)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewIntObj(numberCars)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewIntObj(trainTons)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewIntObj(trainLoads)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewIntObj(trainEmpties)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewIntObj(trainLongest)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewIntObj(currentStop)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	int result = Tcl_EvalObjEx(interp,scriptObj,TCL_EVAL_GLOBAL);
	if (result != TCL_OK) Tcl_BackgroundError(interp);
}

%}

class Tcl8PauseCallback : public PauseCallback {
public:
	Tcl8PauseCallback(Tcl_Interp *interp,const char *pause_);
	virtual ~Tcl8PauseCallback() {}
};


%{
///  A Swig Tcl 8.0 detived class for handling pause callbacks.
class Tcl8PauseCallback : public PauseCallback {
public:
	/**   Constructor.  Save the Tcl interpreter and the pause
	   procedure or command.
	  @param interp_ The Tcl Interpreter.
	  @param pause_ The pause procedure.*/
	Tcl8PauseCallback(Tcl_Interp *interp_,const char *pause_) {
		interp = interp_;
		pause = pause_;
	}
	///  Destructor.
	virtual ~Tcl8PauseCallback() {}
	/**  The pause member function.
	  @param message The pause message.*/
	void Pause(string message) const;
private:
	///  The Tcl interpreter.
	Tcl_Interp *interp;
	///  The pause procedure.
	string pause;
};

void Tcl8PauseCallback::Pause(string message) const
{
	Tcl_Obj *scriptObj = Tcl_NewListObj(0,NULL);
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj((char *)pause.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	if (Tcl_ListObjAppendElement(interp,scriptObj,Tcl_NewStringObj((char *)message.c_str(),-1)) != TCL_OK) {
		Tcl_BackgroundError(interp);
	}
	int result = Tcl_EvalObjEx(interp,scriptObj,TCL_EVAL_GLOBAL);
	if (result != TCL_OK) Tcl_BackgroundError(interp);
}

%}

#endif

//@}
	
#endif // _CALLBACK_H_

