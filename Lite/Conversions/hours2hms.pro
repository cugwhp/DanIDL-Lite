FUNCTION hours2hms, hour, ndp, status, NO_PAR_CHECK = no_par_check

; Description: This function converts times in hours "hour" to strings of the format
;              "HH:MM:SS.SSS" representing valid times in hours (HH, "00" to "23"), minutes
;              (MM, "00" to "59"), and seconds (SS.SSS, "00.000" to "59.999") with a precision of
;              "ndp" decimal places on the seconds. The input parameter "hour" may be a scalar,
;              vector, or array.
;
;              N.B: The implementation in this function does not use the string method ".strlen"
;                   because this method is slower for both scalar strings and vectors/arrays of
;                   strings.
;
; Input Parameters:
;
;   hour - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array containing
;                                                               a set of times in hours.
;   ndp - INTEGER/LONG - The number of decimal places to return on the seconds in the formatted
;                        time string(s). If this parameter is negative or greater than "16",
;                        then the function will return three decimal places on the seconds in
;                        the formatted time string(s).
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input time(s), then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of
;                      "0".
;
; Return Value:
;
;   The function returns a STRING type variable, with the same dimensions as the input parameter
;   "hour", where each element represents a time in the format "HH:MM:SS.SSS" and in the range 0
;   to 24 hours. Where elements of "hour" are not valid times in the range 0 to 24 hours, the
;   string 'ERROR' is returned.
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform
;   parameter checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "hour" and "ndp" are of the correct number types
  if (test_bytintlonfltdbl(hour) NE 1) then return, 'ERROR'
  if (test_intlon_scalar(ndp) NE 1) then return, 'ERROR'
endif

;If "ndp" is outside the acceptable range, then use the default value of "3" to set the format
;of the time strings
if ((ndp LT 0) OR (ndp GT 16)) then begin
  format_str = '(f25.3)'
endif else format_str = '(f25.' + scmp(fix(ndp)) + ')'

;Convert the elements of "hour" to double precision numbers
hour_use = double(hour)

;Determine which of the elements of "hour" are in the range 0 to 24 hours, taking into account
;the rounding introduced by limiting the number of decimal places on the seconds
ok_subs = where((hour_use GE 0.0D) AND (double(scmp(hour_use*3600.0D, FORMAT = format_str)) LT 86400.0D), nok_subs)

;If none of the elements of "hour" are in the range 0 to 24 hours
if (nok_subs EQ 0L) then begin

  ;Set "status" to "1"
  status = 1

  ;Return the results of the time conversion of the elements of "hour"
  if (hour.ndim EQ 0L) then begin
    return, 'ERROR'
  endif else return, replicate('ERROR', hour.dim)
endif

;If all of the elements of "hour" are in the range 0 to 24 hours
nhour = hour.length
if (nok_subs EQ nhour) then begin

  ;Determine the number of hours, minutes, and seconds for each time
  hour_num = floor(hour_use)
  hour_use = 60.0D*(temporary(hour_use) - hour_num)
  min_num = floor(hour_use)
  sec_str = scmp(60.0D*(temporary(hour_use) - min_num), FORMAT = format_str)
  subs = where(double(sec_str) EQ 60.0D, nsubs)
  if (nsubs GT 0L) then begin
    sec_str[subs] = scmp(0.0D, FORMAT = format_str)
    min_num[subs] = min_num[subs] + 1L
  endif
  subs = where(min_num EQ 60L, nsubs)
  if (nsubs GT 0L) then begin
    min_num[subs] = 0L
    hour_num[subs] = hour_num[subs] + 1L
  endif

  ;Enforce the format "SS.SSS" for the strings representing the seconds for each time
  subs = where(sec_str.startswith('-') EQ 1B, nsubs)
  if (nsubs GT 0L) then sec_str[subs] = scmp(0.0D, FORMAT = format_str)
  subs = where(sec_str.substring(1, 1) EQ '.', nsubs)
  if (nsubs GT 0L) then sec_str[subs] = '0' + sec_str[subs]
  subs = where(strlen(sec_str) EQ 3L, nsubs)
  if (nsubs GT 0L) then sec_str[subs] = sec_str[subs].substring(0, 1)

  ;Convert the times in hours stored in "hour" into time strings of the format "HH:MM:SS.SSS"
  hour_str = scmp(hour_num, FORMAT='(I02)') + ':' + scmp(min_num, FORMAT='(I02)') + ':' + sec_str

;If not all of the elements of "hour" are in the range 0 to 24 hours
endif else begin

  ;Prepare the set of output time strings
  hour_str = replicate('ERROR', nhour)

  ;Extract the elements of "hour" that are in the range 0 to 24 hours
  hour_use = hour_use[ok_subs]

  ;Determine the number of hours, minutes, and seconds for each time
  hour_num = floor(hour_use)
  hour_use = 60.0D*(temporary(hour_use) - hour_num)
  min_num = floor(hour_use)
  sec_str = scmp(60.0D*(temporary(hour_use) - min_num), FORMAT = format_str)
  subs = where(double(sec_str) EQ 60.0D, nsubs)
  if (nsubs GT 0L) then begin
    sec_str[subs] = scmp(0.0D, FORMAT = format_str)
    min_num[subs] = min_num[subs] + 1L
  endif
  subs = where(min_num EQ 60L, nsubs)
  if (nsubs GT 0L) then begin
    min_num[subs] = 0L
    hour_num[subs] = hour_num[subs] + 1L
  endif

  ;Enforce the format "SS.SSS" for the strings representing the seconds for each time
  subs = where(sec_str.startswith('-') EQ 1B, nsubs)
  if (nsubs GT 0L) then sec_str[subs] = scmp(0.0D, FORMAT = format_str)
  subs = where(sec_str.substring(1, 1) EQ '.', nsubs)
  if (nsubs GT 0L) then sec_str[subs] = '0' + sec_str[subs]
  subs = where(strlen(sec_str) EQ 3L, nsubs)
  if (nsubs GT 0L) then sec_str[subs] = sec_str[subs].substring(0, 1)

  ;Convert the times in hours stored in "hour" into time strings of the format "HH:MM:SS.SSS"
  hour_str[ok_subs] = scmp(hour_num, FORMAT='(I02)') + ':' + scmp(min_num, FORMAT='(I02)') + ':' + sec_str
endelse

;Set "status" to "1"
status = 1

;Return the results of the time conversion of the elements of "hour"
if (hour.ndim EQ 0L) then begin
  return, hour_str[0]
endif else return, reform(hour_str, hour.dim, /OVERWRITE)

END
