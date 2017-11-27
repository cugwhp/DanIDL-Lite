FUNCTION test_flt, num

; Description: This function tests that the parameter "num" contains data of FLOAT type.
;
; Input Parameters:
;
;   num - ANY - The parameter to be tested whether or not it contains data of FLOAT type.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "num" contains data of FLOAT type, and set to "0"
;   if "num" does not contain data of FLOAT type.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;If "num" is a variable containing data of FLOAT type, then return a value of "1", otherwise return a
;value of "0"
if (determine_idl_type_as_int(num) EQ 4) then return, 1
return, 0

END
