//------------------------------------------------------------------------------------------------------------------------------------
//
// KOD-SPECS-special-funcs.ipf
//
// Collection of specialized functions for fitting.
//
//------------------------------------------------------------------------------------------------------------------------------------
//
// Copyright 2013 Kane O'Donnell
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

#pragma rtGlobals=1		// Use modern global access method

//------------------------------------------------------------------------------------------------------------------------------------
// Below is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------
//
//--------------------------------------------------
// Functions for fitting NEXAFS intensity variations
//--------------------------------------------------
// Function Stohr916a(w,theta)
// Function Stohr923(w,theta)
// Function Stohr918a(w,theta)


//------------------------------------------------------------------------------------------------------------------------------------


// Provides Equation 9.16a from Stohr's "NEXAFS Spectroscopy" as a fitting
// function. Theta is the experimental angle between the sample surface normal
// and the polarization vector of the X-Ray beam. Alpha is the tilt angle of the 
// orbital axis with respect to the surface normal vector. Both are in degrees.
Function Stohr916a(w,theta) : FitFunc
	Wave w
	Variable theta

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(theta) = I0 * (1 + 0.5 * (3 * cos(theta*pi/180)^2 - 1) * (3 * cos(alpha*pi/180)^2 - 1))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ theta
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = I0
	//CurveFitDialog/ w[1] = alpha

	return w[0] * (1 + 0.5 * (3 * cos(theta*pi/180)^2 - 1) * (3 * cos(w[1]*pi/180)^2 - 1))
End

// Provides Equation 9.23 from Stohr's "NEXAFS Spectroscopy" as a fitting
// function. Parameters as above for Stohr916a. Equation 9.23 is the general
// case and should give identical angles to 9.16a for the SXR beamline because
// in our case P = 1. Just a good cross-check.
Function Stohr923(w,theta) : FitFunc
	Wave w
	Variable theta

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(theta) = A * ((cos(theta * pi / 180) ^ 2) * (1 - 1.5 * sin(alpha * pi / 180) ^ 2) + 0.5 * sin(alpha * pi / 180) ^ 2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ theta
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = alpha

	return w[0] * ((cos(theta * pi / 180) ^ 2) * (1 - 1.5 * sin(w[1] * pi / 180) ^ 2) + 0.5 * sin(w[1] * pi / 180) ^ 2)
End

// Provides Equation 9.18a from Stohr's "NEXAFS Spectroscopy" as a fitting function.
// Equation 9.18a is 9.16a modified to give two angles alpha1 and alpha2 that reflect
// some spread in angles (say, due to thermal motion). Requires at least 3 data points
// for fitting.
Function Stohr918a(w,theta) : FitFunc
	Wave w
	Variable theta

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(theta) = A * (1 + 0.5 * (3 * cos(theta * pi / 180) ^ 2 - 1) * (cos(alpha1 * pi / 180) ^ 2 + cos(alpha2 * pi / 180) ^ 2 + cos(alpha1 * pi / 180) * cos(alpha2 * pi / 180) - 1))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ theta
	//CurveFitDialog/ Coefficients 3
	//CurveFitDialog/ w[0] = A
	//CurveFitDialog/ w[1] = alpha1
	//CurveFitDialog/ w[2] = alpha2

	return w[0] * (1 + 0.5 * (3 * cos(theta * pi / 180) ^ 2 - 1) * (cos(w[1] * pi / 180) ^ 2 + cos(w[2] * pi / 180) ^ 2 + cos(w[1] * pi / 180) * cos(w[2] * pi / 180) - 1))
End