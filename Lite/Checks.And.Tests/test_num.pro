PRO test_num, num, status, numtype

; Description: This module tests that the parameter "num" contains number data. In other words, it checks
;              that "num" contains data of any of the types BYTE, INTEGER, LONG, FLOAT, DOUBLE, UINT, ULONG,
;              LONG64, or ULONG64. The module also returns the IDL type code of the parameter "num".
;
; Input Parameters:
;
;   num - ANY - The parameter to be tested whether or not it contains number data.
;
; Output Parameters:
;
;   status - INTEGER - The parameter "status" is set to "1" if the parameter "num" is contains number data
;                      of any of the types BYTE, INTEGER, LONG, FLOAT, DOUBLE, UINT, ULONG, LONG64, or
;                      ULONG64. Otherwise, the module sets "status" to a value of "0".
;   numtype - INTEGER - The IDL type code of the parameter "num". Note that IDL type codes of 1, 2, 3, 4,
;                       5, 12, 13, 14, and 15 correspond to variable types of BYTE, INTEGER, LONG, FLOAT,
;                       DOUBLE, UINT, ULONG, LONG64, and ULONG64, respectively.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Determine the IDL type code for "num"
numtype = determine_idl_type_as_int(num)

;If "num" is a variable containing number data of any of the types BYTE, INTEGER, LONG, FLOAT, DOUBLE,
;UINT, ULONG, LONG64, or ULONG64, then set the value of "status" to "1"
if (((numtype GT 0) AND (numtype LT 6)) OR (numtype GT 11)) then status = 1

END
