FUNCTION test_lon, num

; Description: This function tests that the parameter "num" contains data of LONG type.
;
; Input Parameters:
;
;   num - ANY - The parameter to be tested whether or not it contains data of LONG type.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "num" contains data of LONG type, and set to "0"
;   if "num" does not contain data of LONG type.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;If "num" is a variable containing data of LONG type, then return a value of "1", otherwise return a
;value of "0"
if (determine_idl_type_as_int(num) EQ 3) then return, 1
return, 0

END
