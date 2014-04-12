// -!- c++ -!- //////////////////////////////////////////////////////////////
//
//  System        : 
//  Module        : 
//  Object Name   : $RCSfile$
//  Revision      : $Revision$
//  Date          : $Date$
//  Author        : $Author$
//  Created By    : Robert Heller
//  Created       : Fri Apr 11 13:42:00 2014
//  Last Modified : <140411.1342>
//
//  Description	
//
//  Notes
//
//  History
//	
/////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2014 Deepwoods Software.
// 
//  All Rights Reserved.
// 
// This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
// reproduced,  translated,  or  reduced to any  electronic  medium or machine
// readable form without prior written consent from Deepwoods Software.
//
//////////////////////////////////////////////////////////////////////////////

#ifndef __DISPATCHERREFERENCE_H
#define __DISPATCHERREFERENCE_H

/** @page dispatcher:Reference Dispatcher Reference
 * The Dispatcher program is used to create computerized CTC (Centralized
Traffic Control) panels, to be used by dispatchers as part of a CATC
(Computer Assisted Traffic Control) system to manage traffic flow for a
model railroad\footnote{It is also possible to use the Dispatcher
program to create the artwork for a ``manual'' CTC panel using
mechanical switches mounted on a panel.}.  A computerized CTC panel
typically contains a track work schematic and a collection of control
elements (such as switch plates, signal plates, toggle switches, push
buttons, etc.) that control the track work and track side signals.  In
addition to creating and editing CTC panels, the Dispatcher program can
read in an XTrkCAD layout file and create a compressed graph of the
track work and this graph can be used as a guide while creating CTC
panels.

\section{Main GUI Screen}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics[width=5in]{DISPMainGUI.png}
\caption{Main Dispatcher Window}
\label{fig:dispatcher:mainDispatcher}
\end{centering}
\end{figure}
The main GUI window of the Dispatcher program is shown in
Figure~\ref{fig:dispatcher:mainDispatcher}. It consists of a standard
menu bar, a tool bar, and an area for track work graph display. A
track work graph is something computer scientists call a ``directed
graph''.  A directed graph is a data structure consisting of nodes,
with links to other nodes.  In this case each node is a piece of
track work and the links are the connections between pieces of track work
and thus indicate the adjacency of track work nodes (and how the pieces
of track work interconnect with each other).  In the case of simple
track work (such as straight sections or curved sections), there are one
(if the section ``dead ends'') or two links and in the case of complex
track work (such as turnouts and crossings), there are three or more
links.  The graph is ``compressed'', where adjacent pieces of simple
track work are consolidated into single nodes. 

\subsection{Track work Node Graphs}

Once the compressed graph is built (upon loading a layout file), it is
displayed on the main GUI screen as numbered circles (nodes) connected
by lines with arrows (links).  A graphic of the piece of track work is
also drawn. Left clicking on a node displays a pop-up containing
information about the track work node.  Right clicking on a node pops up
a menu of actions involving the node\footnote{Current two menu items
are defined, one to display the node info and the other to add it to a
panel.}. Left clicking on a link displays a pop-up containing
information about the link.  The node numbers are the track element
numbers assigned by XTrkCad.

\subsubsection{Loading a Layout}

An XTrkCAD layout file is loaded either with the \verb=Load XTrkCad File=
tool bar button or with the \verb=Load...= item on the \verb=File=
menu. It is also possible to load a XTrkCAD layout file during
program start up using the \verb=-xtrkcad= command line option.

In all cases, the layout's track work is loaded a track work graph and
displayed in the track work graph display area.  Dispatcher then asks if
XTrkCad itself should be started.  This might be useful as it gives a
display of the actual layout on your screen, which can be referred to
when creating CTC panels.

\subsubsection{Finding Nodes}

A node can be ``found'' by its number.  Finding a node scrolls the node
graph to make the node visible and the node is highlighted.

\subsubsection{Printing Node Graphs}

A node graph can be printed to provide a hard-copy reference of the node
graph.

\subsection{Creating a new CTC Panel}
\label{sect:dispatcher:creatingCTCPanels}

\begin{figure}[hbpt] \begin{centering}
\includegraphics{DISPNewCTCPanel.png} \caption{New CTC Panel Dialog}
\label{fig:dispatcher:newCTCPanel} \end{centering} \end{figure} A new
CTC Panel is created with the \verb=New CTC Window= too bar button or
the \verb=New CTC Panel Window= entry under the \verb=File= menu.  A
New CTC Panel Dialog, as shown in
Figure~\ref{fig:dispatcher:newCTCPanel}, is displayed. This dialog box
asks the user for some basic information about the new panel.  This
includes the name (title) of the panel, its initial width and height,
whether it connects to a C/MRI bus and information about that bus, as
well as whether it uses MRD devices\footnote{MRD2-U or MRD2-S devices,
made by Azatrax.}. 

There is also a check button to select ``Simple Mode''.  ``Simple Mode''
simply means that the panel will be a simple one with canned code to
use Azatrax USB devices to actuate switch machines, either directly or
via NCE's Switch-It (or similar) units. The canned and auto-generated
code associates a Switch Plate with a switch and associates a Code
Button with 1 or more Switch Plates and Signal Plates\footnote{The
Signal Plates don't do anything but change their panel lights.}  In
``Simple Mode'', all of the UI elements relating to writing Tcl code
are disabled and all of the Tcl code is completely generated by the
Dispatcher program.  All the user does is place the track work elements
on the schematic and the control elements on the control panel and
provide some the serial number of the MRD2-U devices that are wired to
the Switch-Its and the names of the track work devices being controlled.

What is actually created is a Tcl/Tk program that uses parts of the
library of Tcl/Tk and C++ code included with the Model Railroad System
that will implement a CTC Panel, which contains two display sections: a
track work schematic and a control panel.  The track work schematic is in
the upper half of the panel and has a black background with white (red
when occupied) track work. Signals with one, two, or three heads can be
added to the track work schematic.  The control panel is in the lower
half and has a dark green background. The control panel can have switch
plates, signal plates, toggle switches, push buttons, code buttons, and
indicator lamps.

The CTC Panel can be used by a dispatcher using a computer screen and
pointing device (such as a mouse or touch pad) to select and manipulate
control elements. The track work on a CTC Panel will reflect the actual
track conditions (occupied or not, signal aspects, and turnout states).

\subsection{Opening an existing CTC Panel}

Existing CTC Panel programs are the specifically formatted Tcl/Tk
programs created by the Dispatcher program.  They can be opened and
edited using the \verb=Open CTC File= too bar button or the
\verb=Open...= entry under the \verb=File= menu or specified on the
Dispatcher's command line.  There are three sections of the code that
are ``loaded'' into the Dispatcher program: the collection of CTC Panel
elements, the information about the (optional) C/MRI network or Azatrax
USB devices, and the user code associated with the panel.

\section{Configurable Options}
\label{sect:dispatcher:configopts}

The configurable options can be set or changed with the 
\verb=Edit Configuration= menu entry under the \verb=Options= menu. These
configurable options can be saved with the \verb=Save Configuration=
menu entry under the \verb=Options= menu and can be loaded with the 
\verb=Load Configuration= menu entry.  At present there are three
configuration options: \verb=Use External Editor=, which has a boolean
value (true or false), \verb=External Editor=, which is a
command line that starts an external editor (the name of the file
to edit is appended to this command line), and \verb=Tcl Kit=, which is
the name of the Tclkit file to use for the run time when wrapping panel
programs (see Section~\ref{sect:dispatcher:wrapas}).

\section{CTC Panel Windows}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics[width=5in]{DISPEmptyCTCPanel.png}
\caption{Empty CTC Panel Window}
\label{fig:dispatcher:emptyCTCPanel}
\end{centering}
\end{figure}
A freshly created CTC Panel window is shown in
Figure~\ref{fig:dispatcher:emptyCTCPanel}\footnote{When the program is
run on its own, the Panel and C/Mri menus will be absent.}. The pink
square at the lower left indicates that the file is in a modified state
and has not been saved to disk.  Saving the file is done with the
\verb=Save= and \verb=Save As...= menu items under the \verb=File= menu.
It is also possible to create a standalone executable program file using
the \verb=Wrap As...= menu item under the \verb=File= menu (see
Section~\ref{sect:dispatcher:wrapas} for more information).

\subsection{Menu items available when editing a CTC Panel Window}

\subsubsection{File menu}

The \verb=File= contains entries to create a new CTC Panel Window, load
an XTrkCad file, open a CTC Panel Window, save the current CTC Panel
Window, wrap the current CTC Panel Window, close the current CTC Panel
Window, and exit.  Attempting to close a modified CTC Panel Window will
cause a save confirmation window, allowing you to save your work. There
are also menu items to print the panel graphics as a PDF page or to
export either the schematic or control panel as a bitmap image.  These
files can be printed and used as the artwork for a manual CTC panel
using mechanical switches.

\subsubsection{Edit menu}

In addition to the standard edit menu entries, there are three extra
entries\footnote{These items are disabled when in ``Simple Mode''.}:

\begin{description}
  \item[(Re-)Generate Main Loop] This entry generates (or regenerates)
the main loop.  The basic loop read all of the input ports of all of the
C/MRI nodes, invokes all of the track work elements, and then writes all
of the output ports of all of the C/MRI nodes.  The loop is an endless
real time loop.  It is necessary to ``fill in'' the logic of the CTC Panel.
  \item[User Code] This entry opens an editor to edit the user code
section of the CTC Panel program.
  \item[Modules] This entry inserts selected helper modules into the
user code section of the CTC Panel program.  These are all in name spaces
and are SNIT types:
    \begin{description}
      \item[Track Work types] This inserts two SNIT types, one for
blocks (usable for simple track work) and one for switches (turnouts).
      \item[Switch Plate type] This inserts a SNIT type to handle switch
plates. 
      \item[Signals] This inserts SNIT types to help with signals:
	\begin{description}
	   \item[Two Aspect Color Light] Use this module if you are
using two lamp or LED (red and green) signals.  One, two, and three head
signals are supported.
	   \item[Three Aspect Color Light] Use this module if you are
using three  lamp or LED (red,  yellow,  and green) signals.  One, two,
and three head signals are supported.
	   \item[Three Aspect Search Light] Use this module if you are 
using bi-color LEDs (red/green -- either three lead or two lead)
signals.  One, two, and three head signals are supported.
	\end{description}
      \item[Signal Plate type] This type handles Signal Plates.
      \item[Control Point type] Use this type for Code Button action code.
      \item[Radio Group Type] Use this type to collect a group of push 
buttons into an exclusive group where only one button is ``on'' at a
time.  Used to implement a software track selection matrix for a yard or
terminal.
    \end{description}
\end{description}

\subsubsection{View menu}

The \verb=View= menu contains entries to zoom in, zoom to a specific
level, and zoom out. This allows to grow or shrink the display.  This
lets the dispatcher get a view of a large layout in a single view or to
zoom in on a specific control point as needed.  This menu is also
available in the generated CTC Panel program.

\subsubsection{Panel menu}

The \verb=Panel= menu contains entries to add, edit, and delete panel
elements (both track work and control) and also has an entry to edit the
overall panel's configuration. 

\subsubsection{C/Mri menu}

The \verb=C/Mri= menu contains entries to add, edit, and delete C/MRI
nodes on the C/MRI bus. The C/MRI nodes contain input and output ports
that can be connected to things like occupancy detectors, turnout point
state switches, signal LEDs (or lamps), and switch machine motors.  They
can also be connected to manual controls and indicators on control
panels mounted over on beside the layout (eg ``local'' towers).


\subsubsection{MRD menu}

The \verb=MRD= menu contains entries to add, edit, and delete MRD nodes
on the USB bus. The MRD nodes contain IR sensors and relays that can be
connected to things like signal LEDs (or lamps), and switch machine
motors.

\section{CTC Panel Code}

The Dispatcher program creates Tcl scripts (programs).  That is, each
CTC Panel Window implies a Tcl/Tk script file and in fact this is what
is created when the window is ``saved''.  The script file contains
generated code, code that is created by the Dispatcher program (some of
which is pre-written code that is copied to the script file). And some
of the code is created by you the user of the program\footnote{When
running in ``Simple Mode'' you won't be writing any code. All of the
code will be generated by the Dispatcher program.}. This code
implements the CTC Panel that your model railroad's dispatcher will use
to control some part of your model railroad during an operating session.

\subsection{Wrapped CTC Panel Programs}
\label{sect:dispatcher:wrapas}

The \verb=Wrap As...= menu item on the file menu saves the CTC Panel
Code as a StarPack, a self-contained executable program file that runs
a Tcl/Tk program.  This program can be run as-is, without needing any
support files or code installed on the target system.  You can create
your panel on your desktop computer, which has the Model Railroad
System installed and then you can ``wrap'' your panel program and then
you can copy the generated executable program to a thumb drive and
transfer the program to the computer used as your dispatcher's screen.
The only 'gotcha' is that the computer used as your dispatcher's screen
should be generally the same kind of computer as the desktop computer
used to wrap the panel program -- eg both should be 32-bit MS-Windows
machines or both be 64-bit Linux machines, etc. You should also
``save'' your CTC Panel, if only to allow for future modifications and
to document your CTC Panel.  

\subsection{Generated Code}

The generated code consists of some prefix code including comments
containing the panel's configuration, followed by code to load various
packages used by the CTC Panel code, code to implement the panel
itself, and code to initialize the C/MRI bus and initialize the nodes
(boards) on the bus or code to initialize the Azatrax devices.

\subsubsection{Configuring CTC Panel Windows}
\label{sect:dispatcher:confpanel}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics{DISPEditPanelOptions.png}
\caption{Edit Panel Options Dialog}
\label{fig:dispatcher:editPanelOptsDialog}
\end{centering}
\end{figure}
The configuration of CTC Panel Windows can be changed using the
\verb=Configure= entry of the \verb=Panel= menu.  This menu entry
displays the Edit Panel Options Dialog, as shown in
Figure~\ref{fig:dispatcher:editPanelOptsDialog}. This dialog box allows
changing all of the same options as were set when the panel was created
(see Section~\ref{sect:dispatcher:creatingCTCPanels}).

\subsubsection{Adding, Editing, and deleting elements to CTC Panel Windows}
\label{sect:dispatcher:addeditdeletePanelElements}

CTC Panel elements can be added, edited, or deleted with the
\verb=Add=, \verb=Edit=, and \verb=Delete= entries of the \verb=Panel=
menu. There are twenty element types to select from.  CTC Panel
track work elements can also be added directly from the Track work Node
Graphs using the right button node menu.  Every CTC Panel element has a
unique name, is part of a control point\footnote{For mainline trackage
a control point of ``Main'' can be used.}, and has an X, Y location on
either the track work schematic (for track work elements) or the control
area (for control elements). The X, Y location(s) can be either set by
entering the coordinates directly (this allows precise positioning) or
by using cross hairs to position elements using the pointer device (eg
mouse)\footnote{After placing a device with the cross hairs, it is
possible to adjust the coordinates for added precision.}. Additionally,
element specific options are available for each element. When entering
Switch Plates in ``Simple Mode'', there is a provision for entering the
serial number of the MRD2-U device and the name of the track work
switch.  All of the command script entries are disabled, although the
generated scriptlets are shown (for the curious).

\subsubsection{Adding, Editing, and deleting C/Mri nodes to CTC Panel
Windows}

C/Mri nodes can be added, edited, or deleted with the \verb=Add=,
\verb=Edit=, and \verb=Delete= entries of the \verb=C/Mri=menu. Each
node has a unique name and unique UA (address).  There are three
supported board types: SMINI (Super Mini), USIC (Universal Serial
Interface Card) and SUSIC (Super Universal Serial Interface Card).

\subsubsection{Adding, Editing, and deleting MRD nodes to CTC Panel
Windows}

MRD nodes can be added, edited, or deleted with the \verb=Add=,
\verb=Edit=, and \verb=Delete= entries of the \verb=MRD=menu. Each
node has a unique name and unique serial numbers.

\subsection{User Code}

The user code is editable with the \verb=User Code= entry of the
\verb=Edit= menu.  This menu entry either starts a simple edit window
or starts a user-specified external editor (See
Section~\ref{sect:dispatcher:configopts}).  In addition to directly
editing the user code, one or more pre-written modules can be inserted
and a skeleton main loop can be created. When using the program in
``Simple Mode'' the user code menu items are disabled.  All code is
generated by the Dispatcher program.  The functions and logic are
limited to the canned ``Simple Mode'' functionality.  It is possible to
later turn off ``Simple Mode'' in the panel's configuration (see
Section~\ref{sect:dispatcher:confpanel}).

\subsubsection{Insert-able Modules}

These are a collection of SNIT types, in name spaces, that encapsulate
various common types of things that a CTC Panel implements, including
blocks, turnouts, signals, signal plates, control points, and radio
groups (commonly used to implement a software track selection matrix for
a yard or terminal).

\subsubsection{The Main Loop}

A skeleton main loop can be generated, but you will need to modify it to
implement the actual logic of your CTC Panels.  The basic main loop is an
endless, ``real time'' loop, that reads in all of the input ports,
invokes all of the track work, and then writes all of the output ports. 
It is necessary to decode the input bytes into bit fields which can be
stored in various types.  The occupation state and switch point state
information sensed from the inputs is used, along with the settings of
the control elements (switch plates, signal plates, etc.) is tested and
logical tests are applied to determine things like signal aspects and
switch motor values, etc. These values are then packed into the vectors
(lists) of output bytes which are then written to the output ports.

\section{Add CMRI Node Dialog}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics{DISPAddEditCMR_INode.png}
\caption{Add / Edit CMR/I Node Dialog}
\label{fig:dispatcher:addeditcmrinodedialog}
\end{centering}
\end{figure}
%
This dialog box adds a C/MRI node to the C/MRI bus.  These nodes are the
SUSIC, USIC, SMINI boards.  Each board has a name and an address (0 to
127). If the board is a SMINI board, it can have a count of yellow
signals and a yellow signal map and for SUSIC and USIC nodes, it has a
count on input and output ports and a map of card types. There is also a
delay value\footnote{Only meaningful for the older USIC boards.}. The
name will be a SNIT object instance name and should start with a letter
and contain only letters, digits, period, underscore, or dash.

\section{Select CMRI Node Dialog}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics{DISPSelectCMRINodeDialog.png}
\caption{Select CMR/I Node Dialog}
\label{fig:dispatcher:selectcmrinodedialog}
\end{centering}
\end{figure}
%
This dialog box selects an existing C/MRI node. It is possible to
specify a pattern to narrow the list of results.

\section{Add MRD Node Dialog}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics{DISPAddEditMRDNode.png}
\caption{Add / Edit MRD Node Dialog}
\label{fig:dispatcher:addeditmrdnodedialog}
\end{centering}
\end{figure}
%
This dialog box adds an Axatrax MRD-2 device and gives it a name that
can be used with the user code to access the device's state information
and to actuate its channels.  The dialog box asks for a name and the
device's serial number.

\section{Select MRD Node Dialog}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics{DISPSelectMRDNodeDialog.png}
\caption{Select MRD Node Dialog}
\label{fig:dispatcher:selectmrdnodedialog}
\end{centering}
\end{figure}
%
This dialog box selects an existing Axatrax MRD-2 device. It is possible to
specify a pattern to narrow the list of results.

\section{Add Panel Object Dialog}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics[width=4in]{DISPAddEditPanelObject.png}
\caption{Add / Edit Panel Object Dialog}
\label{fig:dispatcher:addeditpaneldialog}
\end{centering}
\end{figure}
%
This dialog box adds an object to either the schematic (track work)
panel or control panel.  Each object is of a specified type and has a
unique name, is part of a control point, and has various attributes,
such as a location (X and Y coordinates), orientation, label, etc.

\section{Select Panel Object Dialog}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics{DISPSelectPanelObject.png}
\caption{Select Panel Object Dialog}
\label{fig:dispatcher:selectpanelobjectdialog}
\end{centering}
\end{figure}
%
This dialog box selects an existing object on the schematic (track work)
panel or control panel.It is possible to specify a pattern to narrow
the list of results.

\section{Edit User Code Dialog}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics[width=4in]{DISPEditUserCode.png}
\caption{Edit User Code Dialog}
\label{fig:dispatcher:editusercodedialog}
\end{centering}
\end{figure}
%
This dialog box displays the user code and provides a simple text editor
to edit the user code.

\section{Find Node Dialog}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics{DISPFindNodeDialog.png}
\caption{Find Node Dialog}
\label{fig:dispatcher:findnodedialog}
\end{centering}
\end{figure}
%
This dialog box is used to find nodes by number in the node graph.

\section{Print Dialog}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics{DISPPrintDialog.png}
\caption{Print Dialog}
\label{fig:dispatcher:printdialog}
\end{centering}
\end{figure}
%
This dialog box selects the output PDF file and paper size for the print
operations\footnote{Really it is a save to PDF file. To really print you
need to open the PDF file with a PDF viewer and then select the Print
function of the viewer to then print the file.}.

\section{Select Panel Dialog}

\begin{figure}[hbpt]
\begin{centering}
\includegraphics{DISPSelectCTCPanel.png}
\caption{Print Dialog}
\label{fig:dispatcher:selectctcpaneldialog}
\end{centering}
\end{figure}
%
This dialog box selects the panel to add track work from the node graph to.

 */

#endif // __DISPATCHERREFERENCE_H

