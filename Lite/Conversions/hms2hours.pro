FUNCTION hms2hours, str, status, NO_PAR_CHECK = no_par_check

; Description: This function converts strings of the format "HH:MM:SS.SSS", representing
;              valid times in hours (HH, "00" to "23"), minutes (MM, "00" to "59"), and
;              seconds (SS.SSS, "00.000" to "59.999") (where the precision on the seconds
;              can extend to any number of decimal places), to numbers representing the
;              times in hours. The input parameter "str" may be a scalar, vector, or array.
;
; Input Parameters:
;
;   str - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of strings
;                                      to be converted from the format "HH:MM:SS.SSS" to
;                                      times in hours.
;   status - ANY - A variable which will be used to contain the output status of the
;                  function on returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the time string(s), then
;                      "status" is returned with a value of "1", otherwise it is returned
;                      with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision variable, with the same dimensions as the input
;   parameter "str", where each element represents a time in units of hours and in the range
;   0 to 24 hours. Where elements of "str" are not valid representations of a time in the
;   format "HH:MM:SS.SSS", a value of "-1.0" is returned.
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

  ;Check that "str" is a variable of string type
  if (test_str(str) NE 1) then return, -1.0D
endif

;Determine which of the elements of "str" are of the format "HH:MM:SS.SSS"
str_use = test_format_hms(str, stat, /NO_PAR_CHECK)
ok_subs = where(str_use NE 'ERROR', nok_subs)

;If none of the elements of "str" are of the format "HH:MM:SS.SSS"
if (nok_subs EQ 0L) then begin

  ;Set "status" to "1"
  status = 1

  ;Return the results of the time string conversion of the elements of "str"
  if (str.ndim EQ 0L) then begin
    return, -1.0D
  endif else return, replicate(-1.0D, str.dim)
endif

;If all of the elements of "str" are of the format "HH:MM:SS.SSS"
nstr = str.length
fac1 = 1.0D/60.0D
fac2 = 1.0D/3600.0D
if (nok_subs EQ nstr) then begin

  ;Convert the time strings stored in "str" into times in hours
  times = double(str_use.substring(0, 1)) + (fac1*double(str_use.substring(3, 4))) + (fac2*double(str_use.substring(6)))

;If not all of the elements of "str" are of the format "HH:MM:SS.SSS"
endif else begin

  ;Prepare the set of output times
  times = replicate(-1.0D, nstr)

  ;Extract the elements of "str" that are of the format "HH:MM:SS.SSS"
  str_use = str_use[ok_subs]

  ;Convert the time strings stored in "str" into times in hours
  times[ok_subs] = double(str_use.substring(0, 1)) + (fac1*double(str_use.substring(3, 4))) + (fac2*double(str_use.substring(6)))
endelse

;Set "status" to "1"
status = 1

;Return the results of the time string conversion of the elements of "str"
if (str.ndim EQ 0L) then begin
  return, times[0]
endif else return, reform(times, str.dim, /OVERWRITE)

END
