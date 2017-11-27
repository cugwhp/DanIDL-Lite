PRO test_num_scalar, num, status, numtype

; Description: This module tests that the parameter "num" contains a scalar number. In other words, it
;              checks that "num" contains a single number of any of the types BYTE, INTEGER, LONG, FLOAT,
;              DOUBLE, UINT, ULONG, LONG64, or ULONG64. The module also returns the IDL type code of the
;              parameter "num".
;
; Input Parameters:
;
;   num - ANY - The parameter to be tested whether or not it satisfies the properties that a scalar number
;               would have.
;
; Output Parameters:
;
;   status - INTEGER - The parameter "status" is set to "1" if the parameter "num" is a scalar number of
;                      any of the types BYTE, INTEGER, LONG, FLOAT, DOUBLE, UINT, ULONG, LONG64, or
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

;Check that "num" is scalar
if (size(num, /N_DIMENSIONS) NE 0L) then return

;If "num" is scalar and contains a number of any of the types BYTE, INTEGER, LONG, FLOAT, DOUBLE, UINT,
;ULONG, LONG64, or ULONG64, then set the value of "status" to "1"
if (((numtype GT 0) AND (numtype LT 6)) OR (numtype GT 11)) then status = 1

END
