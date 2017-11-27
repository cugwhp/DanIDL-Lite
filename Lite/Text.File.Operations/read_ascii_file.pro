PRO read_ascii_file, filename, nheader, nlines_in, lines, nlines_out, status, errstr, SKIP_LINES = skip_lines, ONLY_LINES = only_lines, STARTING = starting, ENDING = ending, $
                     NO_PAR_CHECK = no_par_check

; Description: This module reads in a set of lines from the ASCII file specified by "filename". The
;              module will skip the first "nheader" lines, and then read in the next "nlines_in" lines,
;              storing each line in a vector of strings called "lines". The module provides the option
;              of ignoring lines containing, or starting and/or ending with, any non-empty substring
;              drawn from a specific set of substrings via the use of combinations of the keywords
;              SKIP_LINES, STARTING and ENDING. Alternatively, the module provides the option of only
;              reading in lines containing, or starting and/or ending with, any non-empty substring
;              drawn from a specific set of substrings via the use of combinations of the keywords
;              ONLY_LINES, STARTING and ENDING. The actual number of lines read in is recorded in
;              "nlines_out", corresponding to the number of elements in the output parameter "lines".
;
; Input Parameters:
;
;   filename - STRING - The file name of the ASCII file to be read in. This parameter may be specified
;                       as a file name with or without an absolute or relative directory path. If this
;                       parameter is specified as a file name without a directory path, then the module
;                       will look for the ASCII file in the current working directory. If this parameter
;                       is specified as a file name with a relative directory path, then the module will
;                       look for the ASCII file in the relevant directory relative to the current
;                       working directory.
;   nheader - INTEGER/LONG - The number of header lines to be skipped when reading in the ASCII file
;                            "filename". This parameter must be non-negative.
;   nlines_in - INTEGER/LONG - The number of data lines to be read in from the ASCII file "filename"
;                              and stored. If this parameter is zero or negative, then all data lines
;                              after the header line(s) will be read in and stored. Lines containing,
;                              or starting or ending with, any non-empty substring drawn from a specific
;                              set of substrings defined by the keyword SKIP_LINES are not considered
;                              to be data lines and therefore do not count against the number of data
;                              lines to be read in specified by this parameter. Alternatively, lines
;                              containing, or starting or ending with, any non-empty substring drawn
;                              from a specific set of substrings defined by the keyword ONLY_LINES are
;                              the only lines that count against the number of data lines to be read
;                              in specified by this parameter. Note that the keywords SKIP_LINES and
;                              ONLY_LINES cannot both be set at the same time.
;
; Output Parameters:
;
;   lines - STRING VECTOR - A vector of strings with "nlines_out" elements where each element stores a
;                           line from the ASCII file "filename".
;   nlines_out - LONG - The number of data lines actually read in from the ASCII file "filename" and
;                       stored.
;   status - INTEGER - If the module successfully read in and stored at least one line from the ASCII
;                      file "filename", then "status" is returned with a value of "1", otherwise it is
;                      returned with a value of "0".
;   errstr - STRING - If the parameter "status" is returned with a value of "0", then "errstr" is
;                     returned with the corresponding error string, otherwise it is returned as an
;                     empty string.
;
; Keywords:
;
;   If the keyword SKIP_LINES is set to a SCALAR/VECTOR/ARRAY variable of STRING type, then lines which
;   contain any of the non-empty substrings stored in this variable are ignored (i.e. they are not
;   returned in the output parameter "lines" nor are they counted in the output parameter "nlines_out").
;   If the keyword STARTING is set at the same time as this keyword, then only lines which start with
;   any of the non-empty substrings stored in this variable are ignored. If the keyword ENDING is set at
;   the same time as this keyword, then only lines which end with any of the non-empty substrings stored
;   in this variable are ignored. If both of the keywords STARTING and ENDING are set at the same time
;   as this keyword, then only lines which start or end with any of the non-empty substrings stored in
;   this variable are ignored. Note that the module will fail if both of the keywords SKIP_LINES and
;   ONLY_LINES are set at the same time.
;
;   If the keyword ONLY_LINES is set to a SCALAR/VECTOR/ARRAY variable of STRING type, then only lines
;   which contain any of the non-empty substrings stored in this variable are read in and stored (i.e.
;   they are the only lines that are returned in the output parameter "lines" and that are counted in
;   the output parameter "nlines_out"). If the keyword STARTING is set at the same time as this
;   keyword, then only lines which start with any of the non-empty substrings stored in this variable
;   are read in and stored. If the keyword ENDING is set at the same time as this keyword, then only
;   lines which end with any of the non-empty substrings stored in this variable are read in and
;   stored. If both of the keywords STARTING and ENDING are set at the same time as this keyword, then
;   only lines which start or end with any of the non-empty substrings stored in this variable are
;   read in and stored. Note that the module will fail if both of the keywords SKIP_LINES and ONLY_LINES
;   are set at the same time.
;
;   If the keyword STARTING is set (as "/STARTING"), then the module will only search for the presence
;   of any non-empty substring drawn from the set of substrings defined by the keywords
;   SKIP_LINES/ONLY_LINES at the start of each line. If the keyword ENDING is set at the same time as
;   this keyword, then the module will only search for the presence of any non-empty substring drawn
;   from the set of substrings defined by the keywords SKIP_LINES/ONLY_LINES at the start or the end
;   of each line. This keyword has no effect if neither of the keywords SKIP_LINES or ONLY_LINES are
;   set.
;
;   If the keyword ENDING is set (as "/ENDING"), then the module will only search for the presence of
;   any non-empty substring drawn from the set of substrings defined by the keywords
;   SKIP_LINES/ONLY_LINES at the end of each line. If the keyword STARTING is set at the same time as
;   this keyword, then the module will only search for the presence of any non-empty substring drawn
;   from the set of substrings defined by the keywords SKIP_LINES/ONLY_LINES at the start or the end
;   of each line. This keyword has no effect if neither of the keywords SKIP_LINES or ONLY_LINES are
;   set.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
lines = ''
nlines_out = 0L
status = 0
errstr = ''

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "filename" is a scalar (single) string that represents a file name with or without an
  ;absolute or relative directory path
  if (test_file_name_scalar(filename) NE 1) then begin
    errstr = 'ERROR - The input parameter "filename" does not represent a file name with or without an absolute or relative directory path...'
    return
  endif

  ;Check the values of "nheader" and "nlines_in"
  if (test_intlon_scalar(nheader) NE 1) then begin
    errstr = 'ERROR - The input parameter "nheader" is not a number of the correct type...'
    return
  endif
  if (nheader LT 0) then begin
    errstr = 'ERROR - The input parameter "nheader" is negative...'
    return
  endif
  if (test_intlon_scalar(nlines_in) NE 1) then begin
    errstr = 'ERROR - The input parameter "nlines_in" is not a number of the correct type...'
    return
  endif
endif
nheader_use = long(nheader)
nlines_in_use = long(nlines_in)

;Test for the existence and readability of the ASCII file "filename"
if (file_test(filename, /REGULAR, /READ) EQ 0L) then begin
  errstr = 'ERROR - The ASCII file "' + filename + '" does not exist (or it is not readable)...'
  return
endif

;Determine the number of lines in the ASCII file "filename"
ndata = long(file_lines(filename))

;If the ASCII file is empty, then return without doing anything
if (ndata EQ 0L) then begin
  errstr = 'ERROR - The ASCII file "' + filename + '" has no lines to read in...'
  return
endif

;If the number of header lines to be skipped is greater than or equal to the number of lines in the
;ASCII file, then return without doing anything
if (nheader_use GE ndata) then begin
  errstr = 'ERROR - The number of header lines to be skipped is greater than or equal to the number of lines in the ASCII file: ' + filename
  return
endif

;Determine the number of (unique) substrings to be tested for their presence at the specified
;position(s) in each line of the ASCII file
if (test_str(skip_lines) EQ 1) then begin
  subs = where(skip_lines NE '', nskip_str)
  if (nskip_str GT 0L) then determine_unique_elements, skip_lines[subs], skip_lines_use, nskip_str
endif else nskip_str = 0L
if (test_str(only_lines) EQ 1) then begin
  subs = where(only_lines NE '', nonly_str)
  if (nonly_str GT 0L) then determine_unique_elements, only_lines[subs], only_lines_use, nonly_str
endif else nonly_str = 0L

;Check that not both of the keywords SKIP_LINES and ONLY_LINES are set at the same time
if ((nskip_str GT 0L) AND (nonly_str GT 0L)) then begin
  errstr = 'ERROR - Both of the keywords SKIP_LINES and ONLY_LINES are set at the same time...'
  return
endif

;Open the ASCII file "filename"
openr, u1, filename, /GET_LUN

;Read in but ignore the first "nheader" lines
line = ''
if (nheader_use GT 0L) then begin
  for i = 0L,(nheader_use - 1L) do readf, u1, line
endif

;If there are no substrings to be tested for their presence in each line of the ASCII file
if ((nskip_str EQ 0L) AND (nonly_str EQ 0L)) then begin

  ;Define the number of lines to be read in and, if necessary, limit the number of lines to be read
  ;in to the number of remaining lines in the ASCII file
  if (nlines_in_use LT 1L) then begin
    nlines_out = ndata - nheader_use
  endif else nlines_out = nlines_in_use < (ndata - nheader_use)

  ;Read in and store the required number of remaining lines from the ASCII file
  lines = strarr(nlines_out)
  for i = 0L,(nlines_out - 1L) do begin
    readf, u1, line
    lines[i] = line
  endfor

  ;Close the ASCII file "filename"
  close, u1
  free_lun, u1

  ;Set "status" to "1" and return
  status = 1
  return
endif

;The rest of the code deals with the case that there is at least one substring to be tested for its
;presence at the specified position(s) in each line of the ASCII file. Determine the number of lines
;remaining in the ASCII file.
nlines_remaining = ndata - nheader_use

;Define the number of lines to be read in and, if necessary, limit the number of lines to be read
;in to the number of remaining lines in the ASCII file
if (nlines_in_use LT 1L) then begin
  nlines_in_use = nlines_remaining
endif else nlines_in_use = nlines_in_use < nlines_remaining

;Set the size of the block of strings to be read in during a single loop of the reading process to
;approximately one tenth of the number of remaining lines in the ASCII file, with a minimum block
;size of 100 lines. Then determine the maximum number of blocks of strings that may need to be read
;in to finish the reading process. Reading in blocks of strings is implemented in the code in this
;part of the module in order to try and avoid reading in many more lines than is strictly necessary
;from the ASCII file while still taking advantage of the speed of vector operations in IDL.
nlines_in_block = ceil(double(nlines_remaining)/10.0D) > 100L
nblocks = ceil(double(nlines_remaining)/double(nlines_in_block))

;Create an empty block of strings
tmp_lines = strarr(nlines_in_block)

;For each block of strings to be read in from the ASCII file
curr_line = 0L
for i = 0L,(nblocks - 1L) do begin

  ;For each line in the current block of strings
  count = 0L
  for j = 0L,(nlines_in_block - 1L) do begin

    ;Read in the current line from the ASCII file and store it in the current block of strings
    readf, u1, line
    tmp_lines[j] = line
    count = count + 1L
    curr_line = curr_line + 1L

    ;If the line that was just read in from the ASCII file is the last line in the file, then break
    ;out of the loop over each line
    if (curr_line EQ nlines_remaining) then break
  endfor
  if (count LT nlines_in_block) then tmp_lines = tmp_lines[0L:(count - 1L)]

  ;If the keyword SKIP_LINES contains non-empty substrings to be tested for their presence at the
  ;specified position(s) in each line of the ASCII file
  if (nskip_str GT 0L) then begin

    ;Only store the lines from the current block of strings that do not contain, or start or end
    ;with, any of the non-empty substrings specified by the keyword SKIP_LINES
    filter_lines, tmp_lines, skip_lines_use, store_lines, nstore_lines, stat, /SKIP, STARTING = starting, ENDING = ending

  ;If the keyword ONLY_LINES contains non-empty substrings to be tested for their presence at the
  ;specified position(s) in each line of the ASCII file
  endif else begin

    ;Only store the lines from the current block of strings that contain, or start or end with,
    ;any of the non-empty substrings specified by the keyword ONLY_LINES
    filter_lines, tmp_lines, only_lines_use, store_lines, nstore_lines, stat, STARTING = starting, ENDING = ending
  endelse

  ;If none of the lines from the current block of strings have been stored, then continue to read
  ;in the next block of strings from the ASCII file
  if (nstore_lines EQ 0L) then continue

  ;Store the lines that have been read in from the ASCII file
  if (i EQ 0L) then begin
    lines = store_lines
    nlines_out = nstore_lines
  endif else begin
    lines = [lines, store_lines]
    nlines_out = nlines_out + nstore_lines
  endelse

  ;If the requested number of lines "nlines_in" have been successfully read in and stored from the
  ;ASCII file, then break out of the loop over each block of strings
  if (nlines_out GT nlines_in_use) then begin
    lines = lines[0L:(nlines_in_use - 1L)]
    nlines_out = nlines_in_use
    break
  endif else if (nlines_out EQ nlines_in_use) then break
endfor

;Close the ASCII file "filename"
close, u1
free_lun, u1

;If no lines have been read in and stored from the ASCII file
if (nlines_out EQ 0L) then begin

  ;Set the error string appropriately and return
  lines = ''
  errstr = 'ERROR - All of the lines in the ASCII file "' + filename + '" (after any header lines) were skipped...'
  return
endif

;Set "status" to "1"
status = 1

END
