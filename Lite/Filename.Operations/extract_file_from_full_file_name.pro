FUNCTION extract_file_from_full_file_name, filenames, status, NO_PAR_CHECK = no_par_check

; Description: This function takes a set of file names with full directory paths "filenames"
;              and returns the file names without the directory paths.
;
; Input Parameters:
;
;   filenames - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of file
;                                            names with full directory paths that are to be
;                                            processed.
;   status - ANY - A variable which will be used to contain the output status of the function
;                  on returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input file names, then
;                      "status" is returned with a value of "1", otherwise it is returned
;                      with a value of "0".
;
; Return Value:
;
;   The function returns a STRING type variable, with the same dimensions as the input
;   parameter "filenames", that is created from "filenames" by removing the directory path
;   from each element of "filenames". If an element of "filenames" does not contain any
;   occurrences of the character '/', then the corresponding element of the return variable
;   is set to a copy of the current element of "filenames". However, if an element of
;   "filenames" does contain occurrences of the character '/', then the corresponding element
;   of the return variable is set to the string of characters after the last occurrence of
;   the character '/', even if this is the empty string ''. For example, the "filenames"
;   element '/data/dmb/ngc7789.fits' would be converted to the string 'ngc7789.fits', and
;   the "filenames" element 'DanIDL.pro' would be converted to the string 'DanIDL.pro'.
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not
;   perform parameter checking on the input parameter, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "filenames" is a variable of string type
  if (test_str(filenames) NE 1) then return, ''
endif

;Set "status" to "1"
status = 1

;Determine the position of the last occurrence of the character '/' in each element
;of "filenames"
last_pos = strpos(filenames, '/', /REVERSE_SEARCH)

;Create and return the set of output file names
return, filenames.substring(last_pos + 1L)

END
