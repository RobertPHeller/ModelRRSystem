%title ""
%module Mrr
%{
#include <iostream.h>   
#include <strstream.h>
#include <fstream.h>
#include <ParseFile.h>
#include <Tree.h>
#include <MRRSigExpr.tab.h>
#include <MRRXtrkCad.tab.h>
static char rcsid[] = "$Id$";
%}

%include typemaps.i

%init %{
	if (Tcl_InitStubs(interp, "8.0", 0) == NULL) {
	    return TCL_ERROR;
	}
	Tcl_PkgProvide(interp,"Mrr","2.1");
%}

%typemap(tcl,out) int MyTcl_Result {
 return $source;
}

class MRRXtrkCad {
public:
	MRRXtrkCad(const char *);
	~MRRXtrkCad();
	const char * SourceFile();
};


%apply int MyTcl_Result { int MRRXtrkCad_Emit };
%apply int MyTcl_Result { int MRRXtrkCad_ProcessFile };

%addmethods MRRXtrkCad {
	int ProcessFile(Tcl_Interp *interp) {
		ostrstream error;
		if (self->ProcessFile(error) != 0) {
			_IO_ssize_t i = error.pcount();
			char *s = error.str();
			s[i] = '\0';
			Tcl_AppendResult(interp,s,(char*)NULL);
			error.freeze(0);
			return TCL_ERROR;
		} else return TCL_OK;
	}
	int Emit(Tcl_Interp *interp,const char * outfile) {
		Tcl_ResetResult(interp);
		ofstream output(outfile);
		self->Emit(output);
		return TCL_OK;
	}
}

