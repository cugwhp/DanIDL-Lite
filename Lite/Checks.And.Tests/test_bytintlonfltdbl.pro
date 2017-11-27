FUNCTION test_bytintlonfltdbl, num

; Description: This function tests that the parameter "num" contains data of BYTE, INTEGER, LONG, FLOAT,
;              or DOUBLE type.
;
; Input Parameters:
;
;   num - ANY - The parameter to be tested whether or not it contains data of BYTE, INTEGER, LONG, FLOAT,
;               or DOUBLE type.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "num" contains data of BYTE, INTEGER, LONG, FLOAT,
;   or DOUBLE type, and set to "0" if "num" does not contain data of BYTE, INTEGER, LONG, FLOAT, or DOUBLE
;   type.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;If "num" is a variable containing data of BYTE, INTEGER, LONG, FLOAT, or DOUBLE type, then return a value
;of "1", otherwise return a value of "0"
type = determine_idl_type_as_int(num)
if ((type GT 0) AND (type LT 6)) then return, 1
return, 0

END
