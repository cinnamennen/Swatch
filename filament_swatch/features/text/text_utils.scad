/*
String manipulation utilities for filament swatch text features
*/

/* String manipulation functions */
function substr(str, pos=0, len=-1, substr="") =
    len == 0 ? substr :
    len == -1 ? substr(str, pos, len(str)-pos, substr) :
    substr(str, pos+1, len-1, str(substr, str[pos]));

function no_leading_zero(strng) =
    strng == undef ? undef :
    strng == "" ? "" :
    strng[0] == "0" ? substr(strng, pos=1, len=-1, substr="") :
    strng;

function str_configurable_zero(number, format) =
    format=="enforce leading zero 0._" ?
        str(abs(number)) :
    format=="enforce leading and trailing zero 0.0" ?
        (round(number)==number ? 
            substr(str(abs(number+.01)), pos=0, len=len(str(abs(number+.01)))-1, substr="") :
            str(abs(number))) :
    no_leading_zero(str(abs(number))); 

function space_letters(str, spaced="") =
    len(str) == 0 ? spaced :
    len(str) == 1 ? str(spaced, str[0]) :
    space_letters(substr(str, 1), str(spaced, str[0], " ")); 