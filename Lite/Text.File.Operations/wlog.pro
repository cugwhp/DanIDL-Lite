PRO wlog, filename, lines, OVERWRITE = overwrite, TIME_LOG = time_log, VERB = verb, TIME_SCREEN = time_screen

; Description: This module appends the set of strings "lines" as a set of new lines to the ASCII file
;              specified by "filename", creating the file if it does not exist already. The user may
;              specify to overwrite the file if it already exists. The module will also print the set of
;              strings "lines" to the terminal if required. Finally, the user may opt to include a time
;              stamp with the set of strings printed to the ASCII file and/or the terminal.
;
; Input Parameters:
;
;   filename - STRING - The file name of the ASCII file to be written to. This parameter may be specified
;                       as a file name with or without an absolute or relative directory path. If this
;                       parameter is specified as a file name without a directory path, then the module
;                       will write to the ASCII file in the current working directory. If this parameter
;                       is specified as a file name with a relative directory path, then the module will
;                       write to the ASCII file in the relevant directory relative to the current working
;                       directory. If this parameter does not represent a file name with or without an
;                       absolute or relative directory path, then the module will return without doing
;                       anything.
;   lines - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing the set of strings to be
;                                        written to the ASCII file "filename" and optionally printed to
;                                        the terminal. If this parameter is not of string type, then the
;                                        module will return without doing anything.
;
; Output Parameters:
;
;   None.
;
; Keywords:
;
;   If the keyword OVERWRITE is set (as "/OVERWRITE"), then the module will remove the file "filename" if
;   it already exists, and then it will recreate the file with the required content.
;
;   If the keyword TIME_LOG is set (as "/TIME_LOG"), then a time stamp will be included with the set of
;   strings appended to the ASCII file "filename".
;
;   If the keyword VERB is set (as "/VERB"), then the set of strings will also be printed to the terminal.
;
;   If the keyword TIME_SCREEN is set (as "/TIME_SCREEN"), then a time stamp will be included with the set
;   of strings printed to the terminal.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;If "filename" is not a scalar (single) string that represents a file name with or without an absolute or
;relative directory path, then return without doing anything
if (test_file_name_scalar(filename) NE 1) then return

;If "lines" is not a variable of string type, then return without doing anything
if (test_str(lines) NE 1) then return

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
if (error NE 0L) then return

;Obtain the system time if necessary
if (keyword_set(time_log) OR keyword_set(time_screen)) then time_str = SYSTIME() + ' : '

;Write the required content to the ASCII file
nlines_m1 = lines.length - 1L
if keyword_set(time_log) then begin
  lines_log = time_str + lines
  for i = 0L,nlines_m1 do printf, u1, lines_log[i]
endif else begin
  for i = 0L,nlines_m1 do printf, u1, lines[i]
endelse

;Close the ASCII file
close, u1
free_lun, u1

;If the keyword VERB is set
if keyword_set(verb) then begin

  ;Print the set of strings to the terminal
  if keyword_set(time_screen) then begin
    lines_screen = time_str + lines
    for i = 0L,nlines_m1 do print, lines_screen[i]
  endif else begin
    for i = 0L,nlines_m1 do print, lines[i]
  endelse
endif

END
