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


Menu "STM"
	
		"Display an image or CITS/F10", displayData()
		Submenu "Colour Scale Control"
			"Change colour", doSomethingWithData("changeColour")
			"Set range to default", updateColourRange("")
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
		End
		"-"
		Submenu "Analysis"
			"Line Profile  [2d and 3d data]/F6", doSomethingWithData("lineprofile")
			"Point from CITS/F7", doSomethingWithData("STSfromCITS")
		End
		
		
		"-"
		Submenu "Manipulation"
			"Differentiate CITS", doSomethingWithData("differentiateCITS")
			"Smooth CITS along z-axis", doSomethingWithData("smoothZ")
			"Matrix convolution [2d and 3d data]",  doSomethingWithData("mConvolution")
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
			"Load all data into MyData", VariablesForProgramControl(); root:WinGlobals:srsstm_ControlVariables:commonDataFolder="yes";
			"Load data into separate datafolders", VariablesForProgramControl(); root:WinGlobals:srsstm_ControlVariables:commonDataFolder="no"
			"-"
			"Auto background subtraction: plane", VariablesForProgramControl(); root:WinGlobals:srsstm_ControlVariables:defaultBackground="plane";
			"Auto background subtraction: linewise", VariablesForProgramControl(); root:WinGlobals:srsstm_ControlVariables:defaultBackground="linewise";
		End
		"-"
		"About", SRSSTMAbout()

End

