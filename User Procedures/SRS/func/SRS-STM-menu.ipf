//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-STM-menu.ipf
//
// Creates the menu for SRS-SPECS
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
//------------------------------------------------------------------------------------------------------------------------------------#pragma rtGlobals=1		// Use modern global access method.


Menu "STM", dynamic
		Submenu "Display"
			"Display 2D or 3D data/F10", displayData()
			"Display all in data folder", displayAllData()
		End		

		Submenu "Colours"
			"Change image colour", doSomethingWithData("changeColour")
			setControlMenuItemDefaultColour(), changeDefaultImageColour()
			"-"
			"Set z-range: default", updateColourRange("")
			"Set z-range: Gaussian fit to histogram", updateColourRangeByHist("",type="gauss")
			"Set z-range: Exponential fit to histogram", updateColourRangeByHist("",type="exp")
			"Set z-range manually", updateColourRangeDialogue("")
			"-"
			"-"
			"Decrease Brightness"+"/F3", incrementColourScale("","increase","both")
			"Increase Brightness"+"/F4", incrementColourScale("","decrease","both")
			"Decrease Contrast"+"/SF3", incrementColourScale("","increase","range")
			"Increase Contrast"+"/SF4", incrementColourScale("","decrease","range")

			"-"
			"Decrease scale maximum"+"/OF3", incrementColourScale("","decrease","max")
			"Increase scale maximum"+"/OF4", incrementColourScale("","increase","max")
			"Decrease scale minimum"+"/SOF3", incrementColourScale("","decrease","min")
			"Increase scale minimum"+"/SOF4", incrementColourScale("","increase","min")
		End
		
		"-"
		Submenu "Region of Interest"
			"Create or Edit ROI", doSomethingWithData("createROI")
			"Kill ROI", doSomethingWithData("killROI")
		End
		Submenu "Background subtraction"
			"Plane", doSomethingWithData("subtractplane")
			"Plane from ROI", doSomethingWithData("subtractplaneROI")
			"Linewise", doSomethingWithData("subtractlinewise")
			"Set minimum to zero", doSomethingWithData("subtractMin")
			"Shift image Z-axis manually",shiftImageZDialogue("")
		End
		"-"
		Submenu "Analysis"
			"Line Profile  [2d and 3d data]/F6", doSomethingWithData("lineprofile")
			"Remove line profile", removeLineProfile("")
			"-"
			"Display image FFT", doSomethingWithData("FFT")
			"-"
			"Point from CITS/F7", doSomethingWithData("STSfromCITS")
		End
		
		
		"-"
		Submenu "Manipulation"
			"Differentiate CITS", doSomethingWithData("differentiateCITS")
			"Smooth CITS along z-axis", doSomethingWithData("smoothZ")
			"Matrix convolution [2d and 3d data]",  doSomethingWithData("mConvolution")
			"FFT Filter beta", doSomethingWithData("FFTFilter")
		End

		"-"
		Submenu "Save image"
			"Save image Window as JPEG to Desktop/F2",quickSaveImage(symbolicPath="UserDesktop",imageType="JPEG")
			"Save image Window as JPEG to Documents",quickSaveImage(symbolicPath="UserDocuments",imageType="JPEG")
			"-"
			"Save image DATA as TIFF to Desktop/SF2",quickSaveImage(symbolicPath="UserDesktop",imageType="TIFF")
			"Save image DATA as TIFF to Documents",quickSaveImage(symbolicPath="UserDocuments",imageType="TIFF")
			"-"
			"Extract a CITS slice to an image", doSomethingWithData("extractImageFromCITS")
			"Extract all CITS slices to images", doSomethingWithData("extractImageSFromCITS")
			//"Quick save JPEG to Documents/SF2",quickSaveImage(symbolicPath="SRSDocuments")
		End
		"-"
		
		Submenu "Automated scripting"
			"Batch process CITS", quickScript("CITSstandard")
			"Batch process point STS folder", quickScript("STSstandard")
		End
		"-"
		Submenu "Global Programme Control"
			setControlMenuItem("autoDisplay"), toggleAutoDisplay()
			setControlMenuItem("commonDataFolder"), toggleCommonDataFolderState()
			"-"
			setControlMenuItem("autoBGnone"), setdefaultBackground("none")
			setControlMenuItem("autoBGplane"), setdefaultBackground("plane")
			setControlMenuItem("autoBGlinewise"), setdefaultBackground("linewise")	
		End
		"-"
		"About", SRSSTMAbout()

End


// set global variable for programme control
Function toggleCommonDataFolderState()
	createSRSControlVariables()
	SVAR commonDataFolder = root:WinGlobals:SRSSTMControl:commonDataFolder
	if (cmpstr(commonDataFolder,"yes")==0)
		commonDataFolder = "no"
	else
		commonDataFolder = "yes"
		// Turn off autodisplay if loading into MyData , since otherwise will display multiples of same images. 
		SVAR autoDisplay = root:WinGlobals:SRSSTMControl:autoDisplay
		autoDisplay = "no"
	endif
End

// set global variable for programme control
Function toggleAutoDisplay()
	createSRSControlVariables()
	SVAR autoDisplay = root:WinGlobals:SRSSTMControl:autoDisplay
	if (cmpstr(autoDisplay,"yes")==0)
		autoDisplay = "no"
	else
		autoDisplay = "yes"
		// turn off the MyData folder option if doing autodisplay
		SVAR commonDataFolder = root:WinGlobals:SRSSTMControl:commonDataFolder
		commonDataFolder = "no"
	endif
End

// set global variable for programme control
// "none"; "plane"; "linewise"
Function setdefaultBackground(state)
	String state
	createSRSControlVariables()
	SVAR autoBGnone = root:WinGlobals:SRSSTMControl:autoBGnone
	SVAR autoBGplane = root:WinGlobals:SRSSTMControl:autoBGplane
	SVAR autoBGlinewise = root:WinGlobals:SRSSTMControl:autoBGlinewise
	strswitch(state)
		case "none":
			autoBGnone = "yes"
			autoBGplane = "no"
			autoBGlinewise = "no"
			break
		case "plane":
			autoBGnone = "no"
			autoBGplane = "yes"
			autoBGlinewise = "no"
			break
		case "linewise":
			autoBGnone = "no"
			autoBGplane = "no"
			autoBGlinewise = "yes"
			break
		default:
			autoBGnone = "yes"
			autoBGplane = "no"
			autoBGlinewise = "no"
			break
	endswitch
End


// This function dynamically creates menu text depending on the state of the global programma control variables.
Function/S setControlMenuItem(controlVariable)
	String controlVariable
	createSRSControlVariables()
	SVAR state = root:WinGlobals:SRSSTMControl:$controlVariable
	
	String returnStr= " "
	
	strswitch(controlVariable)
		case "autoDisplay":
			strswitch(state)
				case "yes":
					returnStr = "Auto-display flat-file images when loading!"+num2char(18) 
					break
				case "no":
					returnStr = "Auto-display flat-file images when loading"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		case "autoBGnone":
			strswitch(state)
				case "yes":
					returnStr = "Auto background subtraction: none!"+num2char(18) 
					break
				case "no":
					returnStr = "Auto background subtraction: none"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		case "autoBGplane":
			strswitch(state)
				case "yes":
					returnStr = "Auto background subtraction: plane!"+num2char(18) 
					break
				case "no":
					returnStr = "Auto background subtraction: plane"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		case "autoBGlinewise":
			strswitch(state)
				case "yes":
					returnStr = "Auto background subtraction: linewise!"+num2char(18) 
					break
				case "no":
					returnStr = "Auto background subtraction: linewise"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		case "commonDataFolder":
			strswitch(state)
				case "yes":
					returnStr = "Load all flat files into MyData!"+num2char(18) 
					break
				case "no":
					returnStr = "Load all flat files into MyData"
					break
				default:
					returnStr = "error 1"
					break
			endswitch
			break		
		default:
			returnStr = "error 2"
			break
	endswitch
	return returnStr
End

Function/S setControlMenuItemDefaultColour()
	createSRSControlVariables()
	SVAR defaultImageColours = root:WinGlobals:SRSSTMControl:defaultImageColours
	return "Change default colours ["+defaultImageColours+"]"
End