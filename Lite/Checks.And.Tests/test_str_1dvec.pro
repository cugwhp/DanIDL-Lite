PRO test_str_1dvec, data, status, xsize, dtype

; Description: This module tests that the parameter "data" contains a one-dimensional vector of strings.
;              If the module finds that "data" does indeed contain a one-dimensional vector of strings,
;              then it also determines the vector length and saves this information in the parameter
;              "xsize". Finally, the module also returns the IDL type code of the parameter "data".
;
; Input Parameters:
;
;   data - ANY - The parameter to be tested whether or not it satisfies the properties that a
;                one-dimensional vector of strings would have.
;
; Output Parameters:
;
;   status - INTEGER - The parameter "status" is set to "1" if the parameter "data" is a one-dimensional
;                      vector of data of STRING type. Otherwise, the module sets "status" to a value of
;                      "0".
;   xsize - LONG - The length of "data". This parameter is only calculated if "status" is set to "1".
;   dtype - INTEGER - The IDL type code of the data values stored in "data". Note that the IDL type code
;                     of 7 corresponds to the STRING variable type.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Determine the IDL type code for "data"
dtype = determine_idl_type_as_int(data)

;Check that "data" has one dimension
result = size(data)
if (result[0] NE 1L) then return

;If "data" is one-dimensional and contains data of STRING type, then set the value of "status" to "1" and
;determine the length of "data"
if (dtype EQ 7) then begin
  status = 1
  xsize = result[1]
endif

END
