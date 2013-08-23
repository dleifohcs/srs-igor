//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-SPECS-manip.ipf
//
// Collection of functions for working with 1D waves; specifically for spectroscopy manipulation
// NEXAFS
//
//------------------------------------------------------------------------------------------------------------------------------------
//
// Copyright 2013 Steven Schofield
//
//    This library is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
//------------------------------------------------------------------------------------------------------------------------------------
#pragma rtGlobals=1


//------------------------------------------------------------------------------------------------------------------------------------
// Below is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------
//
// Function doSomethingWithSpecsData(actionType)
// Function GlobalsForSpecsGraph(graphName)
// Function CursorDependencyForSpecsGraph(graphName)
// Function CursorMovedForSpecsGraph(info, cursNum)
// Function subtractLeadingEdge(graphName)
// Function postEdgeNormalisation(graphName)
// Function findMinimum(graphName)
// Function prettyNEXAFS()
// Function setNEXAFSyAxis()
// Function setNEXAFSyAxisVariable()
// Function setDefaultNEXAFScursors()
//
//------------------------------------------------------------------------------------------------------------------------------------
// Above is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------



//------------------------------------------------------------------------------------------------------------------------------------
// Top level function for manipulating spectroscopy data
//------------------------------------------------------------------------------------------------------------------------------------
Function doSomethingWithSpecsData(actionType)
	String actionType
	// actionType = leadingSubtraction
		
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Get name of top graph
	String graphName= WinName(0,1)
	
	// Check if there is a graph before doing anything
	if( strlen(graphName) )

		// Create WinGlobals etc.
		GlobalsForGraph(graphName)
		
		// Move to the created data folder for the graph window
		SetDataFolder root:WinGlobals:$graphName
		
		// Get name of the Wave
		Wave w= WaveRefIndexed("",0,1)
		
		// Get DF name
		String/G wDF = GetWavesDataFolder(w,1)
		
		// Create global variable of path and name of image wave
		String/G wFullStr= GetWavesDataFolder(w,2)
		
		// Get wave name
		String/G wStr= WaveName("",0,1)
		
		// Remove the quotes from literal wave names
		wStr = possiblyRemoveQuotes(wStr)
		
		// Check dimension of the wave is > 1.  If not, do nothing.
		if (WaveDims(w)<2)
			// Call the appropriate function for the requested manipulation type
			// Note that it is important to still be in the datafolder root:WinGlobals:$graphName 
			// when these functions are called since they load  
			strswitch (actionType)
				case "leadingSubtraction":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
				
					// leading edge subtraction
					subtractLeadingEdge(graphName,"linear")
					
					break
					
				case "leadingConstantSubtraction":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// leading edge subtraction
					subtractLeadingEdge(graphName,"constant")
					
					break
				
				case "leadingAvgSubtraction":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// leading edge subtraction
					subtractLeadingEdge(graphName,"constantAvg")
					
					break
					
				case "postEdgeNormalisation":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// leading edge subtraction
					postEdgeNormalisation(graphName)
					
					break
					
					
				case "findMinimum":
				
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForSpecsGraph(graphName) 
					
					// leading edge subtraction
					findMinimum(graphName)
					
					break
				
				default:
					Print "Error, unknown manipulationType"
					break
					
			endswitch
		else 
				Print "Data must 1 dimensional.  Stopping."
		endif
	else
		Print "Error: no data window"
	endif
	
	//bring the graph containing the data to the front
	//DoWindow/F $graphName 

	// Move back to the original data folder
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------------------------------------------------------------
//Function GlobalsForSpecsGraph(graphName)
//	String graphName//
//
//	if ( DataFolderExists("root:WinGlobals")!=1 )
//		NewDataFolder/O root:WinGlobals
//	endif
//	if ( DataFolderExists("root:WinGlobals:"+graphName)!=1)
//		NewDataFolder/O root:WinGlobals:$graphName
//	endif
//End


//------------------------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------------------------
//Function CursorDependencyForSpecsGraph(graphName)
//	String graphName
//	
//	NewDataFolder/O root:WinGlobals
//	NewDataFolder/O/S root:WinGlobals:$graphName
//	String/G S_CursorAInfo, S_CursorBInfo
//	Variable/G dependentA
//	SetFormula dependentA, "CursorMovedForSpecsGraph(S_CursorAInfo, 0)"
//	Variable/G dependentB
//	SetFormula dependentB,"CursorMovedForSpecsGraph(S_CursorBInfo, 1)"
//End


//------------------------------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------------------------------
Function CursorMovedForSpecsGraph(info, cursNum)
	String info
	Variable cursNum // 0 if A cursor, 1 if B cursor 

	Variable result= NaN // error result
	
	// Check that the top graph is the one in the info string.
	String topGraph= WinName(0,1)
	String graphName= StringByKey("GRAPH", info)
	
	String DFSave= GetDataFolder(1);
	SetDataFolder root:WinGlobals:$graphName

	if( CmpStr(graphName, topGraph) == 0 )
		String tName= StringByKey("TNAME", info)
		String xPtStr= StringByKey("POINT", info)
		String yPtStr= StringByKey("YPOINT", info)
		Variable/G xPt= str2num(xPtStr)
		
		Variable leftXVal, rightXVal
		
		// If the cursor is off the trace name will be zero length so do nothing
		if( strlen(tName) ) // cursor still on
			leftXVal= hcsr(A)
			rightXVal= hcsr(A)
			Variable/G xA= leftXVal
			Variable/G xB= rightXVal

		endif
	endif
	
	//doSomethingWithSpecsData("leadingSubtraction")
	
	SetDataFolder DFSave
	return result
End


//------------------------------------------------------------------------------------------------------------------------------------
// Function to remove a background based on the slope of the leading edge
//------------------------------------------------------------------------------------------------------------------------------------
Function subtractLeadingEdge(graphName,type)
	String graphName,type
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G wDF			// data folder containing the data shown on the graph
	String/G wStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G wFullStr		// data folder plus wave name
	
	// Make wave assignment to the data.  This can be either a 2d, or 3d data wave
	Wave w= $wFullStr
	
	// Determine image size for positioning the cursors
	Variable xMin= DimOffset(w,0)
	Variable xMax= (DimDelta(w,0) * DimSize(w,0) + DimOffset(w,0))
	Variable xRange= xMax - xMin
	
	// Calculate cursor positions
	Variable leftCurs= xMin + (0.05 * xRange)
	Variable rightCurs= xMin + (0.13 * xRange)
	
	// Load the cursor positions from global variables if they exist
	Variable/G xA
	Variable/G xB
	
	// Try to load cursors from reference spectrum data folder if they exist
	NVAR cursorA = root:reference:cursorA
	NVAR cursorB = root:reference:cursorB

	if ( (Abs(xA)+Abs(xB))>0 && (Abs(xA)+Abs(xB)) < 10000 )  // assume if these are all zero then they have not been defined before, otherwise they have so use those numbers/
		leftCurs= xA
		rightCurs= xB
	elseif ( numtype (cursorA+cursorB)==0 )  // checks these are not NaN or INF
		leftCurs= cursorA
		rightCurs= cursorB
	endif

	// Place Cursors on Image (unless they are already there)
	if (strlen(CsrInfo(A))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) A, $wStr, leftCurs
	endif 
	if (strlen(CsrInfo(B))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) B, $wStr, rightCurs
	endif
	
	// Create a wave that will be used for the leading edge subtraction
	Duplicate/O w, fitW
	
	// Determine the wave to be used for leading edge subtraction, depending on type of subtraction desired
	
	strswitch ( type )
		case "constant":
			fitW = vcsr(A)   // horizontal line with y value equal to cursor A
			break
		case "constantAvg":  // horizontal line with y value equal to the average of y values between cursors
			fitW = mean(w,hcsr(A),hcsr(B))  // horizontal line with y value equal to mean y value between cursors
			break
		case "linear":
			CurveFit/NTHR=0 line  w[pcsr(A),pcsr(B)] /D=fitW
			Wave fitCoef=W_coef
			fitW= fitCoef[1]*x + fitCoef[0]
			Variable minY, maxY
			GetAxis/Q left
			RemoveFromGraph/Z/W=$graphName fitW
			SetAxis left V_min, V_max
			break
	endswitch
	
	// Show the wave used for subtraction on the graph window
	AppendToGraph/C=(0,0,0) fitW
	
	// change to data DF	
	SetDataFolder wDF
	
	// make wave name for subtracted wave
	String newWStr
	newWStr= wStr+"_CS"
	
	// Create new wave that has been modified
	Duplicate/O w, $newWStr
	
	// Make wave assignment
	Wave newW= $newWStr
	
	// Perform subtraction
	newW= w-fitW
	
	// Display result
	DoWindow/K $(newWStr+"0")
	Display/k=1/N=$newWStr newW
	String newGraphName= WinName(0,1)
	
	AutoPositionWindow/E/m=0/R=$graphName $newGraphName
End

//------------------------------------------------------------------------------------------------------------------------------------
// Function to perform post-edge normalisation
//------------------------------------------------------------------------------------------------------------------------------------
Function postEdgeNormalisation(graphName)
	String graphName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G wDF			// data folder containing the data shown on the graph
	String/G wStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G wFullStr		// data folder plus wave name
	
	// Make wave assignment to the data.  This can be either a 2d, or 3d data wave
	Wave w= $wFullStr
	
	// Determine image size for positioning the cursors
	Variable xMin= DimOffset(w,0)
	Variable xMax= (DimDelta(w,0) * DimSize(w,0) + DimOffset(w,0))
	Variable xRange= xMax - xMin
	
	// Calculate cursor positions
	Variable leftCurs= xMax - (0.05 * xRange)
	Variable rightCurs= xMax 
	
	// Load the cursor positions from global variables if they exist
	Variable/G xA
	Variable/G xB
	
	if ( (Abs(xA)+Abs(xB))!=0 && (Abs(xA)+Abs(xB)) < 10000 )  // assume if these are all zero then they have not been defined before, otherwise they have so use those numbers/

		leftCurs= xA
		rightCurs= xB

	endif
		
	// Place Cursors on Image (unless they are already there)
	if (strlen(CsrInfo(A))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) A, $wStr, leftCurs
	endif 
	if (strlen(CsrInfo(B))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) B, $wStr, rightCurs
	endif
	
	// Find average value between cursors
	WaveStats/R=[pcsr(A),pcsr(B)] w
	Variable normConstant = V_avg

	// change to data DF	
	SetDataFolder wDF
	
	// make wave name for subtracted wave
	String newWStr= wStr+"_N"
	
	// Create new wave that has been modified
	Duplicate/O w, $newWStr
	
	// Make wave assignment
	Wave newW= $newWStr
	
	// Perform normalisation
	newW= w/normConstant
	DoWindow/K $(newWStr+"0")
	Display/k=1/N=$newWStr newW
	String newGraphName= WinName(0,1)
	
	AutoPositionWindow/E/m=0/R=$graphName $newGraphName
	
End


//------------------------------------------------------------------------------------------------------------------------------------
// Function to remove a background based on the slope of the leading edge
//------------------------------------------------------------------------------------------------------------------------------------
Function findMinimum(graphName)
	String graphName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Create a global variable to contain the value of the determined minimum
	Variable/G peakMinLoc=NaN
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G wDF			// data folder containing the data shown on the graph
	String/G wStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G wFullStr		// data folder plus wave name
	
	// Make wave assignment to the data.  This can be either a 2d, or 3d data wave
	Wave w= $wFullStr
	
	// Determine image size for positioning the cursors
	Variable xMin= DimOffset(w,0)
	Variable xMax= (DimDelta(w,0) * DimSize(w,0) + DimOffset(w,0))
	Variable xRange= xMax - xMin
	
	// Duplicate wave and smooth it; will use the smoothed wave for peak fitting then delete this wave
	Duplicate/O w, $(wStr+"_smooth")
	Wave smW= $(wStr+"_smooth")
	// determine the smoothing factor by the length of the data
	Variable smth= Round(numpnts(smW)/20)
	Smooth smth, smW
	
	// Find minimum of wave
	FindPeak/Q/N smW
	Variable dataMin=V_PeakLoc
	Print "Found data minimum value at", dataMin, "eV"
	
	// Remove temporary smoothed wave
	KillWaves smW
	
	// Set cursor positions based on wave minimum
	Variable leftCurs= V_PeakLoc - (0.03 * xRange)
	Variable rightCurs= V_PeakLoc + (0.03 * xRange)
	
	// Load the cursor positions from global variables if they exist
	Variable/G xA
	Variable/G xB
	
	if ( (Abs(xA)+Abs(xB))!=0 && (Abs(xA)+Abs(xB)) < 10000 )  // assume if these are all zero then they have not been defined before, otherwise they have so use those numbers/

		leftCurs= xA
		rightCurs= xB

	endif
		
	// Place Cursors on Image (unless they are already there)
	if (strlen(CsrInfo(A))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) A, $wStr, leftCurs
	endif 
	if (strlen(CsrInfo(B))==0)
		Cursor/W=$graphName/s=0/c=(0,0,0) B, $wStr, rightCurs
	endif

	// Fit parabola to curve minimum (between cursors)
	Duplicate/O w, fitW
	CurveFit/Q/NTHR=0 poly 3,  w[pcsr(A),pcsr(B)] /D=fitW
	Wave fitCoef=W_coef
	fitW= fitCoef[2]*x^2 + fitCoef[1]*x + fitCoef[0]
	Variable minY, maxY
	GetAxis/Q left
	RemoveFromGraph/Z/W=$graphName fitW
	AppendToGraph/C=(0,0,0) fitW
	SetAxis left V_min, V_max
	
	// Find minimum of the fitted parabola
	FindPeak/Q/N fitW
	Variable fittedMin= V_PeakLoc
	Print "Found fitted minimum value at", fittedMin, "eV"
	
	// Set the global variable for peak min to be the location of the fitted minimum
	peakMinLoc= fittedMin
End

//------------------------------------------------------------------------------------------------------------------------------------
// Simple macro to make the axes of the graph nice
//------------------------------------------------------------------------------------------------------------------------------------
Function prettyNEXAFS()
	ModifyGraph width=566.929,height=283.465;DelayUpdate
	ModifyGraph mirror=1,standoff=0;DelayUpdate
	ModifyGraph tick=2;DelayUpdate
	SetAxis left 0,*;DelayUpdate
	SetAxis/A bottom;DelayUpdate
	Label left "Normalised Auger Yield";DelayUpdate
	Label bottom "Photon Energy (\\U)";DelayUpdate
	ModifyGraph fSize=16;DelayUpdate
	Label left "\\Z16Normalised Auger Yield";DelayUpdate
	Label bottom "\\Z16Photon Energy (\\U)"
	MakeTracesDifferentColours("YellowHot256")
	DoUpdate
	Legend/C/N=text0/F=0
	DoUpdate
End

//------------------------------------------------------------------------------------------------------------------------------------
// This looks for a variable in root:reference that determines the y-axis height and if it finds it it sets the y-axis
//------------------------------------------------------------------------------------------------------------------------------------
Function setNEXAFSyAxis()
	NVAR/Z yAxisHeight = root:reference:yAxisHeight
	if ( NVAR_Exists(yAxisHeight) )
		if ( yAxisHeight > 0)  // if variable is 0 or negative then autoscale, otherwise set the axis height
			SetAxis left 0, yAxisHeight
		else 
			SetAxis left 0, * 
		endif
	endif
End


//------------------------------------------------------------------------------------------------------------------------------------
// This will create global variables that store the desired y-axis height
//------------------------------------------------------------------------------------------------------------------------------------
Function setNEXAFSyAxisVariable()

	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	if ( DataFolderExists("root:reference") )
		SetDataFolder root:reference
	else
		NewDataFolder/S  root:reference
	endif 
	
	NVAR/Z yAxisHeight
	if ( NVAR_Exists(yAxisHeight)==0 )  // if cursorA variable does not exist then create it
		Variable/G yAxisHeight=0
	endif
	
	Variable promptyAxisHeight = yAxisHeight
		
	Prompt promptyAxisHeight, "Enter desired y-axis height (set to 0 for auto-scale)"
	DoPrompt "Y-axis height setting", promptyAxisHeight
		
	yAxisHeight=promptyAxisHeight
	
	// change back to original DF
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------------------------------
// This will create global variables that store the positions of the cursors used for NEXAFS
// preedge subtraction
//------------------------------------------------------------------------------------------------------------------------------------
Function setDefaultNEXAFScursors()
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	if ( DataFolderExists("root:reference") )
		SetDataFolder root:reference
	else
		NewDataFolder/S  root:reference
	endif 
	
	NVAR/Z cursorA, cursorB
	if ( NVAR_Exists(cursorA)==0 )  // if cursorA variable does not exist then create it
		Variable/G cursorA=0
	endif
	if ( NVAR_Exists(cursorB)==0 )  // if cursorA variable does not exist then create it
		Variable/G cursorB=0
	endif
	
	Variable promptCursA = cursorA
	Variable promptCursB = cursorB
	
	Prompt promptCursA, "Energy for left cursor"
	Prompt promptCursB, "Energy for right cursor"
	DoPrompt "Default Cursor Energies for Pre-edge Subtraction", promptCursA, promptCursB
		
	cursorA=promptCursA
	cursorB = promptCursB
	
	// change back to original DF
	SetDataFolder saveDF
End


