PRO printv, verb, str

; Description: This module prints the set of strings stored in the parameter "str" to the
;              screen only if the parameter "verb" is set to "1". This module is useful for
;              controlling the printed output from any program.
;
; Input Parameters:
;
;   verb - INTEGER/LONG - If this parameter is set to "1", then the module will print the
;                         set of strings stored in "str" to the screen, one string per line.
;                         If this parameter is set to any other value, then the module will
;                         do nothing.
;   str - STRING SCALAR/VECTOR/ARRAY - The set of strings to be printed to the screen if
;                                      required. If this parameter is not of string type,
;                                      then the module will do nothing.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;If "verb" is a not number of the correct type, then do nothing
if (test_intlon_scalar(verb) NE 1) then return

;If "verb" is not equal to "1", then do nothing
if (verb NE 1) then return

;If "str" is not a variable of string type, then do nothing
if (test_str(str) NE 1) then return

;Print the set of strings stored in "str" to the screen, one string per line
for i = 0L,(str.length - 1L) do print, str[i]

END
