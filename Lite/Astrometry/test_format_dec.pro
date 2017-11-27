FUNCTION test_format_dec, str, status, NO_PAR_CHECK = no_par_check

; Description: This function checks that the string elements of "str" are of the format "pDD:MM:SS.SSS",
;              representing a sign (p, "+" or "-"), degrees (DD, "00" to "90"), arcminutes (MM, "00" to
;              "59"), and arcseconds (SS.SSS, "00.000" to "59.999"), where the precision on the arcseconds
;              can extend to any number of decimal places. The sign symbol "p" is not required to be
;              present but will be recognised if it is "+" or "-". The format corresponds to an object
;              declination in sexagesimal form. If an element of "str" is of the correct format, then the
;              function copies this string element to the corresponding element of the return variable, with
;              any leading or trailing white space removed, and any other required neatening of the string
;              format. If an element of "str" is not of the correct format, then the function writes the
;              string 'ERROR' to the corresponding element of the return variable. The input parameter "str"
;              may be a scalar, vector, or array.
;
;              N.B: The implementation in this function does not use either of the string methods ".trim"
;                   or ".strlen" because these methods are slower for both scalar strings and vectors/arrays
;                   of strings. The implementation also does not use the string method ".substring" because
;                   it is slower for scalar strings by a factor of ~2.8.
;
; Input Parameters:
;
;   str - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of strings to be tested for
;                                      the format "pDD:MM:SS.SSS". Leading or trailing white space in each
;                                      string element will be ignored.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input string(s), then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a STRING type variable, with the same dimensions as the input parameter "str".
;   If an element of "str" is of the format "pDD:MM:SS.SSS", then the corresponding element of the return
;   variable is set to the current element of "str" but with any leading or trailing white space removed.
;   Furthermore, if an element of "str" is of the specific format "pDD:MM:SS.", then the corresponding
;   element of the return variable is set to the current element of "str" modified to match the format
;   "pDD:MM:SS". If an element of "str" is not of the format "pDD:MM:SS.SSS", then the corresponding
;   element of the return variable is set to the string 'ERROR'.
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameter, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "str" is a variable of string type
  if (test_str(str) NE 1) then return, ''
endif

;Remove any leading or trailing white space from the elements of "str"
str_use = strtrim(str, 2)

;Determine the length of each string element of "str"
nchar = strlen(str_use)

;For each element of "str"
numarr_90 = scmp(indgen(91), FORMAT='(I02)')
numarr_59 = numarr_90[0:59]
numarr_9 = scmp(indgen(10))
for i = 0L,(str.length - 1L) do begin

  ;Extract the current element of "str"
  curr_str = str_use[i]
  curr_nchar = nchar[i]

  ;Check that the current element of "str" has at least 8 characters
  if (curr_nchar LT 8L) then begin
    str_use[i] = 'ERROR'
    continue
  endif

  ;Decompose the current element of "str" into individual characters
  chars = str2chars(curr_str, stat, /NO_PAR_CHECK)

  ;If the first character of the current element of "str" is "+" or "-"
  pm_tag = 0
  if ((chars[0] EQ '+') OR (chars[0] EQ '-')) then begin

    ;Drop the first character "+" or "-" from the set of individual characters
    curr_nchar = curr_nchar - 1L
    chars = chars[1L:curr_nchar]
    pm_tag = 1

    ;Check that there are still at least 8 characters in the set of individual characters
    if (curr_nchar LT 8L) then begin
      str_use[i] = 'ERROR'
      continue
    endif
  endif

  ;Check the values of the individual characters in the current element of "str", and check the degree,
  ;arcminute, and arcsecond
  degree = chars[0] + chars[1]
  if (test_set_membership(degree, numarr_90, /NO_PAR_CHECK) NE 1) then begin
    str_use[i] = 'ERROR'
    continue
  endif
  if (chars[2] NE ':') then begin
    str_use[i] = 'ERROR'
    continue
  endif
  arcminute = chars[3] + chars[4]
  if (test_set_membership(arcminute, numarr_59, /NO_PAR_CHECK) NE 1) then begin
    str_use[i] = 'ERROR'
    continue
  endif
  if (chars[5] NE ':') then begin
    str_use[i] = 'ERROR'
    continue
  endif
  arcsecond = chars[6] + chars[7]
  if (test_set_membership(arcsecond, numarr_59, /NO_PAR_CHECK) NE 1) then begin
    str_use[i] = 'ERROR'
    continue
  endif
  if (degree EQ '90') then begin
    if ((arcminute NE '00') OR (arcsecond NE '00')) then begin
      str_use[i] = 'ERROR'
      continue
    endif
  endif

  ;If the current element of "str" has 8 characters, then, by reaching this point, the string has passed all
  ;of the format tests, and has the form "DD:MM:SS". Alternatively, if the current element of "str" has 9
  ;characters and starts with a "+" or "-" sign, then, by reaching this point, the string has passed all of
  ;the format tests, and has the form "pDD:MM:SS". In either case, the function will set the corresponding
  ;element of the return variable to the current element of "str".
  if (curr_nchar EQ 8L) then continue

  ;Perform another check on the current element of "str"
  if (chars[8] NE '.') then begin
    str_use[i] = 'ERROR'
    continue
  endif

  ;If the current element of "str" has 9 characters, then, by reaching this point, the string has passed all
  ;of the format tests, and has the form "DD:MM:SS.". Alternatively, if the current element of "str" has 10
  ;characters and starts with a "+" or "-" sign, then, by reaching this point, the string has passed all of
  ;the format tests, and has the form "pDD:MM:SS.". In either case, the function will set the corresponding
  ;element of the return variable to the current element of "str" modified to match the format "DD:MM:SS" or
  ;"pDD:MM:SS" as appropriate.
  if (curr_nchar EQ 9L) then begin
    str_use[i] = strmid(curr_str, 0, 8 + pm_tag)
    continue
  endif

  ;Perform the final checks on the decimal places of the current element of "str"
  if (degree NE '90') then begin
    if (numarr_9.hasvalue(chars[9L:(curr_nchar - 1L)]) EQ 0B) then str_use[i] = 'ERROR'
  endif else begin
    if (array_equal(chars[9L:(curr_nchar - 1L)], '0') EQ 0B) then str_use[i] = 'ERROR'
  endelse
endfor

;Set "status" to "1"
status = 1

;Return the results of the format check on "str"
return, str_use

END
