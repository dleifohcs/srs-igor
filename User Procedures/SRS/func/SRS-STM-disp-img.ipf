//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-STM-disp-img.ipf
//
// A collection of functions for displaying 2D and 3D data sets.  This was primarily coded with 
// scanning tunnelling microscopy (STM) and current imaging tunnelling spectroscopy (CITS) data sets
// in mind.
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
// Function displayData()
// Function/S imgChooseDialog(wList,wNum)
// Function imgDisplay(imgWStr)
// Function img3dDisplay(imgWStr)
// Function imgGraphPretty(graphName)
// Function imgScaleBar(graphName)
// Function imgAddInfo(graphName)
// Function img3DInfoPanel(graphName)
// Function citsZPanelUpdate(ctrlName,varNum,varStr,varName) : SetVariableControl 
//
//------------------------------------------------------------------------------------------------------------------------------------
// Above is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------
// This function looks for 2D or 3D data waves in the current data folder and attempts to display them
Function displayData()

	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	String imgDF = GetDataFolder(1)  // This is the DF that holds the wave data

	// List (2D) waves in current data folder
	String w2dList =  WaveList("*",";","DIMS:2") 
	Variable w2dNum = ItemsInList(w2dList)

	// List (3D) waves in current data folder
	String w3dList =  WaveList("*",";","DIMS:3") 
	Variable w3dNum = ItemsInList(w3dList)

	// Join 2D and 3D wave lists
	String wList = w2dList+w3dList 
	Variable wNum = w2dNum + w3dNum
	
	if (wNum!=0)  // check that at least one 2D or 3D data set exists 
	
		String imgWStr
	
		// Ask user which image they want to work with if there is more than one wave in the data folder
		// otherwise choose the single wave as the one to use	
		if (wNum>1)
			imgWStr= imgChooseDialog(wList,wNum)  // returns the image name, or "none" if user cancels
		else
			imgWStr= StringFromList(0,wList,";")  // if there is only one image file don't bother asking the user
		endif
		
		if (cmpstr(imgWStr,"none") != 0)  // check user did not cancel before proceeding
			String imgWFullStr= imgDF+PossiblyQuoteName(imgWStr)
	
			// Create Wave assignment for image
			Wave imgW= $imgWFullStr

			// Display the data
			if (WaveDims(imgW)<3)
				// if a 2D wave then do the following
				imgDisplay(imgWStr)
			else
				// if a 3D wave then do the following
				img3dDisplay(imgWStr)
			endif
		else  // user cancelled
			Print "Image display cancelled by user" 
		endif
	else
		Print "Error: no 2D or 3D image data found in the current data folder"
	endif
		
	// Return to original data folder
	SetDataFolder saveDF	
End



//-----------------------------------------------------------------
// This function looks for 2D or 3D data waves in the current data folder and attempts to display them (all)
Function displayAllData([autoBG])
	String autoBG
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	String imgDF = GetDataFolder(1)  // This is the DF that holds the wave data

	// List (2D) waves in current data folder
	String w2dList =  WaveList("*",";","DIMS:2") 
	Variable w2dNum = ItemsInList(w2dList)

	// List (3D) waves in current data folder
	String w3dList =  WaveList("*",";","DIMS:3") 
	Variable w3dNum = ItemsInList(w3dList)

	// Join 2D and 3D wave lists
	String wList = w2dList+w3dList 
	Variable wNum = w2dNum + w3dNum
	
	if (wNum!=0)  // check that at least one 2D or 3D data set exists 
	
		String imgWStr
		Variable i
	
		// display all 2D and 3D waves in folder 		
		for (i=0; i<wNum; i+=1)
		
			imgWStr= StringFromList(i,wList,";") 
			
			String imgWFullStr= imgDF+PossiblyQuoteName(imgWStr)
	
			// Create Wave assignment for image
			Wave imgW= $imgWFullStr

			// Display the data
			if (WaveDims(imgW)<3)
				// if a 2D wave then do the following
				imgDisplay(imgWStr)
				
				if ( ParamIsDefault(autoBG) )
					// do nothing
				else
					// automatic background subtraction
					if ( cmpstr(autoBG,"linewise")==0 )
						doSomethingWithData("subtractlinewise")
					elseif (cmpstr(autoBG,"plane")==0 )
						doSomethingWithData("subtractplane")
					endif
				endif
			else
				// if a 3D wave then do the following
				img3dDisplay(imgWStr)
			endif
		endfor
	else
		Print "Error: no 2D or 3D image data found in the current data folder"
	endif
		
	// Return to original data folder
	SetDataFolder saveDF	
End


//-----------------------------------------------------------------
// This function creates a pop-up window requesting the user to choose an image
// from the list of images or 3D data sets in the current data folder
Function/S imgChooseDialog(wList,wNum)
	String wList
	Variable wNum

	String wName
	Prompt wName,"Which image would you like to display?", popup, wList 
	DoPrompt "Image display",wName
   	if( V_Flag )
      	return "none"          // user canceled
   	endif
	return wName
End


//-----------------------------------------------------------------
// Displays 2D (image) data
Function imgDisplay(imgWStr)
	String imgWStr
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	String imgDF = GetDataFolder(1)  // This is the DF that holds the 2D image wave data

	// Make wave assignment to the image wave data
	Wave imgW= $imgWStr
	
	// Create a new blank graph window
	Display/k=1/N=IMG
	
	// Show image in the display window
	AppendImage imgW
	
	// Get the name of the graph window
	String graphName= WinName(0,1)
	
// HACK (?)
// Think we should delete the folder root:WinGlobals:graphName if it exists at this point.
// This is because I think it should not have been created yet.  So if it exists it is due to a 
// previous image display.  This can cause problems if e.g., a ctab file does not exist in that
// folder.  Thus I have added this to kill the DF if it exists.  If will be recreated during the
// "makeImgPretty" routine below
	// 
	SetDataFolder root:WinGlobals
	if ( DataFolderExists(graphName) )
		Print "Warning: root:WinGlobals:"+graphName+" already exists.  Deleting"
		KillDataFolder $graphName
	endif
	SetDataFolder saveDF
	
	// Adjust graph size etc.
	doSomethingWithData("makeImgPretty")
	
	// Autoposition window
	AutoPositionWindow/E
	
	// Return to starting data folder
	SetDataFolder saveDF
End



//---------------------------------------
// Display 3D data - e.g., CITS
Function img3dDisplay(imgWStr)
	String imgWStr
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	String imgDF = GetDataFolder(1)
	
	// Create a new blank graph window
	Display/k=1/N=CITS
	
	// Get the name of the new graph window
	String graphName= WinName(0,1)
	
	// HACK (?)
// Think we should delete the folder root:WinGlobals:graphName if it exists at this point.
// This is because I think it should not have been created yet.  So if it exists it is due to a 
// previous image display.  This can cause problems if e.g., a ctab file does not exist in that
// folder.  Thus I have added this to kill the DF if it exists.  If will be recreated during the
// "makeImgPretty" routine below
	// 
	SetDataFolder root:WinGlobals
	if ( DataFolderExists(graphName) )
		KillDataFolder/Z $graphName
		If (V_flag)
			Print "Warning: root:WinGlobals:"+graphName+" already exists and cannot delete.  This may cause problems."
		endif
	endif
	SetDataFolder saveDF
	// HACK
	
	// Create WinGlobals etc. if they are not already created
	GlobalsForGraph(graphName)
	
	// Change data folder to the folder containing the global variables for the image graph
	SetDataFolder root:WinGlobals:$graphName
	
	// Create global variables for wave and data folder
	String/G citsWStr= imgWStr
	String/G citsDF= imgDF
	String/G citsWFullStr= citsDF+PossiblyQuoteName(citsWStr)

	// Create wave assignment for 3d cits wave
	Wave citsW = $citsWFullStr
	
	// Find number of points in each of the three dimensions
	Variable/G xSize= DimSize(citsW,0)
	Variable/G ySize= DimSize(citsW,1)
	Variable/G zSize= DimSize(citsW,2)

	// Get min/max x, y and z values
	Variable xMin = DimOffset(citsW,0)
	Variable xMax = DimDelta(citsW,0) * DimSize(citsW,0) + DimOffset(citsW,0)
	Variable yMin = DimOffset(citsW,1)
	Variable yMax = DimDelta(citsW,1) * DimSize(citsW,1) + DimOffset(citsW,1)

	// Get min and delta values for z	
	Variable/G biasOffset= DimOffset(citsW,2)
	Variable/G biasDelta= DimDelta(citsW,2)	

	// Create global variable for the z slice to display, and the associated bias
	Variable/G citsZVar=0
	Variable/G citsBiasZVar=biasOffset
	
	// Get the units of the 3d wave.  For typical CITS the four values are "m", "m", "V", "A"
	String/G citsWXUnit= WaveUnits(citsW,0)
	String/G citsWYUnit= WaveUnits(citsW,1)
	String/G citsWZUnit= WaveUnits(citsW,2)
	String/G citsWDUnit= WaveUnits(citsW,-1)	
		
	// Create a 2D image wave to hold image data for particular z value 
	Make/N=(xSize,ySize) tempW
	Duplicate/O tempW, citsImgW
	KillWaves/Z tempW
	
	// Set the image to be the z=0 slice of the 3d data set
	citsImgW[][]= citsW[p][q][0]
	
	// Apply units and dimensions of the 3d wave to the extracted 2d wave
	SetScale/I x, xMin, xMax, citsWXUnit,  citsImgW
	SetScale/I y, yMin, yMax, citsWYUnit,  citsImgW
	SetScale/I d, 0, 1, citsWDUnit,  citsImgW
	
	// Show image in the display window
	AppendImage citsImgW
		
	// Adjust graph size etc.
	doSomethingWithData("make3DImgPretty")
		
	// Return to starting data folder
	SetDataFolder saveDF
End



//----------------------
// This adjusts the graph window for an image to make it look nice
Function imgGraphPretty(graphName)
	String graphName

	// If graphName not given (i.e., ""), then get name of the top graph window
	if ( strlen(graphName)==0 )
			graphName= WinName(0,1)
	endif
	
	// Modify image size
	ModifyGraph/W=$graphName  width=200
	//DoUpdate // this resizes the graph window.  The following line make the graph resizable again.
	ModifyGraph/W=$graphName  height={Aspect,1}
	ModifyGraph/W=$graphName  fSize=9,font="Arial"
	ModifyGraph/W=$graphName  axThick=0.8
	ModifyGraph/W=$graphName  standoff=0
	DoUpdate
	ModifyGraph/W=$graphName width=0,height={Aspect,1}
	DoUpdate	
End


//------------------------------------------------
// Creates a z-scale bar and displays to the right of the image
Function imgScaleBar(graphName)
	String graphName
	
	// If graphName not given (i.e., ""), then get name of the top graph window
	// if there is no graph window then this function will produce an erro
	if ( strlen(graphName)==0 )
	
			graphName= WinName(0,1)
	endif
	
	// Get name of the image Wave
	String wnameList = ImageNameList("", ";")
	String imgWStr = StringFromList(0, wnameList)
	
	// Graph size information
	GetWindow $graphName, gsize
	Variable graphLeft = V_left
	Variable graphRight = V_right
	Variable graphWidth = graphRight-graphLeft
//	Variable graphTop = V_top
//	Variable graphBottom = V_bottom
//	Variable graphHeight = graphBottom - graphTop
	
	// Image size information
	GetWindow $graphName, psize
	Variable imgLeft = V_left
	Variable imgRight = V_right
	Variable imgWidth = imgRight-imgLeft
//	Variable imgTop = V_top
//	Variable imgBottom = V_bottom
//	Variable imgHeight = imgBottom - imgTop
	
	// Make z-scale bar size
//	Variable barLeftpct = 100 * imgLeft/graphWidth
//	Variable barToppct = 100 * imgTop/graphHeight	
	Variable barWidth = 0.05 *imgWidth 
	Variable marginr = 0.3 * imgWidth
	
	// Adds blank margin space to the right of the image in order to leave space for the z-scale
	// The z-scale bar will be created at 0.3 of the width of the image as it is displayed when this function is called
	ModifyGraph/W=$graphName width=imgWidth, margin(right)=marginr
	
	// Creates the z-scale
	ColorScale/W=$graphName/C/Z=1/N=text0/F=0/A=LT/X=102/Y=0 image=$imgWStr, width=barWidth
	ColorScale/C/N=text0 "\Z09\\U"
	ColorScale/C/N=text0 font="Arial",fsize=09
	DoUpdate
End


//------------------------------------------------
// Creates information panel on image
Function imgAddInfo(graphName)
	String graphName
	
	// If graphName not given (i.e., ""), then get name of the top graph window
	// if there is no graph window then this function will produce an erro
	if ( strlen(graphName)==0 )
			graphName= WinName(0,1)
	endif
	
	// Get name of the image Wave
	String wnameList = ImageNameList("", ";")
	String imgWStr = StringFromList(0, wnameList)
	
	// Graph size information
	GetWindow $graphName, gsize
	Variable graphLeft = V_left
	Variable graphRight = V_right
	Variable graphWidth = graphRight-graphLeft
	
	// Image size information
	GetWindow $graphName, psize
	Variable imgLeft = V_left
	Variable imgRight = V_right
	Variable imgWidth = imgRight-imgLeft

	// The graph is widened in the function that puts the z-scale on; however if you want to adjust again can use this	
	// Adds blank margin space to the right of the image in order to leave space for the z-scale
	// The z-scale bar will be created at 0.3 of the width of the image as it is displayed when this function is called
//	Variable marginr = 0.5 * imgWidth
//	ModifyGraph/W=$graphName width=imgWidth, margin(right)=marginr

	// Get full name and path to image wave
	String/G imgWFullStr
	
	// Create wave assignment for 3d cits wave
	Wave imgW = $imgWFullStr
	
	// Get the wave note
	String imgInfoFromNote = note(imgW)
	
	// Get the bias and setpoint values from the wave note
	String biasStr = StringByKey("Voltage",imgInfoFromNote)
	String setpointStr = StringByKey("Setpoint",imgInfoFromNote)
	
	// convert to nano, pico, etc.
	biasStr = sciunit(biasStr)
	setpointStr = sciunit(setpointStr)
	
	Variable bias, setpoint
	String biasUnit, setpointUnit
	sscanf biasStr, "%f%s", bias, biasUnit
	sscanf setpointStr, "%f%s", setpoint, setpointUnit

	// Get the time stamp from the wave note
	String timeStr = StringByKey("Time stamp",imgInfoFromNote)
	
	// Add the information to the displayed image
	String cmd
	
	// Add the bias and set point to the image as an annotation
	//	Sprintf cmd, "TextBox/C/N=text1/Z=1/F=0/A=LB/X=102/Y=0 \"\F'Arial'\Z09 %4.3f %s\\r %4.3f %s\\r %2.1f%s gain\\r %2.0f %s\"",bias, biasunitStr, setpoint1, setpoint1unitStr, loopgain1, loopgainunitStr, scanspeed, scanspeedunitStr
	Sprintf cmd, "TextBox/C/N=text1/Z=1/F=0/A=LB/X=102/Y=0 \"\JR\F'Arial'\Z09 %4.2f %s\\r %4.0f %s\"",bias, biasUnit, setpoint, setpointUnit
	Execute cmd

	// add the image name to the image as an annotation
	Sprintf cmd, "TextBox/C/N=text2/Z=1/F=0/A=LB/X=0/Y=100.3 \"\F'Arial'\Z09%s\"", possiblyRemoveQuotes(imgWStr)
	Execute cmd
	
	// add the data acuisition time to the image as an annotation
	Sprintf cmd, "TextBox/C/N=text3/Z=1/F=0/A=RB/X=0/Y=100.1 \"\F'Arial'\Z09%s\"", timeStr
	Execute cmd
End


//------------------------------------------------
// Creates information panel on image
Function img3DInfoPanel(graphName)
	String graphName
	
	// If graphName not given (i.e., ""), then get name of the top graph window
	// if there is no graph window then this function will produce an erro
	if ( strlen(graphName)==0 )
	
			graphName= WinName(0,1)
	endif
	
	// Get name of the image Wave
	String wnameList = ImageNameList("", ";")
	String imgWStr = StringFromList(0, wnameList)
	
	// Graph size information
	GetWindow $graphName, gsize
	Variable graphLeft = V_left
	Variable graphRight = V_right
	Variable graphWidth = graphRight-graphLeft
	
	// Image size information
	GetWindow $graphName, psize
	Variable imgLeft = V_left
	Variable imgRight = V_right
	Variable imgWidth = imgRight-imgLeft

	Variable barWidth = 0.05 *imgWidth 
	Variable marginl = 0.60 * imgWidth
	Variable marginr = 0.40 * imgWidth
		
	// Adds blank margin space to the right of the image in order to leave space for the z-scale
	// The z-scale bar will be created at 0.3 of the width of the image as it is displayed when this function is called
	ModifyGraph/W=$graphName width=imgWidth, margin(left)=marginl, margin(right)=marginr
	
	// Get z information to set the limits on the variable panels
	Variable/G zSize
	Variable/G biasOffset
	Variable/G biasDelta
	
	// Calculate bias Max for panel; biasMin=the offset
	Variable biasMax= biasOffset + biasDelta * (zSize-1)
	
	GetWindow $graphName gsizeDC
	Variable xPosForPanel= V_left+5
	
	// Z Slice
	SetVariable slicePanelVar,bodyWidth=60,pos={xPosForPanel,10},size={40,15},title="\JL Slice", proc=citsZPanelUpdate
	SetVariable slicePanelVar,limits={0,zSize-1,1},value=root:WinGlobals:$(graphName):citsZVar
	
	// Bias from Z Slice		
	SetVariable biasPanelVar,bodyWidth=60,pos={xPosForPanel,30},size={40,15},title="\JL Bias ", proc=citsZPanelUpdate
	SetVariable biasPanelVar,limits={biasOffset,biasMax,biasDelta},value=root:WinGlobals:$(graphName):citsBiasZVar
End



//-------------------------------
// This function is called when the toggle button on the cits image display is pressed
// Its purpose is to update the image according to which z slice the user wants to display
Function citsZPanelUpdate(ctrlName,varNum,varStr,varName) : SetVariableControl 
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// Get the name of the new graph window
	String graphName= WinName(0,1)
	
	// Change data folder to the folder containing the global variables for the image graph
	SetDataFolder root:WinGlobals:$graphName
	
	// Load global variables for wave and data folder
	String/G citsWStr
	String/G citsDF
	String/G citsWFullStr
	
	// Wave assignment for 2d and 3d cits waves
	Wave citsW = $citsWFullStr
	Wave citsImgW
	
	// Get min/max Z slice values
	Variable/G biasOffset
	Variable/G biasDelta
	Variable/G zSize
	
	strswitch(ctrlName)
		
		case "slicePanelVar":
			// read slice number, calculate bias
			Variable/G citsZVar
			Variable/G citsBiasZVar= biasDelta * citsZVar + biasOffset
		break
		
		case "biasPanelVar":
			// read bias, calculate slice number
			Variable/G citsBiasZVar
			Variable/G citsZVar=   Round( (citsBiasZVar - biasOffset) / biasDelta)
		break
		
	endswitch

	// Set the image to be the z=citsZVar slice of the 3d data set
	citsImgW[][]= citsW[p][q][citsZVar]
	
	// This allows menu control over whether or not to update the colour range of the CITS
	SVAR autoUpdateCITSColour = root:WinGlobals:SRSSTMControl:autoUpdateCITSColour
	
	changeColour(graphName,colour="keep",changeScale=autoUpdateCITSColour)
	
	// Return to starting data folder
	SetDataFolder saveDF
End








