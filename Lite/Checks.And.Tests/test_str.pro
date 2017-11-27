FUNCTION test_str, str

; Description: This function tests that the parameter "str" contains data of STRING type.
;
; Input Parameters:
;
;   str - ANY - The parameter to be tested whether or not it contains data of STRING type.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "str" contains data of STRING type, and set to "0"
;   if "str" does not contain data of STRING type.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;If "str" is a variable containing data of STRING type, then return a value of "1", otherwise return a value
;of "0"
if (determine_idl_type_as_int(str) EQ 7) then return, 1
return, 0

END
