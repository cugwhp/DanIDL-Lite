FUNCTION test_dirstr, str, status, NO_PAR_CHECK = no_par_check

; Description: This function tests that the parameter "str" contains a set of strings that represent
;              directory paths. An element of the parameter "str" is considered to represent a
;              directory path if it starts with the character "/".
;
; Input Parameters:
;
;   str - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of strings to be tested
;                                      for satisfying the properties that a string representing a
;                                      directory path would have.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input string(s), then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns an INTEGER type variable, with the same dimensions as the input parameter
;   "str". If an element of "str" is a string representing a directory path, then the corresponding
;   element of the return variable is set to "1", otherwise it is set to "0".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform
;   parameter checking on the input parameter, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "str" is a variable of string type
  if (test_str(str) NE 1) then return, 0
endif

;Set "status" to "1"
status = 1

;Calculate and return the results of the directory path test on the elements of "str"
return, fix(str.startswith('/'))

END
