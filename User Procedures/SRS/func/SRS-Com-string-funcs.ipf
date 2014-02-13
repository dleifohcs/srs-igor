//------------------------------------------------------------------------------------------------------------------------------------
//
// SRS-Com-string-funcs.ipf
//
// Collection of functions for working with strings
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
// Function/S removeBadChars(str)
// Function/S removeSpace(str)
// Function/S possiblyRemoveQuotes(name)
// Function/S sciunit(numStr)
// Function/S EverythingAfterLastColon(str)
// Function/S possiblyRemoveHash(str)
// Function/S replaceHyphen(str)
// Function/S replaceSpace(str)
//Function StringByKeyNumberOfInstances(matchStr,listStr,[sepChar])
//Function/S StringByKeyIndexed(instance,matchStr,listStr,[sepChar])
//
//------------------------------------------------------------------------------------------------------------------------------------
// Above is a list of functions contained in this file
//------------------------------------------------------------------------------------------------------------------------------------


//------------------------------------------------------------------------------------------------------------------------------------
// Takes a string as input and removes bad characters
// Bad Chars=  
// : ; + = , ( )
//------------------------------------------------------------------------------------------------------------------------------------
Function/S removeBadChars(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	Variable j=0
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case ".":
				// Do nothing
				break
			case ":":
				// Do nothing
				break
			case ";":
				// Do nothing
				break
			case "+":
				// Do nothing
				break
			case "=":
				// Do nothing
				break
			case "(":
				// Do nothing
				break
			case ")":
				// Do nothing
				break
			case ",":
				// Do nothing
				break
			default:
				newstr[j]= char
				j+=1
				break
		endswitch
	endfor
	
	return newstr
End

//------------------------------------------------------------------------------------------------------------------------------------
// Takes a string as input and removes bad characters and replaces them with "_"
// Bad Chars=  
// : ; + = , ( )
//------------------------------------------------------------------------------------------------------------------------------------
Function/S replaceBadChars(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	Variable j=0
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case ".":
				newstr[j]= "_"
				j+=1
				break
			case ":":
				newstr[j]= "_"
				j+=1
				break
			case ";":
				newstr[j]= "_"
				j+=1
				break
			case "+":
				newstr[j]= "_"
				j+=1
				break
			case "=":
				newstr[j]= "_"
				j+=1
				break
			case "(":
				newstr[j]= "_"
				j+=1
				break
			case ")":
				newstr[j]= "_"
				j+=1
				break
			case ",":
				newstr[j]= "_"
				j+=1
				break
			default:
				newstr[j]= char
				j+=1
				break
		endswitch
	endfor
	
	return newstr
End


//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
Function/S removeSpace(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	Variable j=0
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case " ":
				// Do nothing
				break
			default:
				newstr[j]= char
				j+=1
				break
		endswitch
	endfor
	
	return newstr
End



//--------------------------------------------------------------------------------------------------------------
// Remove the quotes from wave names if they exist
//------------------------------------------------------------------------------------------------------------------------------------
Function/S possiblyRemoveQuotes(name)
	String name
	
	Variable len
	len = strlen(name)

	Variable beginningQuote=0
	if (cmpstr(name[0],"'")==0)
		beginningQuote=1
	endif
	
	Variable endingQuote=0
	if (cmpstr(name[0],"'")==0)
		endingQuote=1
	endif
	
	String newName = name[0+beginningQuote,len-endingQuote-1]
	
	return newName
End


//--------------------------------------------------------------------------------------------------------------
// Remove the quotes from wave names if they exist  *******DELETE THIS ONE AND REPLACE WITH THE ABOVE*****
//Function/S possiblyRemoveQuotesSpecs(name)
//	String name
//	
//	Variable len
//	len = strlen(name)//
//
//	Variable beginningQuote=0
//	if (cmpstr(name[0],"'")==0)
//		beginningQuote=1
//	endif
//	
//	Variable endingQuote=0
//	if (cmpstr(name[0],"'")==0)
//		endingQuote=1
//	endif
//	
//	String newName = name[0+beginningQuote,len-endingQuote-1]
//	
//	return newName
//End




//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
Function/S sciunit(numStr)
	String numStr
	
	Variable num
	String unit
	
	// separate the number from the unit
	sscanf numStr, "%f%s", num, unit
	
	String returnStr
	String newunit = unit
	Variable newnum = num
	
	// milli
	if ( ( abs(num) / 1e-3 >= 1 ) && ( abs(num) / 1 < 1 ))
		newnum = num / 1e-3
		newunit = "m"+unit
	endif
	
	// micro
	if ( ( abs(num) / 1e-6 >= 1 ) && ( abs(num) / 1 < 1e-3 ))
		newnum = num / 1e-6
		newunit = "micro"+unit
	endif
	
	// nano
	if ( ( abs(num) / 1e-9 >= 1 ) && ( abs(num) / 1 < 1e-6 ))
		newnum = num / 1e-9
		newunit = "n"+unit
	endif
	
	// pico 
	if ( ( abs(num) / 1e-12 >= 1 ) && ( abs(num) / 1 < 1e-9 ))
		newnum = num / 1e-12
		newunit = "p"+unit
	endif
	
	// fempto 
	if ( ( abs(num) / 1e-15 >= 1 ) && ( abs(num) / 1 < 1e-12 ))
		newnum = num / 1e-15
		newunit = "f"+unit
	endif
	
	returnStr = num2str(newnum)+" "+newunit
	
	return returnStr
	
End


//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
Function/S EverythingAfterLastColon(str)
	String str
	
	Variable i, c, len
	String returnstr = ""
	
	c = 0
	len = strlen(str)
	for ( i=0; i<len ; i+=1 )
		returnstr[c]= str[i]
		c += 1
		if ( cmpstr(str[i],":") == 0 )
			returnstr = ""
			c = 0
		endif
	endfor
	
	return returnstr
End


//------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------
Function/S possiblyRemoveHash(str)
	String str
	
	String newstr= ""
	Variable i=0
	Variable j=0
	Variable len= strlen(str)
	for (i=0; i<len;i+=1)
		if (cmpstr(str[i],"#")==0)
			// do nothing
		else
			newstr[j]=str[i]
			j+=1
		endif
	endfor
	return newstr
End
				
		
//------------------------------------------------------------------------------------------------------------------------------------
// Replaces "-" with "_"
//------------------------------------------------------------------------------------------------------------------------------------
Function/S replaceHyphen(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case "-":
				newstr[i]= "_"
				break
			default:
				newstr[i]= char
				break
		endswitch
	endfor
	
	return newstr
End


		
//------------------------------------------------------------------------------------------------------------------------------------
// Replaces " " with "_"
//------------------------------------------------------------------------------------------------------------------------------------
Function/S replaceSpace(str)
	String str
	
	Variable len=strlen(str)
	Variable i
	String newstr= ""
	String char= ""
	for (i=0; i<len; i+=1)
		char=str[i]
		strswitch(char)
			case " ":
				newstr[i]= "_"
				break
			default:
				newstr[i]= char
				break
		endswitch
	endfor
	
	return newstr
End

//----------------------------------------------------------------------------------
// counts the number of times a particular key word appears in a list
//----------------------------------------------------------------------------------
Function StringByKeyNumberOfInstances(matchStr,listStr,[sepChar])
	String matchStr,listStr,sepChar
	
	Variable i // for loops
	Variable instanceCount=0
	String tmpStr
	
	// default to semicolon for the separation character
	if ( paramIsDefault(sepChar) )
		sepChar = ";"
	endif

	// count the instances in the list
	for (i=0; i<999; i+=1 )
		tmpStr = stringFromList(i,listStr,sepChar)
		if ( strlen(tmpStr)==0 )  
			break // reached the end of the list
		endif
		if ( strlen(StringByKey(matchStr,tmpStr))==0 )
			// do nothing
		else 
			instanceCount+=1  // increment the instance count
		endif
	endfor
	
	return instanceCount
	
End

//----------------------------------------------------------------------------------
// counts the number of times a particular key word appears in a list
//----------------------------------------------------------------------------------
Function/S StringByKeyIndexed(instance,matchStr,listStr,[sepChar])
	Variable instance
	String matchStr,listStr,sepChar
	
	// default to semicolon for the separation character
	if ( paramIsDefault(sepChar) )
		sepChar = ";"
	endif
	
	Variable i // for loops
	Variable instanceCount=0
	String tmpStr
	
	// find out how many instances in total
	Variable instanceTotal = StringByKeyNumberOfInstances(matchStr,listStr,sepChar=sepChar)	
	
	if ( instance > instanceTotal-1 )
		Print "ERROR: There are only", instanceTotal, "instances in the list (the first instance is numbered 0)"
		return  ""
	endif
	
	// 	get the instance from the list
	for (i=0; i<999; i+=1 )
		tmpStr = stringFromList(i,listStr,sepChar)
		if ( strlen(StringByKey(matchStr,tmpStr))==0 )
			// do nothing
		else 
			if ( instanceCount >= instance)
				break
			endif
			instanceCount+=1  // increment the instance count
		endif
	endfor
	String returnStr = StringByKey(matchStr,tmpStr)

	return returnStr
	
End









// This is a numerical, not a string function, but I'm putting it in this procedure file for the moment
// since I do not have one of these for numerical things...
Function roundSignificant(val,N)	// round val to N significant figures
	Variable val			// input value to round
	Variable N			// number of significant figures

	if (val==0 || numtype(val))
		return val
	endif
	Variable is,tens
	is = sign(val) 
	val = abs(val)
	tens = 10^(N-floor(log(val))-1)
	return is*round(val*tens)/tens
End