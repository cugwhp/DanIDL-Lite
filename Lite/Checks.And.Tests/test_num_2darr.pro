PRO test_num_2darr, data, status, xsize, ysize, dtype

; Description: This module tests that the parameter "data" contains a two-dimensional array of number data.
;              In other words, it checks that "data" is non-empty, contains numbers of any of the types BYTE,
;              INTEGER, LONG, FLOAT, DOUBLE, UINT, ULONG, LONG64, or ULONG64, and has exactly two dimensions.
;              If the module finds that "data" does indeed contain a two-dimensional array of number data,
;              then it also determines the array size and saves this information in the parameters "xsize"
;              and "ysize". Finally, the module also returns the IDL type code of the parameter "data".
;
; Input Parameters:
;
;   data - ANY - The parameter to be tested whether or not it satisfies the properties that a two-dimensional
;                array of number data would have.
;
; Output Parameters:
;
;   status - INTEGER - The parameter "status" is set to "1" if the parameter "data" is a non-empty array of
;                      numbers of any of the types BYTE, INTEGER, LONG, FLOAT, DOUBLE, UINT, ULONG, LONG64,
;                      or ULONG64, with exactly two dimensions. Otherwise, the module sets the value of
;                      "status" to "0".
;   xsize - LONG - The array size along the x-axis. This parameter is only calculated if "status" is set to
;                  "1".
;   ysize - LONG - The array size along the y-axis. This parameter is only calculated if "status" is set to
;                  "1".
;   dtype - INTEGER - The IDL type code of the data values stored in "data". Note that IDL type codes of 1,
;                     2, 3, 4, 5, 12, 13, 14, and 15 correspond to variable types of BYTE, INTEGER, LONG,
;                     FLOAT, DOUBLE, UINT, ULONG, LONG64, and ULONG64, respectively.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Determine the IDL type code for "data"
dtype = determine_idl_type_as_int(data)

;Check that "data" has two dimensions
result = size(data)
if (result[0] NE 2L) then return

;If "data" is two-dimensional and contains numbers of any of the types BYTE, INTEGER, LONG, FLOAT, DOUBLE,
;UINT, ULONG, LONG64, or ULONG64, then set the value of "status" to "1" and determine the array size
if ((dtype LT 6) OR (dtype GT 11)) then begin
  status = 1
  xsize = result[1]
  ysize = result[2]
endif

END
