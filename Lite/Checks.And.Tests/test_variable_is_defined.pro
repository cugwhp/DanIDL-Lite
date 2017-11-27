FUNCTION test_variable_is_defined, var

; Description: This function tests that the variable "var" is defined.
;
; Input Parameters:
;
;   var - ANY - The parameter to be tested whether or not it is defined.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "var" is defined, and set to "0" if "var" is
;   undefined.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;If "var" is defined, then return a value of "1", otherwise return a value of "0"
if (determine_idl_type_as_int(var) NE 0) then return, 1
return, 0

END
