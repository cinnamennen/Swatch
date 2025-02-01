/*
Utility functions for filament swatch
Contains string manipulation and other helper functions
*/

/**** substr ****
Returns a substring of a string.

Arguments:
- [str] `str`: The original string.
- [int] `pos` (optional): The substring position (0 by default).
- [int] `len` (optional): The substring length (string length by default).
*/
function substr(str, pos=0, len=-1, substr="") =
    len == 0 ? substr :
    len == -1 ? substr(str, pos, len(str)-pos, substr) :
    substr(str, pos+1, len-1, str(substr, str[pos]));

// Remove leading zero from string
function no_leading_zero(strng) =
    strng == undef ? undef :
    strng == "" ? "" :
    strng[0] == "0" ? substr(strng, pos=1, len=-1, substr="") :
    strng;

// Format number according to specified zero format
function str_configurable_zero(number, format) =
    format == "enforce leading zero 0._" ?
        str(abs(number)) :
    format == "enforce leading and trailing zero 0.0" ?
        (round(number)==number ? 
            substr(str(abs(number+.01)), pos=0, len=len(str(abs(number+.01)))-1, substr="") :
            str(abs(number))) :
    no_leading_zero(str(abs(number))); 