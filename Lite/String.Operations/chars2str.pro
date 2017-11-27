FUNCTION chars2str, char_arr, status, NO_PAR_CHECK = no_par_check

; Description: This function creates a string by concatenating a set of characters and/or strings.
;
; Input Parameters:
;
;   char_arr - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing the set of strings to
;                                           be concatenated.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input string(s), then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of
;                      "0".
;
; Return Value:
;
;   The function returns a SCALAR STRING constructed by concatenating the string(s) stored in the
;   parameter "char_arr". The concatenation order follows that of the elements in the string
;   scalar/vector/array "char_arr".
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

  ;If "char_arr" is not a variable of string type, then return an empty string
  if (test_str(char_arr) NE 1) then return, ''
endif

;Set "status" to "1"
status = 1

;Concatenate the string elements stored in "char_arr" to create the output string, and return the
;result
return, strjoin(char_arr, /SINGLE)

END
