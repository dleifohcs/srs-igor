//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-STM-data-manip.ipf
//
// A collection of functions for manipulating scanning tunnelling microscopy data
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
#pragma rtGlobals=1		// Use modern global access method.


//------------------------------------------------------------------------------------------------------------------------------------
// Below is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------
//
//------------------------------
// Top level
//------------------------------
// Function doSomethingWithData(actionType)
//
//------------------------------
// Line profile from data
//------------------------------
// Function lineProfile(graphname)
// Function makeLineProfile(graphname)
// Function updateLineProfile(graphname)
//
//------------------------------
// Cursor functions
//------------------------------
// Function CursorDependencyForGraph(graphName)
// Function CursorMovedForGraph(info, cursNum)
//
//-------------------------------
// Global Programme control
//-------------------------------
// Function VariablesForProgramControl()
//
//-------------------------------
// Background subtraction
//-------------------------------
// Function subtractPlane(graphname,[ROI])
// Function subtractMin(graphname)
// Function subtractLinewise(graphname)
//
//-------------------------------
// CITS functions
//-------------------------------
// Function dispSTSfromCITS(graphname,)
// Function backupData(graphname,suffixStr)
// Function manipulateCITS(graphname,action)
// Function refresh3dData(graphName)
// Function matrixConvolveData(graphName)
// Function makeKernel(graphName,dim)
// Function quickSaveImage([symbolicPath,imageType])
// Function quickScript(scriptType)
// Function createROI(graphname)
// Function killROI(graphname)
// Function imageArithmetic(graphname)
//
//------------------------------------------------------------------------------------------------------------------------------------
// Above is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------------------------
// This function gets data from the top window, creates appropriate variables in root:WinGlobals
// and then calls some function to operate on the data according to value it is called with.
// This is for 2D and 3D data sets
Function doSomethingWithData(actionType)
	String actionType
	// actionType={ 
	//--- ANALYSIS
	//						"lineprofile"
	//--- MANIPULATION
	//						"subtractplane"
	//						"subtractplaneROI"
	// 						"subtractlinewise"
	// 						"subtractMin"
	//						"imageArithmetic"
	//--
	// 						"STSfromCITS"
	//						"duplicateLinePlot"
	// 						"differentiateCITS"
	// 						"smoothZ"
	//						"mConvolution"
	// 						"extractImageFromCITS"
	//
	//						"createROI"
	//						"killROI"
	//--- APPEARANCE
	//						"makeImgPretty"
	//						"changeColour"
	
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

		// Get name of the image Wave
		String wnameList = ImageNameList("", ";")
		String/G imgWStr = StringFromList(0, wnameList)
		// Remove the quotes from literal wave names
		imgWStr = possiblyRemoveQuotes(imgWStr)
		
		// Get datafolder of the image wave
		String/G imgDF
		imgDF = ImageInfo("",imgWStr,0)		
		imgDF = StringByKey("ZWAVEDF",imgDF)

		// Create global variable of path and name of image wave
		String/G imgWFullStr= imgDF+PossiblyQuoteName(imgWStr)
		
		// Create Wave assignment for image
		Wave imgW= $imgWFullStr 

		// Check dimension of the wave is > 1.  If not, do nothing.
		if (WaveDims(imgW)>1)
			// Call the appropriate function for the requested manipulation type
			// Note that it is important to still be in the datafolder root:WinGlobals:$graphName 
			// when these functions are called since they load  
			strswitch (actionType)
				case "lineprofile":
						
					// Establish link between cursor positions and CursorMoved fn. 
					CursorDependencyForGraph(graphName) 
					
					// generate line profile
					lineProfile(graphName)
					break
					
				case "subtractplane":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"P")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					subtractPlane(graphName)
					
					// Update the colour scale (important after background substraction)
					updateColourRange(graphName)

					// Update line profiles after manupulating data
					updateLineProfile(graphname)
					
					break

				case "subtractplaneROI":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"R")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					subtractPlane(graphName,ROI="yes")
					
					// Update the colour scale (important after background substraction)
					updateColourRange(graphName)

					// Update line profiles after manupulating data
					updateLineProfile(graphname)
					
					break
					
				case "subtractlinewise":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"L")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					subtractLinewise(graphName)
					
					// Update the colour scale (important after background substraction)
					updateColourRange(graphName)

					// Update line profiles after manupulating data
					updateLineProfile(graphname)
					
					break
				
				case "subtractMin":
					
					// Function for removing a plane background
					subtractMin(graphName)
					
					// Update the colour scale (important after background substraction)
					updateColourRange(graphName)
					
					// Update line profiles after manupulating data
					updateLineProfile(graphname)
					
					break
					
				case "imageArithmetic":
					
					imageArithmetic(graphName)
					
					break
					
				case "differentiateCITS":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"D")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					manipulateCITS(graphName,"differentiate")
					
					break

				case "smoothZ":
					
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"S")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function for removing a plane background
					manipulateCITS(graphName,"smoothZ")
					
					break
					
				case "STSfromCITS":
				
					// Make wave assignment to 3d data wave
					Wave citsImgW
					
					// Check that the image displayed has an associated 3d dataset.  The image must have been displayed with the SRS macros that generate the appropriate global variables
					if (WaveExists(citsImgW)==1)
				
						// Establish link between cursor positions and CursorMoved fn. 
						CursorDependencyForGraph(graphName)
					
						// Display STS curve
						dispSTSfromCITS(graphName)
					else
						Print "Error: this is not a 3d data set, or it was not displayed using the img3dDisplay(imgWStr) function of the SRS-STM macros"
					endif
					break
					
				case "duplicateLinePlot":
					
					duplicateLinePlotNewWaves()
					break
					
				case "createROI":
				
					// create ROI on graphName
					createROI(graphName)

					break
				
				case "killROI":
				
					// killl ROIs if any exist
					killROI(graphName)

					break
					
				case "mConvolution":
				
					// Make a back up copy of the original data in a data folder of the same name
					backupData(graphName,"M")  // the string in the second variable is appended to wave name after backup up the original data
					
					// Function convolving a matrix with the data
					matrixConvolveData(graphName)

					break
				
				case "extractImageFromCITS":
				
					// Function convolving a matrix with the data
					manipulateCITS(graphname,"extractImage")

					break
					
				case "extractImageSFromCITS":
				
					// Function convolving a matrix with the data
					manipulateCITS(graphname,"extractImages")

					break
				

				case "makeImgPretty":

					// Change graph size, etc., so that it looks nice
					imgGraphPretty(graphName)
					
					// Add a z-scale
					imgScaleBar(graphName)
					
					// Apply a colour scale to the image
					changeColour(graphName,colour="Autumn")

					// Add information panel
					imgAddInfo(graphName)

					break
					
				case "make3DImgPretty":

					// Change graph size, etc., so that it looks nice
					imgGraphPretty(graphName)
					
					// Add a z-scale
					imgScaleBar(graphName)
					
						
					// Apply a colour scale to the image
					changeColour(graphName,colour="Blue2")
					
					// Add information panel area
					img3DInfoPanel(graphName)
					
					// Add image information (bias, current, etc.)
					//imgAddInfo(graphName)

					break
					
				case "changeColour":
					
					changeColour(graphName,changeScale="no")
					break
					
				default:
					Print "Error, unknown manipulationType"
					break
					
			endswitch
		else 
				Print "Data must be 2 or 3 dimensional.  Stopping."
		endif
	else
		Print "Error: no data window"
	endif
	
	//bring the graph containing the data to the front
	DoWindow/F $graphName 

	// Move back to the original data folder
	SetDataFolder saveDF
End


//--------------------------------------------------------------------------------------------------------------
// This is called from the manipulateData function when user asks for a line profile of the current graph
Function lineProfile(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data.  This can be either a 2d, or 3d data wave
	Wave imgW= $imgWFullStr

	// Determine image size for positioning the cursors
	Variable xMin= DimOffset(imgW,0)
	Variable xMax= (DimDelta(imgW,0) * DimSize(imgW,0) + DimOffset(imgW,0))
	Variable yMin= DimOffset(imgW,1)
	Variable yMax= (DimDelta(imgW,1) * DimSize(imgW,1) + DimOffset(imgW,1))
	Variable xRange = xMax - xMin
	Variable yRange = yMax - yMin
	
	// Calculate cursor positions
	Variable leftCursX= xMin + (0.25 * xRange)
	Variable rightCursX= xMax - (0.25 * xRange)
	Variable leftCursY= yMin + (0.25 * yRange)
	Variable rightCursY= yMax - (0.25 * yRange)
	
	// Load the cursor positions from global variables if they exist
	Variable/G xA
	Variable/G xB
	Variable/G yA
	Variable/G yB
	
	if ( (Abs(xA)+Abs(xB)+Abs(yA)+Abs(yB))!=0 && (Abs(xA)+Abs(xB)+Abs(yA)+Abs(yB)) < 10000 )  // assume if these are all zero then they have not been defined before, otherwise they have so use those numbers/

		leftCursX= xA
		rightCursX= xB
		leftCursY= yA
		rightCursY= yB

	endif
	
	// Generate folder and global variables for 2d plot (if working with 3d data set)
	// This must be done before calling "Cursor" below, since the 2dline profile DF in WinGlobals needs to be created before the cursors are placed
	if (WaveExists(citsImgW)==1)

		// Create name that will be used for the 2d slice graph window and associated WinGlobals folder
		String/G lineProfile2dGraphName= graphName+"_2dProfile"
		
		// Create WinGlobals etc. for the 2d line profile graph window (this is used later for colour scaling etc.)
		GlobalsForGraph(lineProfile2dGraphName)
		
	endif
	
	// Place Cursors on Image (unless they are already there)
	if (strlen(CsrInfo(A))==0)
		Cursor/W=$graphName/I/s=1/c=(65535,65535,65535) A, $imgWStr, leftCursX, leftCursY
	endif 
	if (strlen(CsrInfo(B))==0)
		Cursor/W=$graphName/I/s=1/c=(65535,65535,65535) B, $imgWStr, rightCursX, rightCursY
	endif
			
	// Create Global Variables with Cursor Positions
	Variable/G xB= hcsr(B)
	Variable/G yB= vcsr(B)
	Variable/G xA= hcsr(A)
	Variable/G yA= vcsr(A)
	
	// Make a wave to display a line between the cursors on the image
	Make/O/N=2 lineprofx={xA,xB}, lineprofy={yA,yB}
	RemoveFromGraph/Z lineprofy // in case a line profile already drawn then remove it
	AppendToGraph lineprofy vs lineprofx // display the path on the image
	ModifyGraph rgb=(65535,65535,65535); DoUpdate  // change colour to white	

	// We don't actually need to run "makelineprofile()" because this is called when the cursors are generated above	
//	makelineprofile(graphName)
	
	// Make wave assignment to the 1d line profile generated in makeLineProfile()
	Wave lineProfile1D
	
	// Create a new graph to display the line profile
	String/G lineProfileGraphName= graphName+"_lineprofile"
	DoWindow/K $lineProfileGraphName
	Display/k=1/N=$lineProfileGraphName 
	AppendToGraph/W=$lineProfileGraphName lineProfile1D
	
	//--- now do 2d image slice
	
	// Generate folder and global variables for 2d plot (if working with 3d data set)
	if (WaveExists(citsImgW)==1)

		// Create name that will be used for the 2d slice graph window and associated WinGlobals folder
		String/G lineProfile2dGraphName= graphName+"_2dProfile"
		
		// Create WinGlobals etc. for the 2d line profile graph window (this is used later for colour scaling etc.)
		GlobalsForGraph(lineProfile2dGraphName)
		
		// Move into the WinGlobals folder for the 2d slice
		SetDataFolder root:WinGlobals:$(lineProfile2dGraphName)
		
		// Create global variables in this data folder.  These are used by other procedures such as the colour change function
		String/G imgDF= "root:WinGlobals:"+lineProfile2dGraphName+":"
		String/G imgWStr= "lineProfile2D"
		String/G imgWFullStr= imgDF+imgWStr
		
		// We don't actually need to run "makelineprofile()" because this is called when the cursors are generated above	
//		makelineprofile(graphName)
				
		// Make the graph window
		DoWindow/K $lineProfile2dGraphName
		Display/k=1/N=$lineProfile2dGraphName
		
		// Append the 2d line profile to the graph window and make it look nice
		AppendImage/W=$lineProfile2dGraphName lineProfile2D
		imgGraphPretty(lineProfile2dGraphName)
		imgScaleBar(lineProfile2dGraphName)
		changeColour(lineProfile2dGraphName,colour="BlueExp")
		
		// Move back to the WinGlobals data folder for the 3d data set
		SetDataFolder root:WinGlobals:$(GraphName)
	endif
	
		
	// Arrange graph windows on screen
	if (WaveExists(citsImgW)==1)
		AutoPositionWindow/E/m=0/R=$graphName $lineProfile2dGraphName
		AutoPositionWindow/E/m=1/R=$lineProfile2dGraphName $lineProfileGraphName
	else
		AutoPositionWindow/E/m=0/R=$GraphName $lineProfileGraphName
	endif
	 
	// Move back to the original data folder
	SetDataFolder saveDF

End


//--------------------------------------------------------------------------------------------------------------
// Called from "CursorMoved" and "lineProfile"
Function makeLineProfile(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
		
	// These global variables have been created and set already
	String/G imgWFullStr
	Wave imgW= $imgWFullStr 
	Wave lineprofx, lineprofy

	// this variable will be 0 if there are no NaNs or INFs in lineprofx and lineprofy
	Variable anyNaNs = numtype(lineprofx[0]) + numtype(lineprofy[0]) + numtype(lineprofx[1]) + numtype(lineprofy[1]) 

	// check if any of lineprof values are NaN or inf before calculating the lineprofile
	// this is necessary in case the user has killed and recreated the image window (in which case NaNs appear...)
	if ( anyNaNs != 0)  
		// do nothing
	else
		// Use inbuilt Igor routine to generate the line profile
		ImageLineProfile/SC xwave=lineprofx, ywave=lineprofy, srcwave=imgW

		// Copy the created wave to a new wave that will be used for plotting
		Duplicate/O W_ImageLineProfile lineProfile1D
		KillWaves/Z W_ImageLineProfile
	
		// Create a "distance" wave from the two x- and y- waves
		Duplicate/O W_LineProfileX lineProfileDistance
		Wave xline= W_LineProfileX
		Wave yline= W_LineProfileY
		Wave dline= lineProfileDistance
	
		// ensure xline and yline are always increasing positive
		if (xline(numpnts(xline)-1) - xline(0)<0)
			Reverse xline 
		endif
		if (yline(numpnts(yline)-1) - yline(0)<0)
			Reverse yline 
		endif
	
		// Set origin of x and y waves to zero then calculate the distance wave
		Variable xlinemin= WaveMin(xline)
		Variable ylinemin= WaveMin(yline)
		xline= xline - xlinemin
		yline= yline - ylinemin
		dline = Sqrt(xline^2 + yline^2)
	
		// Having calculated the distance wave we can delete the X and Y waves to make the data folder neater
		KillWaves/Z W_LineProfileX, W_LineProfileY
	
		// Give the line profile appropriate units (taken from image wave)
		String/G imgWXUnit= WaveUnits(imgW,0)
		String/G imgWYUnit= WaveUnits(imgW,1)
		String/G imgWDUnit= WaveUnits(imgW,-1)
		SetScale/I y, 0, 1, imgWDUnit,  lineProfile1D
		SetScale/I x, WaveMin(dline), WaveMax(dline), imgWXUnit,  lineProfile1D
		
		// Now that the 1d line profile has been generated, check whether this is a 3d data set (e.g., cits) and if so then
		// generate the 2d slice profile from it	
		if (WaveExists(citsImgW)==1)
	
			// Get the global string that tells us where the cits wave data is
			String/G citsWFullStr
		
			// Make the wave assignment to this data
			Wave citsW= $citsWFullStr
		
			// Use inbuilt Igor routine to generate the line profile
			ImageLineProfile/SC/P=-2 xwave=lineprofx, ywave=lineprofy, srcwave=citsW
		
			// Copy the created wave to a new wave that will be used for plotting - this wave is put in a separate data folder
			Duplicate/O M_ImageLineProfile root:WinGlobals:$(graphName+"_2dProfile"):lineProfile2D
//			KillWaves/Z M_ImageLineProfile, W_LineProfileX, W_LineProfileY

			// Move into 2d data slice DF
			SetDataFolder root:WinGlobals:$(graphName+"_2dProfile")
			
			// Give the 2d line profile appropriate units (taken from image wave)
			String/G citsWXUnit= WaveUnits(citsW,0)
			String/G citsWYUnit= WaveUnits(citsW,1)
			String/G citsWZUnit= WaveUnits(citsW,2)
			String/G citsWDUnit= WaveUnits(citsW,-1)

			// Determine image size for positioning the cursors
			Variable zMin= DimOffset(citsW,2)
			Variable zMax= (DimDelta(citsW,2) * DimSize(citsW,2) + DimOffset(citsW,2))
			SetScale/I x, WaveMin(dline), WaveMax(dline), citsWXUnit,  root:WinGlobals:$(graphName+"_2dProfile"):lineProfile2D
			SetScale/I y, zMin, zMax, citsWZUnit,  lineProfile2D
			SetScale/I d, 0, 1, citsWDUnit, lineProfile2D
			
			// Move back to 3d data DF
			SetDataFolder root:WinGlobals:$(graphName)
			
		endif		// end of 2d slice generation
			
	endif 	// end of "isNaN" checking

	// move back to original DF
	SetDataFolder saveDF
End




//--------------------------------------------------------------------------------------------------------------
// Update line profiles after manupulating data
Function updateLineProfile(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Check if there is an image line profile being displayed.  
	String/G lineProfileGraphName  // Load the name of the STS graph window from global variables
	String lineProfileGraphExists= WinList(lineProfileGraphName,"","WIN:1")  // check that the window (still) exists

	// Refresh graphs (if they exist)
	if ( strlen(lineProfileGraphExists)!=0 )
		doSomethingWithData("lineprofile")
	else
		KillStrings/Z lineProfileGraphName
	endif
	
	// Return to saved data folder
	SetDataFolder saveDF
	
End


//--------------------------------------------------------------------------------------------------------------
Function CursorDependencyForGraph(graphName)
	String graphName
	
	NewDataFolder/O root:WinGlobals
	NewDataFolder/O/S root:WinGlobals:$graphName
	String/G S_CursorAInfo, S_CursorBInfo, S_CursorCInfo
	Variable/G dependentA
	SetFormula dependentA, "CursorMovedForGraph(S_CursorAInfo, 0)"
	Variable/G dependentB
	SetFormula dependentB,"CursorMovedForGraph(S_CursorBInfo, 1)"
	Variable/G dependentC
	SetFormula dependentC,"CursorMovedForGraph(S_CursorCInfo, 2)"
End


//--------------------------------------------------------------------------------------------------------------
Function CursorMovedForGraph(info, cursNum)
	String info
	Variable cursNum // 0 if A cursor, 1 if B cursor, 2 if C cursor
	
	Variable result= NaN // error result
	
	// Check that the top graph is the one in the info string.
	String topGraph= WinName(0,1)
	String graphName= StringByKey("GRAPH", info)
	
	String df= GetDataFolder(1);
	SetDataFolder root:WinGlobals:$graphName

	if( CmpStr(graphName, topGraph) == 0 )
		String tName= StringByKey("TNAME", info)
		String xPtStr= StringByKey("POINT", info)
		String yPtStr= StringByKey("YPOINT", info)
		Variable/G xPt= str2num(xPtStr)
		Variable/G yPt= str2num(yPtStr)	
		
		Wave lineprofx, lineprofy
		// If the cursor is off the trace name will be zero length so do nothing
		if( strlen(tName) ) // cursor still on
			
			Variable xVal, yVal
			switch ( cursNum )
			
				case 0:
					xVal= hcsr(A)
					yVal= vcsr(A)
					Variable/G xA= xVal
					Variable/G yA= yVal
					lineprofx[0]=xA
					lineprofy[0]=yA
					// update line profile
					makeLineProfile(graphName) 
					break
					
				case 1:
					xVal= hcsr(B)
					yVal= vcsr(B)
					Variable/G xB= xVal
					Variable/G yB= yVal
					lineprofx[1]=xB
					lineprofy[1]=yB
					// update line profile
					makeLineProfile(graphName) 
					break 
				
				case 2:
					
					String/G citsWFullStr
						
					// Get STS and CITS waves
					Wave stsW
					Wave citsW= $citsWFullStr
						
					// Get STS wave from the 3d data set at the appropriate point
					stsW[]=citsW[xPt][yPt][p]
					break
			endswitch
		endif
	endif
	SetDataFolder df
	return result
End

//--------------------------------------------------------------------------------------------------------------
Function VariablesForProgramControl()
	
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	NewDataFolder/O root:WinGlobals
	NewDataFolder/O/S root:WinGlobals:srsstm_ControlVariables
	
	// Create a global string that can be set to "yes" if the user wants to load all their data into a single data folder
	// e.g., if they are loading multiple STS measurements taken at the same point.
	String/G commonDataFolder
	if (strlen(commonDataFolder)==0)
		commonDataFolder = "no"
	endif
	
	String/G defaultBackground
	if (strlen(defaultBackground)==0)
		defaultBackground = "none"
	endif

	SetDataFolder saveDF
End

//--------------------------------------------------------------------------------------------------------------
// PLANE SUBTRACT
Function subtractPlane(graphname,[ROI])
	String graphname, ROI 
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	
	// Create name of ROI wave
	String imgWROIStr= graphName+"_ROI_W"
	
	if ( ParamIsDefault(ROI) )  // plane subtract the entire image
	
		// Create a Region of Interest (ROI) wave that covers the entire image
		Duplicate/O imgW, $imgWROIStr
		Wave imgWROI= $imgWROIStr
		imgWROI=1
	else
		if ( cmpstr(ROI,"yes")==0 )  // plane subtract using ROI wave
		
			// Drawing tools
			SetDrawLayer/W=$graphName ProgFront
				
			ImageGenerateROIMask/W=$graphName $imgWStr
			
			if ( WaveExists(imgWROI)==0 )
			
				Duplicate/O M_ROIMask $imgWROIStr
				KillWaves/Z M_ROIMask
			
				Wave imgWROI= $imgWROIStr
				
			endif 
			
			// Drawing tools
			SetDrawLayer/W=$graphName UserFront
			
			// Drawing tools
			HideTools/W=$graphName 
			
		endif 
	endif
	
	
	if ( WaveExists(imgWROI)!=0 )  // Don't do anything unless a ROI exists (either for the entire image or a user drawn ROI)
	
		Redimension/B/U imgWROI 			

		// Use in-built Igor function for plane removal
		ImageRemoveBackground /O/R=imgWROI/P=1 imgW
	else
		Print "Warning: no background substraction performed.  Missing ROI wave?"
	
	endif 
	
	// Clean up
	KillWaves/Z imgWROI
	
	// Return to saved data folder
	SetDataFolder saveDF
End



//--------------------------------------------------------------------------------------------------------------
// zero
Function subtractMin(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	
	Variable minVal= WaveMin(imgW)
	
	imgW= imgW - minVal

	// Return to saved data folder
	SetDataFolder saveDF
End

	
//--------------------------------------------------------------------------------------------------------------
// LINEWISE BACKGROUND SUBTRACT
Function subtractLinewise(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr

	Variable xPts = DimSize(imgW,0)
	Variable yPts = DimSize(imgW,1)
	
	KillWaves/Z lineWave
	Make/O/N=(xPts) lineWave
	Duplicate/O lineWave, linefitWave
	
	Variable i=0
	for (i=0; i<yPts; i+=1)
		lineWave  = imgW[p][i]
		CurveFit/N/Q/NTHR=0 line  lineWave /D=linefitWave
		lineWave=lineWave - linefitWave
		imgW[][i] = lineWave[p]
	endfor

	// Clean up
	KillWaves/Z lineWave, linefitWave, W_coef, W_sigma
	
	// Return to saved data folder
	SetDataFolder saveDF
End


//--------------------------------------------------------------------------------------------------------------
Function dispSTSfromCITS(graphname,)
	String graphname
	
	// Get current data folder
	DFREF saveDFSTSfromCITS = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
//	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	String/G citsDF
	String/G citsWStr
	String/G citsWFullStr
//	String/G citsImgW
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	Wave citsW= $citsWFullStr

	// Determine image size for positioning the cursors and for dimensionaing the STS wave
	Variable xMin= DimOffset(imgW,0)
	Variable xMax= (DimDelta(imgW,0) * DimSize(imgW,0) + DimOffset(imgW,0))
	Variable yMin= DimOffset(imgW,1)
	Variable yMax= (DimDelta(imgW,1) * DimSize(citsW,1) + DimOffset(imgW,1))
	Variable zMin= DimOffset(citsW,2)
	Variable zMax= (DimDelta(citsW,2) * DimSize(citsW,2) + DimOffset(citsW,2))
	Variable xRange = xMax - xMin
	Variable yRange = yMax - yMin
	
	// Calculate cursor position
	Variable cursX= xMin + (0.5 * xRange)
	Variable cursY= yMin + (0.5 * yRange)
	
	// Place the Cursor on Image (unless it is already there)
	if (strlen(CsrInfo(C))==0)
		Cursor/I/s=2/c=(65535,65535,65535) C, $imgWStr, cursX, cursY
	endif 
	
	// Create a new graph to display the STS
	String/G STSgraphname= graphName+"_STS"
	DoWindow/K $STSgraphname

	// Create a new blank graph window
	Display/k=1/N=$STSgraphname 
	AutoPositionWindow/E/m=1
	
	// Load the size of the lineProfile2dGraphName dimension (this was computed and saved as a global variable in the image display function)
	Variable/G zSize
	
	//Make a new wave to store a single STS curve in
	Make/O/N=(zSize) stsW
	
	// Load the cursor x and y position from already saved global variables
	Variable/G xPt
	Variable/G yPt
	
	// Get STS wave from the 3d data set at the appropriate point
	stsW[]=citsW[xPt][yPt][p]

	// Give the line profile appropriate units.  These units were saved in global variables in the image display function
	String/G citsWZUnit   //= WaveUnits(citsW,2)
	String/G citsWDUnit   //= WaveUnits(citsW,-1)

	SetScale/I x, zMin, zMax, citsWZUnit, stsW
	SetScale/I d, 0, 1, citsWDUnit, stsW

	AppendToGraph stsW
	
	// Return to saved data folder
	SetDataFolder saveDFSTSfromCITS
End




//--------------------------------------------------------------------------------------------------------------
// Create a backup wave in new data folder
Function backupData(graphname,suffixStr)
	String graphname, suffixStr
	
	// Get current data folder
	DFREF saveDFbackup = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName 
	
	// Check that the image displayed has an associated 3d dataset.  The image must have been displayed with the SRS macros that generate the appropriate global variables
	//If it does then we will save the 3d wave, rather than the 2d wave. 
	if (WaveExists(citsImgW)==1)  // 3d data
	
		// Get the global variable for the 3d wave
		String/G citsDF		// data folder plus wave name
		String/G citsWStr
		String/G citsWFullStr		// data folder plus wave name

		String/G databackupDF = citsDF+PossiblyQuoteName(citsWStr)
		NewDataFolder/O $databackupDF
		String/G backupDataStr= databackupDF+":"+PossiblyQuoteName(citsWStr)
		Duplicate/O $citsWFullStr $backupDataStr	
		
		String newcitsWStr = citsWStr+suffixStr
		SetDataFolder $citsDF
		KillWaves/Z 	$newcitsWStr
		Rename $citsWFullStr, $newcitsWStr
		
		// Update global variables
		citsWStr= newcitsWStr
		citsWFullStr= citsDF+PossiblyQuoteName(citsWStr)
		
	else // 2d data
		
		// Get the global variable for this graph (these were set in the manipulateData procedure)
		String/G imgDF		// data folder plus wave name
		String/G imgWStr
		String/G imgWFullStr		// data folder plus wave name
		
		String/G databackupDF = imgDF+PossiblyQuoteName(imgWStr)
		NewDataFolder/O $databackupDF
		String/G backupDataStr= databackupDF+":"+PossiblyQuoteName(imgWStr)
		Duplicate/O $imgWFullStr $backupDataStr
		
		String newimgWStr = imgWStr+suffixStr
		SetDataFolder $imgDF
		KillWaves/Z 	$newimgWStr
		Rename $imgWFullStr, $newimgWStr
		
		// Update global variables
		imgWStr= newimgWStr
		imgWFullStr= imgDF+PossiblyQuoteName(imgWStr)
		
	endif
	
	SetDataFolder saveDFbackup

End
	



//--------------------------------------------------------------------------------------------------------------
// Differentiate a 3d data set with respect to its z coordinate
Function manipulateCITS(graphname,action)
	String graphname, action
	// action= "differentiate"
	// action= "smoothZ"
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName 
	
	// Check that the image displayed has an associated 3d dataset.  The image must have been displayed with the SRS macros that generate the appropriate global variables
	//If it does then we will save the 3d wave, rather than the 2d wave. 
	if (WaveExists(citsImgW)==1)  // 3d data
		
		// Load the global variables 
		String/G citsDF
		String/G citsWStr
		String/G citsWFullStr
		
		// make wave assignment to the 3d data set
		Wave citsW = $citsWFullStr
		
		strswitch ( action )
			case "differentiate":
			
				// Use in built Igor routine to differentiate the 3d data set with respect to its z axis
				Differentiate/DIM=2 citsW
		
				// Give the line profile appropriate units (taken from image wave)
				String/G waveDUnit= WaveUnits(citsW,-1)
				if (cmpstr(waveDUnit,"A")==0)
					// original data in A, so differentiated data in S
					SetScale/I d, 0, 1, "S",  citsW
				else
					Print "Warning: Do not know what units to assign to differentiated data"
					SetScale/I d, 0, 1, "",  citsW
				endif
				
				// Refresh 3D data windows
				refresh3dData(graphName)
				break
				
			case "smoothZ":
			
				// Prompt user for smoothing factor
				Variable smthfactor=50
				Prompt smthfactor, "Enter smoothing factor: " 
				DoPrompt "Smoothing factor", smthfactor
				if (V_Flag)
 					Print "Warning: User cancelled 'smooth CITS'"                          // User canceled
  				else			 			
					Smooth/DIM=2/E=0 smthfactor, citsW
				endif
				
				// Refresh 3D data windows
				refresh3dData(graphName)
				
				break
				
			case "extractImages":
				
				// get x and y pixel sizes
				Variable/G xSize
				Variable/G ySize
				
				// get number of slices
				Variable/G zSize
				
				// get currently displayed slice number
				Variable/G citsZvar
				
				// make a new data folder if it doesn't already exist and move there
				NewDataFolder/O root:CITSImageSlices
				SetDataFolder root:CITSImageSlices
				
				Variable i = 0
				
				for (i=0; i<zSize; i+=1)
					// make image name
					String CITSimageName = citsWStr+"-"+num2str(i)
					
					Make/O/N=(xSize,ySize) $CITSimageName
					Wave myImage = $CITSimageName
					myImage[][] = citsW[p][q][i]
				
				endfor
				
				// move back to image info DF
				SetDataFolder root:WinGlobals:$graphName 
				
// SHOULD ADD units and dimensions here *************

				
				
				break
			case "extractImage":
				
				// get x and y pixel sizes
				Variable/G xSize
				Variable/G ySize
				
				// get number of slices
				Variable/G zSize
				
				// get currently displayed slice number
				Variable/G citsZvar
				
				// make a new data folder if it doesn't already exist and move there
				NewDataFolder/O root:CITSImageSlices
				SetDataFolder root:CITSImageSlices
				
				// make image name
				String CITSimgName = citsWStr+"-"+num2str(citsZvar)
					
				Make/O/N=(xSize,ySize) $CITSimgName
				Wave myImage = $CITSimgName
				myImage[][] = citsW[p][q][citsZvar]
				
				
				// move back to image info DF
				SetDataFolder root:WinGlobals:$graphName 
				
// SHOULD ADD units and dimensions here *************

				
				
				break
				
			default:
				Print "Don't know what you want to do with this data"
				break
		endswitch
			
	else // 2d data
		Print "Error: this is not a 3d data set, or it was not displayed using the img3dDisplay(imgWStr) function of the SRS-STM macros"
	endif
	
	
	// Return to original data folder
	SetDataFolder saveDF

End


//-----------------------------------------
Function refresh3dData(graphName)
	String graphName
		
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName 
		
	// Load the global variables 
	String/G citsDF
	String/G citsWStr
	
	// Check if there is point spectra being displayed.  
	String/G STSgraphname  // Load the name of the STS graph window from global variables
	String STSpointGraphExists= WinList(STSgraphname,"","WIN:1")  // check that the window (still) exists

	// Check if there is point spectra being displayed.  
	String/G lineProfileGraphName
	String lineProfileGraphExists= WinList(lineProfileGraphName,"","WIN:1")  // check that the window (still) exists

	// Kill the window that has the original data and the display the differentiated data
	KillWindow $graphName
	SetDataFolder citsDF
	img3dDisplay(citsWStr)
	
	if ( strlen(lineProfileGraphExists)!=0)
		DoWindow/F $graphName //bring the graph containing the data to the front
		lineProfile(graphName)
	endif
	
	// Refresh point spectra graph (if it exists)
	if ( strlen(STSpointGraphExists)!=0 )
		DoWindow/F $graphName //bring the graph containing the data to the front
		dispSTSfromCITS(graphName)
	endif
	
	// Refresh line profile graph (if it exists)
	

	
	// Return to saved DF
	SetDataFolder saveDF
	
End


//-----------------------------------------------------------
// matrix convolution for 2d or 3d data
Function matrixConvolveData(graphName)
	String graphName

	// If graphName not given (i.e., ""), then get name of the top graph window
	if ( strlen(graphName)==0 )
	
			graphName= WinName(0,1)
	endif
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save DF
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName
		
	// Get information about the image wave
	String/G imgWStr
	String/G imgDF
	String/G imgWFullStr
	
	// create a variable for the dimensions of the data
	Variable dim=-1
	
	// Check that the image displayed has an associated 3d dataset.  The image must have been displayed with the SRS macros that generate the appropriate global variables
	//If it does then we will work with a 3d wave, otherwise 2d 
	if (WaveExists(citsImgW)==1)  // 3d data
		
		// Load the global variables 
		String/G citsDF
		String/G citsWStr
		String/G citsWFullStr
		
		// make wave assignment to the 3d data set
		Wave dataW = $citsWFullStr
		
		// set the dimension variable
		dim=3
	
	else // 2d wave

		// make wave assignment to the 2d image wave
		Wave dataW = $imgWFullStr	
			
		// set the dimension variable
		dim=2
		
	endif
	
	// Make the kernel for the manipulation
	makeKernel(graphName,dim)
	
	// Convert the data to single precision floating point
	Redimension/S dataW // to avoid integer truncation
	
	// Use built in Igor function for matric convolution
	MatrixConvolve sKernel dataW  // creates new wave M_Convolution
	Wave convolvedW= M_Convolution

	if (WaveExists(citsImgW)==1)  // 3d data
	
		// copy the data to the appropriate place
		dataW= convolvedW
		KillWaves/Z M_Convolution
		// refresh the data displays
		refresh3dData(graphName)
	
	else
		// probably need to refresh 2d data
		
	endif
	

	
	// return to DF	
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------------------------------------
Function makeKernel(graphName,dim)
	String graphName
	Variable dim
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save DF
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName
	
				
	// Prompt user for smoothing factor
	Variable kernelSize=5
	Prompt kernelSize, "Please enter side length, n, of the (nxn) kernel: " 
		
	String kernelName
	Prompt kernelName,"Kernel type",popup,TraceNameList("",";",1) 
	Prompt kernelName,"Kernel type: ",popup,"sinc; none"
	DoPrompt "Make kernel", kernelSize, kernelName
	
	if (V_Flag) // User canceled
		
		Print "Warning: User cancelled"         
		kernelName= "none"
	
	endif			
		
	if (dim==3) // 3d wave
		
		Make/O/N=(kernelSize,kernelSize,kernelSize) sKernel // first create the convolution kernel 
		SetScale/I x -5,5,"", sKernel
		SetScale/I y -5,5,"", sKernel 	// Equivalent to rect(2*fx)*rect(2*fy) in the spatial frequency domain. 
		SetScale/I z -5,5,"", sKernel

		strswitch( kernelName )
		
			case "sinc":
			
				sKernel=sinc(x/2)*sinc(y/2)*sinc(z/2)
				break
			
			default:  //unitary		
			
				Make/O/N=(1,1,1) sKernel //  create a unitary kernel (2d)
				sKernel=1
				break

		endswitch
		
	else // 2d wave
	
		Make/O/N=(kernelSize,kernelSize) sKernel // first create the convolution kernel 
		SetScale/I x -5,5,"", sKernel
		SetScale/I y -5,5,"", sKernel 	// Equivalent to rect(2*fx)*rect(2*fy) in the spatial frequency domain. 

		strswitch( kernelName )
		
			case "sinc":
			
				sKernel=sinc(x/2)*sinc(y/2)
				break
			
			default:  //unitary		
			
				Make/O/N=(1,1) sKernel //  create a unitary kernel (2d)
				sKernel=1
				break
				
		endswitch
	endif
				
	// Normalise the kernel
	Variable normalisation= Sum(sKernel)
	sKernel= sKernel/normalisation

	// Return to original DF
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------
// currently only JPEG images are fully supported
//------------------------------------------------------------------------------------------------------------
Function quickSaveImage([symbolicPath,imageType])
	String symbolicPath,imageType
	
	// Get name of top graph
	String graphName= WinName(0,1)
	
	// if imageType not given then set it to "JPEG"
	if ( ParamIsDefault(imageType) )
		imageType="JPEG"
	endif

	// if symbolicPath not given then set it to "SRSDesktop".  This symbolic path is created in SRSSTM2012.ipf
	if ( ParamIsDefault(symbolicPath) )
		symbolicPath="UserDesktop"
	endif
	
	
	// Create String variables for use later on
	String fileExt= ".default"
	String imageFileName= "defaultImageName"
	String imageDataOnly= "no"
	
	strswitch (imageType)
		case "JPEG":
			fileExt=".jpg"
			break
		
		case "TIFF":
			fileExt=".tif"
			imageDataOnly= "yes"
			break
			
	endswitch
	
	Variable i
	for (i=0;i<999;i+=1)
	
		// Attempt to open image to find out if it already exists
		imageFileName= graphName+"_"+num2str(i)+fileExt
		ImageLoad /Q/O /Z /T=any /P=$symbolicPath imageFileName

		if ( V_Flag )
			// Clean up
			KillWaves/Z $imageFileName
		else
			strswitch ( imageDataOnly )
				case "no":
					SavePICT /Z /Q=1 /P=$symbolicPath /T=imageType /B=144 as imageFileName
					break
				
				case "yes":
					
					// Get current data folder
					DFREF saveDF = GetDataFolderDFR()	  // Save
	
					// Move to the created data folder for the graph window
					SetDataFolder root:WinGlobals:$graphName
					
					// get image wave name (includ. full DF path)
					String/G imgWFullStr		// data folder plus wave name
					
					// Duplicate image wave
					Duplicate/O $imgWFullStr imgWforTIFFOutput
					
					Resample/DIM=0/UP=2 imgWforTIFFOutput
					Resample/DIM=1/UP=2 imgWforTIFFOutput
					
					//ImageTransform /C=root:WinGlobals:$(graphName):ctab fliprows imgWforTIFFOutput					
					//ImageTransform /O /C=root:WinGlobals:$(graphName):ctab flipcols imgWforTIFFOutput
					ImageTransform /C=root:WinGlobals:$(graphName):ctab cmap2rgb imgWforTIFFOutput
					ImageRotate/O/V M_RGBOut
					ImageSave/IGOR/O/D=32/T="TIFF"/P=$symbolicPath /Q=1 M_RGBOut as imageFileName
					
//					KillWaves/Z imgWforTIFFOutput, M_RGBOut
					// return to DF
					SetDataFolder saveDF		
					
					break 
					
				default:
					Print "Sorry, something went wrong with image save"
					break
			endswitch
			
			break  // this breaks out of the for loop
		endif
	endfor 
End


//------------------------------------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------------------------------------
Function quickScript(scriptType)
	String scriptType
		
		strswitch( scriptType )
			case "CITSstandard":
				displayData()
				doSomethingWithData("differentiateCITS")
				doSomethingWithData("smoothZ")
				doSomethingWithData("mConvolution")
				//doSomethingWithData("STSfromCITS")
				doSomethingWithData("lineprofile")
				break				
			case "STSstandard":
				// Get current data folder
				DFREF saveDF = GetDataFolderDFR()	  // Save DF
				// display all STS
				display1DWaves("all")
				// average
				DoSomethingToAllTracesInGraph("",type="average")
				// differentiate
				DoSomethingToAllTracesInGraph("",type="differentiate")
				// smooth
				DoSomethingToAllTracesInGraph("",type="smooth-B")
				break
		endswitch
End



//--------------------------------------------------------------------------------------------------------------
// 
Function createROI(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data.  This can be either a 2d, or 3d data wave
	Wave imgW= $imgWFullStr
	
	// Drawing tools
	SetDrawLayer/W=$graphName ProgFront

	ShowTools/W=$graphName /A rect
End


//--------------------------------------------------------------------------------------------------------------
// 
Function killROI(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data.  This can be either a 2d, or 3d data wave
	Wave imgW= $imgWFullStr
	
	// Drawing tools
	SetDrawLayer/W=$graphName ProgFront
	
	// 100% solid pattern
	SetDrawEnv/W=$graphName fillpat=1
	SetDrawEnv/W=$graphName save
	
	// Kill everything in ProgFront layer
	DrawAction /W=$graphName delete
	
	// Hide tools palete
	HideTools/W=$graphName /A 
	
	// Drawing tools
	SetDrawLayer/W=$graphName UserFront
	
End


//--------------------------------------------------------------------------------------------------------------
Function imageArithmetic(graphname)
	String graphname
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	String imgDF = GetDataFolder(1)  // This is the DF that holds the wave data

	// List (2D) waves in current data folder
	String wList =  WaveList("*",";","DIMS:2") 
	Variable wNum = ItemsInList(wList)
	
	if (wNum>1)  // check that at least two 2D
	
		String imgWStr
	
		imgWStr= imgChooseDialog(wList,wNum)  // returns the image name, or "none" if user cancels


//			imgWStr= StringFromList(0,wList,";")  // if there is only one image file don't bother asking the user

		
//		if (cmpstr(imgWStr,"none") != 0)  // check user did not cancel
//			String imgWFullStr= imgDF+PossiblyQuoteName(imgWStr)
//	
//			// Create Wave assignment for image
//			Wave imgW= $imgWFullStr//

			// Display the data
//			if (WaveDims(imgW)<3)
				// if a 2D wave then do the following
//				imgDisplay(imgWStr)
//			else
				// if a 3D wave then do the following
//				img3dDisplay(imgWStr)
//			endif
//		else  // user cancelled
//			Print "Image display cancelled by user" 
//		endif
	else
		Print "Error: there are less than two image waves in this data folder"
	endif
		
	 
	// Move back to the original data folder
	SetDataFolder saveDF
End