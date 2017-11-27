PRO write_ascii_file, filename, lines, status, errstr, OVERWRITE = overwrite, NO_PAR_CHECK = no_par_check

; Description: This module appends the set of strings "lines" as a set of new lines to the ASCII file
;              specified by "filename", creating the file if it does not exist already. The user may
;              specify to overwrite the file if it already exists.
;
; Input Parameters:
;
;   filename - STRING - The file name of the ASCII file to be written to. This parameter may be specified
;                       as a file name with or without an absolute or relative directory path. If this
;                       parameter is specified as a file name without a directory path, then the module
;                       will write to the ASCII file in the current working directory. If this parameter
;                       is specified as a file name with a relative directory path, then the module will
;                       write to the ASCII file in the relevant directory relative to the current working
;                       directory.
;   lines - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing the set of strings to be
;                                        written to the ASCII file "filename".
;
; Output Parameters:
;
;   status - INTEGER - If the module successfully wrote out the set of strings "lines" to the ASCII file
;                      "filename", then "status" is returned with a value of "1", otherwise it is returned
;                      with a value of "0".
;   errstr - STRING - If the parameter "status" is returned with a value of "0", then "errstr" is returned
;                     with the corresponding error string, otherwise it is returned as an empty string.
;
; Keywords:
;
;   If the keyword OVERWRITE is set (as "/OVERWRITE"), then the module will remove the file "filename" if
;   it already exists, and then it will recreate the file with the required content.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0
errstr = ''

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "filename" is a scalar (single) string that represents a file name with or without an absolute
  ;or relative directory path
  if (test_file_name_scalar(filename) NE 1) then begin
    errstr = 'ERROR - The input parameter "filename" does not represent a file name with or without an absolute or relative directory path...'
    return
  endif

  ;Check that "lines" is a variable of string type
  if (test_str(lines) NE 1) then begin
    errstr = 'ERROR - The input parameter "lines" is not a variable of string type...'
    return
  endif
endif

;If the keyword OVERWRITE is set
if keyword_set(overwrite) then begin

  ;Open the ASCII file "filename" and, if the file already exists, erase the contents
  openw, u1, filename, /GET_LUN, ERROR = error

;If the keyword OVERWRITE is not set
endif else begin

  ;Open the ASCII file "filename" and, if the file already exists, move the file pointer to the end of the ASCII
  ;file ready for the new lines to be appended
  openw, u1, filename, /GET_LUN, /APPEND, ERROR = error
endelse

;Check that the ASCII file could be opened without error
if (error NE 0L) then begin
  errstr = 'ERROR - The ASCII file "' + filename + '" could not be opened for writing (check permissions)...'
  return
endif

;Write the required content to the ASCII file
for i = 0L,(lines.length - 1L) do printf, u1, lines[i]

;Close the ASCII file
close, u1
free_lun, u1

;Set "status" to "1"
status = 1

END
