//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-colour.ipf
//
// For changing colour
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
// Function changeColour(graphName,[colour,cMin,cMax,changeScale])
// Function/S ctabChooseDialog(cList,cNum,[cDefault])
// Function updateColourRange(graphName,[minVal,maxVal,changeScale])
// Function updateColourRangeDialogue(graphName)
// Function incrementColourScale(graphName,change,what)
//
//------------------------------------------------------------------------------------------------------------------------------------
// Above is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------
// if [graphSuffix] is included then the colour profile is also applied to the graph window with name graphName+graphSuffix
Function changeColour(graphName,[colour,cMin,cMax,changeScale])
	String graphName, colour, changeScale 
	Variable cMin,cMax
	
	// Use "colour=keep" if the colour should remain unchanged (i.e., the same as indicated by the global variables
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// create global control variables if they do not exist (e.g., used for colour tables list)
	createSRSControlVariables()
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgDF			// data folder containing the data shown on the graph
	String/G imgWStr		// name of the wave shown on the graph (an image or 3D data set; e.g. STM or CITS)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	
	// Get the global variable ctabName if it exists
	String/G ctabName
	
	// Use this to decide whether to abort
	String doNothing = "no"
	
	// Check if a colour name is given in the function call.  If not then we are going to open a user dialogue.
	// note: if the intention is not to change colours then the function should be called with "colour=keep"
	if ( ParamIsDefault(colour) ) // if colour parameter not given open a dialogue
		
		// a list of colour tables
		SVAR cList =  root:WinGlobals:SRSSTMControl:coloursList
		Variable cNum = ItemsInList(cList)

		// get input from user
		colour= ctabChooseDialog(cList,cNum,cDefault=ctabName)

		// check if user cancelled the dialogue 
		if (cmpstr(colour,"none")==0) 
	
			Print "Warning: User cancelled colour change dialogue" 
			doNothing = "yes"
		endif
	endif
	
	// colour=keep means use the colour table already set.  
	if ( cmpstr(colour,"keep")==0 )
		
		if ( strlen(ctabName)==0 )	//Check if one has been set.
			
			Print "Error: no colour table found"
			doNothing="yes"
			
		else 
			
			colour= ctabName  // sets "colour" to be the one already set in global variables (this is so we don't reload it below).
			
		endif
	endif

	// check if doNothing has been set to "yes" before doing anything
	if ( cmpstr(doNothing,"yes")==0 )
		
		Print"Sorry, something went wrong and the colour scale is not being updated"
		// do nothing
	
	else		// do something
		 
		// check if ctabName is already set to the desired ctab, if so do nothing (ie.., assume the correct ctab is already loaded
		if (cmpstr(ctabName,colour)!=0)
		
			ctabName= colour 		// save the colour table name as a global variable
			
			// Create a file name from the colour table name
			String ctabFileName= ctabName+".ibw"		
			
			// Load the colour wave into a wave named "ctable" 
			Execute "LoadWave/P=SRSctab/O \""+ctabFileName+ "\" "
			Duplicate/O $ctabName, ctab
			
		endif
		
		// Update the colour range and apply to the image
		if ( ParamIsDefault(changeScale) )
			updateColourRange(graphName)
		else
			updateColourRange(graphName,changeScale=changeScale)
		endif
			
		// Clean up
		KillWaves/Z $ctabName
		KillVariables/Z V_Flag 
		KillStrings/Z S_path, S_fileName, S_waveNames
	
	endif  // end of "doNothing" conditional

	// Return to DF
	SetDataFolder saveDF
End



//------------------------------------------------------------------------------------------------------------------------------------
// if [graphSuffix] is included then the colour profile is also applied to the graph window with name graphName+graphSuffix
Function changeDefaultImageColour([colour])
	String colour 
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// create global variables if they don't exist (e.g., used for colour table list)
	createSRSControlVariables()
	
	// Get the global variable ctabName if it exists
	SVAR defaultImageColours = root:WinGlobals:SRSSTMControl:defaultImageColours
	
	// Check if a colour name is given in the function call.  If not then we are going to open a user dialogue.
	// note: if the intention is not to change colours then the function should be called with "colour=keep"
	if ( ParamIsDefault(colour) ) // if colour parameter not given open a dialogue
		
		// a list of colour tables
		SVAR cList =  root:WinGlobals:SRSSTMControl:coloursList
		Variable cNum = ItemsInList(cList)

		// get input from user
		colour= ctabChooseDialog(cList,cNum,cDefault=defaultImageColours)

	endif

	if (cmpstr(colour,"none")!=0) 
		defaultImageColours = colour
	endif	

	// Return to DF
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------------------------------
// This function creates a pop-up window requesting the user to choose an colour table from a list
Function/S ctabChooseDialog(cList,cNum,[cDefault])
	String cList, cDefault
	Variable cNum

	String cName
	if (strlen(cDefault)!=0)
		cName=cDefault
	endif
	Prompt cName,"Which image would you like to display?", popup, cList 
	DoPrompt "Image display",cName
   	if( V_Flag )
	      	return "none"          // user canceled
   	endif
	return cName
End


//------------------------------------------------------------------------------------------------------------------------------------
// Uses the colour table saved in the global variable folder for the data window
// If Range is set then this will override the "maxVal" variable
Function updateColourRange(graphName,[minVal,maxVal,Range,changeScale])
	String graphName,changeScale
	Variable minVal, maxVal, Range
	Variable rangeVal
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// If graphName not given (i.e., ""), then get name of the top graph window
	if ( strlen(graphName)==0 )
			graphName= WinName(0,1)
	endif
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// The ctable wave has been created and put in the appropriate WinGlobals location with the global variables and so can be assigned
	Wave ctab
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgWFullStr		// data folder plus wave name
	String/G imgWStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	
	// if noScaleChange not given then set it to "no"
	if ( ParamIsDefault(changeScale) )
		changeScale="yes"
	endif
	
	rangeVal = WaveMax(imgW)  - WaveMin(imgW)
	
	if ( cmpstr(changeScale,"no")==0 )	// this allows the colour to be changed while keeping the scale scaling
		// keep the current scaling on the colour wave
		Variable/G ctabwMin
		Variable/G ctabwMax
	else		// change the colour scaling
		// Min and max of the image wave for colour table scaling
		if ( ParamIsDefault(minVal) )  	// minVal not given in function call
			Variable/G ctabwMin = WaveMin(imgW) + 0.1*rangeVal
		else 							// minVal given in function call
			Variable/G ctabwMin = minVal
		endif
		// If Range is set then this will override the "maxVal" variable
		if ( paramIsDefault(Range) )
			if ( ParamIsDefault(maxVal) )  	// minVal not given in function call
				Variable/G ctabwMax = WaveMax(imgW) -0.05*rangeVal
			else 							// minVal given in function call
				Variable/G ctabwMax = maxVal
			endif
		else
			Variable/G ctabwMax = ctabwMin + Range
		endif
	endif 

	// Set the colour scale range to match the data range
	SetScale/I x ctabwMin, ctabwMax,"", ctab
	
	// Apply colour table to the image being displayed
	ModifyImage/W=$graphName $imgWStr cindex=root:WinGlobals:$(graphName):ctab
	
	Print "Min= ", ctabwMin, "Max= ", ctabwMax, "Range= ", (ctabwMax-ctabwMin)
	// Move back to original DF
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------------------------------
// type = { gauss , exp }
Function updateColourRangeByHist(graphName, [type])
	String graphName, type
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// If graphName not given (i.e., ""), then get name of the top graph window
	if ( strlen(graphName)==0 )
			graphName= WinName(0,1)
	endif
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// The ctable wave has been created and put in the appropriate WinGlobals location with the global variables and so can be assigned
	Wave ctab
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgWFullStr		// data folder plus wave name
	String/G imgWStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	
	// generate a histogram from the image data	
	String/G histName = imgWStr+"_HIST"
	Make/N=100/O $histName
	Wave histW = $histName
	Histogram/B=1 imgW, histW
	
	if ( paramisdefault(type) )
		type = "gauss"
	endif
	
	display1D(histName)
	
	Variable x0, width
	strswitch(type)
		case "gauss":
			CurveFit/M=2/W=0 gauss, $histName/D
			Wave W_coef
			x0 = W_coef[2]
			width = W_coef[3]
			break
		case "exp":
			CurveFit/M=2/W=0 exp, $histName/D
			Wave W_coef
			x0 = 5/W_coef[2]
			width = 5/W_coef[2]
			break
		default: // same as gauss
			CurveFit/M=2/W=0 gauss, $histName/D
			Wave W_coef
			x0 = W_coef[2]
			width = W_coef[3]
			break
	endswitch
			
//	KillWindow $WinName(0,1)
	
	
	Variable/G ctabwMin = x0 - width
	Variable/G ctabwMax = x0 + width
	
	// Set the colour scale range to match the data range
	SetScale/I x ctabwMin, ctabwMax,"", ctab
	
	// Apply colour table to the image being displayed
	ModifyImage/W=$graphName $imgWStr cindex=root:WinGlobals:$(graphName):ctab
	
	Print "Min= ", ctabwMin, "Max= ", ctabwMax, "Range= ", (ctabwMax-ctabwMin)
	// Move back to original DF
	SetDataFolder saveDF
End



//------------------------------------------------------------------------------------------------------------------------------------
// User dialogue for manually setting the colour range
Function updateColourRangeDialogue(graphName)
	String graphName
	Variable minVal, maxVal, rangeVal, rangeValOriginal
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// If graphName not given (i.e., ""), then get name of the top graph window
	if ( strlen(graphName)==0 )
			graphName= WinName(0,1)
	endif
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// Get the global variable for this graph (these were set in the manipulateData procedure)
	String/G imgWFullStr		// data folder plus wave name
	
	// Make wave assignment to the data
	Wave imgW= $imgWFullStr
	
	// The ctable wave has been created and put in the appropriate WinGlobals location with the global variables and so can be assigned
	Wave ctab
	
	minVal = leftx(ctab)
	maxVal = rightx(ctab)
	rangeVal =  maxVal - minVal
	
//	minVal = roundSignificant(minVal,3)
//	maxVal = roundSignificant(maxVal,3)
//	rangeVal = roundSignificant(rangeVal,3)
	rangeValOriginal = rangeVal
	
	Prompt minVal, "Z-scale minimum: " // 
	Prompt maxVal, "Z-scale maximum: " // 
	Prompt rangeVal, "Z-scale range (overrides maximum if changed): " // 
	DoPrompt "Set colour scale", minVal, maxVal, rangeVal
	
	if ( rangeVal !=rangeValOriginal )
		maxVal = minVal + rangeVal
	endif

	if (V_Flag)
      	Print "Warning: User cancelled dialogue"
      	return -1                     // User canceled
      else // set the scale
      	     		
     		Print "updateColourRange(\"\",minVal="+num2str(minVal)+",maxVal="+num2str(maxVal)+")"
      	updateColourRange(graphName,minVal=minVal,maxVal=maxVal)
      	
   	endif
	
	// Move back to original DF
	SetDataFolder saveDF
End


//------------------------------------------------------------------------------------------------------------------------------------
Function incrementColourScale(graphName,change,what)
	String graphName, change, what
	
	// change= increase/decrease
	// what= min/max/both/range
	
	// Get current data folder
	DFREF saveDF = GetDataFolderDFR()	  // Save
	
	// If graphName not given then get name of the top graph window
	if ( strlen(graphName)==0 )
	
			graphName= WinName(0,1)
	endif
	
	// Move to the data folder containing the global variables for the graph
	SetDataFolder root:WinGlobals:$graphName // should already be in this data folder, but include this to be sure
	
	// The ctable wave has been created and put in the appropriate WinGlobals location with the global variables and so can be assigned
	Wave ctab
	
//	Variable ctabDelta= DimDelta(ctab,0)
//	Variable ctabOffset= DimDelta(ctab,0)
//	Variable ctabSize= DimSize(ctab,0)
	
//	Variable ctabMin= ctabOffset
//	Variable ctabMax= ctabDelta*(ctabSize-1) + ctabOffset
	
	Variable/G ctabwMin
	Variable/G ctabwMax
	Variable ctabRange= ctabwMax - ctabwMin
	
	Variable resolution=60
	Variable increment= ctabRange/resolution
	
	strswitch ( change )
		case "increase":
			// do nothing
			break
		case "decrease":
			increment= -increment
			break
		default:
			increment=0
			break
	endswitch
	
	strswitch ( what )
		case "both":
			ctabwMin= ctabwMin + increment
			ctabwMax= ctabwMax + increment
			break
			
		case "range":
			ctabwMin= ctabwMin - increment
			ctabwMax= ctabwMax + increment
			break
		
		case "min":
			ctabwMin= ctabwMin + increment
			break
			
		case "max":
			ctabwMax= ctabwMax + increment
			break
			
		default:
			// do nothing
			break
	endswitch

	// Update colour range
	updateColourRange(graphName,minVal=ctabwMin,maxVal=ctabwMax)
	
	// Move back to original DF
	SetDataFolder saveDF
End






