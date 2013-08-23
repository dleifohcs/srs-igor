//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-SPECS-menu.ipf
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
//------------------------------------------------------------------------------------------------------------------------------------
#pragma rtGlobals=1		// Use modern global access method.


//------------------------------------------------------------------------------------------------------------------------------------
// Menu items specific for NEXAFS data
Menu "NEXAFS"
	
	Submenu "Display - NEXAFS"
	
		"Display Double Normalised Spectrum/6", display1DWaves("oneDN")
		help = {"Display a double normalised spectrum from the current data folder in a new graph window.  Igor looks for a wave ending in '_dn', otherwise displays a dialogue."}
	
		"Display Normalised Spectrum", display1DWaves("oneN")
		help = {"Display a double normalised spectrum from the current data folder in a new graph window. Igor looks for a wave ending in '_n', otherwise displays a dialogue."}
	
		"-"
		"Set cursors for pre-edge subtraction/1", setDefaultNEXAFScursors()
		"Remove annotations from graph", removeAnnotations()
	End
	"-"
	Submenu "Manipulate"
		"Pre-edge subtraction: average/7",doSomethingWithSpecsData("leadingAvgSubtraction")
		"Pre-edge subtraction: linear/O7",doSomethingWithSpecsData("leadingSubtraction")
		"Pre-edge subtraction: constant",doSomethingWithSpecsData("leadingConstantSubtraction")
		"-"
		"Post-edge normalisation/8",doSomethingWithSpecsData("postEdgeNormalisation")
		//"Find minimum",doSomethingWithSpecsData("findMinimum")
		//"-"
		//"Divide two waves", divideGraphs()
	End
	"-"
	Submenu "Batch scripts"
		"Process NEXAFS, constant pre-edge/2", display1DWaves("oneDN"); AutoPositionWindow/E/m=0; doSomethingWithSpecsData("leadingAvgSubtraction"); doSomethingWithSpecsData("postEdgeNormalisation")
	End
	"-"
	Submenu "Make pretty"
		"NEXAFS axes/5", prettyNEXAFS()
		"-"
		"Carbon energy range", SetAxis/A bottom 280, 320; setNEXAFSyAxis()
		"Nitrogen energy range", SetAxis/A bottom 393, 420; setNEXAFSyAxis(); MakeTracesDifferentColours("CyanMagenta")
		"Define y-axis maximum for NEXAFS axes", setNEXAFSyAxisVariable()
		"-"
		"Colours: Spectrum", MakeTracesDifferentColours("SpectrumBlack")
		"Colours: Blue Red Green", MakeTracesDifferentColours("BlueRedGreen256")
		"Colours: Red Yellow", MakeTracesDifferentColours("YellowHot256")
		"Colours: Grays", MakeTracesDifferentColours("Grays256")
		"Colours: Rainbow", MakeTracesDifferentColours("Rainbow256")
		"Colours: Red", MakeTracesDifferentColours("Red")
		"Colours: Blue", MakeTracesDifferentColours("Blue")
		"Colours: Green", MakeTracesDifferentColours("Green")
		"Colours: Cyan", MakeTracesDifferentColours("Cyan")
		"Colours: Cyan Magenta", MakeTracesDifferentColours("CyanMagenta")
		"Colours: Blue Black Red", MakeTracesDifferentColours("BlueBlackRed")
		"Colours: Geo", MakeTracesDifferentColours("Geo")
	End
	
	"-"
	"About", SRSSPECSAbout()
	
		
End

