FUNCTION test_format_hms, str, status, NO_PAR_CHECK = no_par_check

; Description: This function checks that the string elements of "str" are of the format "HH:MM:SS.SSS",
;              representing hours (HH, "00" to "23"), minutes (MM, "00" to "59"), and seconds (SS.SSS,
;              "00.000" to "59.999"), where the precision on the seconds can extend to any number of
;              decimal places. The format corresponds to a 24-hour clock time. If an element of "str"
;              is of the correct format, then the function copies this string element to the
;              corresponding element of the return variable, with any leading or trailing white space
;              removed, and any other required neatening of the string format. If an element of "str"
;              is not of the correct format, then the function writes the string 'ERROR' to the
;              corresponding element of the return variable. The input parameter "str" may be a scalar,
;              vector, or array.
;
;              N.B: The implementation in this function does not use either of the string methods ".trim"
;                   or ".strlen" because these methods are slower for both scalar strings and
;                   vectors/arrays of strings. The implementation also does not use the string method
;                   ".substring" because it is slower for scalar strings by a factor of ~2.8.
;
; Input Parameters:
;
;   str - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of strings to be tested
;                                      for the format "HH:MM:SS.SSS". Leading or trailing white space
;                                      in each string element will be ignored.
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
;   The function returns a STRING type variable, with the same dimensions as the input parameter "str".
;   If an element of "str" is of the format "HH:MM:SS.SSS", then the corresponding element of the return
;   variable is set to the current element of "str" but with any leading or trailing white space removed.
;   Furthermore, if an element of "str" is of the specific format "HH:MM:SS.", then the corresponding
;   element of the return variable is set to the current element of "str" modified to match the format
;   "HH:MM:SS". If an element of "str" is not of the format "HH:MM:SS.SSS", then the corresponding
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
numarr_59 = scmp(indgen(60), FORMAT='(I02)')
numarr_23 = numarr_59[0:23]
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

  ;Check the values of the individual characters in the current element of "str", and check the hour,
  ;minute, and second
  hour = chars[0] + chars[1]
  if (test_set_membership(hour, numarr_23, /NO_PAR_CHECK) NE 1) then begin
    str_use[i] = 'ERROR'
    continue
  endif
  if (chars[2] NE ':') then begin
    str_use[i] = 'ERROR'
    continue
  endif
  minute = chars[3] + chars[4]
  if (test_set_membership(minute, numarr_59, /NO_PAR_CHECK) NE 1) then begin
    str_use[i] = 'ERROR'
    continue
  endif
  if (chars[5] NE ':') then begin
    str_use[i] = 'ERROR'
    continue
  endif
  second = chars[6] + chars[7]
  if (test_set_membership(second, numarr_59, /NO_PAR_CHECK) NE 1) then begin
    str_use[i] = 'ERROR'
    continue
  endif

  ;If the current element of "str" has 8 characters, then, by reaching this point, the string has passed
  ;all of the format tests, and has the form "HH:MM:SS". In this case, the function will set the
  ;corresponding element of the return variable to the current element of "str".
  if (curr_nchar EQ 8L) then continue

  ;Perform another check on the current element of "str"
  if (chars[8] NE '.') then begin
    str_use[i] = 'ERROR'
    continue
  endif

  ;If the current element of "str" has 9 characters, then, by reaching this point, the string has passed
  ;all of the format tests, and has the form "HH:MM:SS.". In this case, the function will set the
  ;corresponding element of the return variable to the current element of "str" modified to match the
  ;format "HH:MM:SS".
  if (curr_nchar EQ 9L) then begin
    str_use[i] = strmid(curr_str, 0, 8)
    continue
  endif

  ;Perform the final checks on the decimal places of the current element of "str"
  if (numarr_9.hasvalue(chars[9L:(curr_nchar - 1L)]) EQ 0B) then str_use[i] = 'ERROR'
endfor

;Set "status" to "1"
status = 1

;Return the results of the format check on "str"
return, str_use

END
