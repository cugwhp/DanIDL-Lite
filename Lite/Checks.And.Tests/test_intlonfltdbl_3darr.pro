PRO test_intlonfltdbl_3darr, data, status, xsize, ysize, zsize, dtype

; Description: This module tests that the parameter "data" contains a three-dimensional array of numbers
;              of the type INTEGER, LONG, FLOAT, or DOUBLE. If the module finds that "data" does indeed
;              contain a three-dimensional array of numbers of the type INTEGER, LONG, FLOAT, or DOUBLE,
;              then it also determines the array size and saves this information in the parameters
;              "xsize", "ysize", and "zsize". Finally, the module also returns the IDL type code of the
;              parameter "data".
;
; Input Parameters:
;
;   data - ANY - The parameter to be tested whether or not it satisfies the properties that a
;                three-dimensional array of numbers of the type INTEGER, LONG, FLOAT, or DOUBLE would
;                have.
;
; Output Parameters:
;
;   status - INTEGER - The parameter "status" is set to "1" if the parameter "data" is a three-dimensional
;                      array of numbers of the type INTEGER, LONG, FLOAT, or DOUBLE. Otherwise, the module
;                      sets the value of "status" to "0".
;   xsize - LONG - The array size along the x-axis. This parameter is only calculated if "status" is set
;                  to "1".
;   ysize - LONG - The array size along the y-axis. This parameter is only calculated if "status" is set
;                  to "1".
;   zsize - LONG - The array size along the z-axis. This parameter is only calculated if "status" is set
;                  to "1".
;   dtype - INTEGER - The IDL type code of the data values stored in "data". Note that IDL type codes of
;                     2, 3, 4, and 5 correspond to variable types of INTEGER, LONG, FLOAT, and DOUBLE,
;                     respectively.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Determine the IDL type code for "data"
dtype = determine_idl_type_as_int(data)

;Check that "data" has three dimensions
result = size(data)
if (result[0] NE 3L) then return

;If "data" is three-dimensional and contains numbers of the type INTEGER, LONG, FLOAT, or DOUBLE, then
;set the value of "status" to "1" and determine the array size
if ((dtype GT 1) AND (dtype LT 6)) then begin
  status = 1
  xsize = result[1]
  ysize = result[2]
  zsize = result[3]
endif

END
