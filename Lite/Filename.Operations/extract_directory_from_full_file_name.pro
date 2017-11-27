FUNCTION extract_directory_from_full_file_name, filenames, status, NO_PAR_CHECK = no_par_check

; Description: This function takes a set of file names with full directory paths "filenames"
;              and returns the directory paths without the file names.
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
;   parameter "filenames", that is created from "filenames" by removing the file name (to
;   leave only the directory path) for each element of "filenames". If an element of
;   "filenames" does not start with the character '/', then the corresponding element of
;   the return variable is set to the empty string ''. However, if an element of "filenames"
;   does start with the character '/', then the corresponding element of the return variable
;   is set to the substring in the element of "filenames" that starts with the first
;   character and ends with the last occurrence of the character '/'. For example, the
;   "filenames" element '/data/dmb/ngc7789.fits' would be converted to the string '/data/dmb/',
;   and the "filenames" element '/data' would be converted to the string '/'.
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

;Determine which elements of "filenames" start with the character '/'
subs = where(filenames.startswith('/') EQ 1B, nsubs)

;If none of the elements of "filenames" start with the character '/'
if (nsubs EQ 0L) then begin

  ;Return the set of directory paths as a set of empty strings
  if (filenames.ndim EQ 0L) then begin
    return, ''
  endif else return, strarr(filenames.dim)
endif

;If all of the elements of "filenames" start with the character '/'
if (nsubs EQ filenames.length) then begin

  ;Determine the position of the last occurrence of the character '/' in each element of
  ;"filenames"
  last_pos = strpos(filenames, '/', /REVERSE_SEARCH)

  ;Create and return the set of output directory paths
  return, filenames.substring(0L, last_pos)
endif

;The rest of the code deals with the case that at least one, but not all, of the elements
;of "filenames" start with the character '/'. Determine the position of the last occurrence
;of the character '/' in each element of "filenames" that starts with the character '/'.
dirstr_filenames = filenames[subs]
last_pos = strpos(dirstr_filenames, '/', /REVERSE_SEARCH)

;Create and return the set of output directory paths
filenames_out = strarr(filenames.dim)
filenames_out[subs] = dirstr_filenames.substring(0L, last_pos)
return, filenames_out

END
