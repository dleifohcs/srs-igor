//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-STM-initialise.ipf
//
// Loads procedure files required for SRS-STM
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

// Load procedures from the following files

// Common
#include "SRS-Com-linetrace-funcs"
#include "SRS-Com-string-funcs"

// File Handlng
#include "SRS-File-load"

// STM / STS / CITS
#include "SRS-STM-menu"
#include "SRS-colour"
#include "SRS-STM-disp-img"
#include "SRS-STM-data-manip"

//------------------------------------------------------------------------------------------------------------------------------------
// Line trace - general
#include "SRS-Com-linetrace-menu"