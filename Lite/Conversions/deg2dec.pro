FUNCTION deg2dec, angle, ndp, status, NO_PAR_CHECK = no_par_check

; Description: This function converts declination angles in degrees "angle" to strings of the
;              format "pDD:MM:SS.SSS" representing declination angles in degrees (DD, "00" to
;              "90"), arcminutes (MM, "00" to "59"), and arcseconds (SS.SSS, "00.000" to "59.999")
;              with a precision of "ndp" decimal places on the arcseconds, where "p" is a sign "+"
;              or "-". The input parameter "angle" may be a scalar, vector, or array.
;
;              N.B: The implementation in this function does not use the string method ".strlen"
;                   because this method is slower for both scalar strings and vectors/arrays of
;                   strings.
;
; Input Parameters:
;
;   angle - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array containing
;                                                                a set of declination angles in
;                                                                degrees.
;   ndp - INTEGER/LONG - The number of decimal places to return on the arcseconds in the formatted
;                        declination angle string(s). If this parameter is negative or greater than
;                        "16", then the function will return three decimal places on the arcseconds
;                        in the formatted declination angle string(s).
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the declination angle(s), then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a STRING type variable, with the same dimensions as the input parameter
;   "angle", where each element represents a declination angle in the format "pDD:MM:SS.SSS" and in
;   the range -90 to 90 degrees. Where elements of "angle" are not valid declination angles in the
;   range -90 to 90 degrees, the string 'ERROR' is returned.
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

  ;Check that "angle" and "ndp" are of the correct number types
  if (test_bytintlonfltdbl(angle) NE 1) then return, 'ERROR'
  if (test_intlon_scalar(ndp) NE 1) then return, 'ERROR'
endif

;If "ndp" is outside the acceptable range, then use the default value of "3" to set the format
;of the declination angle strings
if ((ndp LT 0) OR (ndp GT 16)) then begin
  format_str = '(f25.3)'
endif else format_str = '(f25.' + scmp(fix(ndp)) + ')'

;Convert the elements of "angle" to double precision numbers
angle_use = double(angle)

;Determine which of the elements of "angle" are in the range -90 to 90 degrees
ok_subs = where((angle_use GE -90.0D) AND (angle_use LE 90.0D), nok_subs)

;If none of the elements of "angle" are in the range -90 to 90 degrees
if (nok_subs EQ 0L) then begin

  ;Set "status" to "1"
  status = 1

  ;Return the results of the declination angle conversion of the elements of "angle"
  if (angle.ndim EQ 0L) then begin
    return, 'ERROR'
  endif else return, replicate('ERROR', angle.dim)
endif

;If all of the elements of "angle" are in the range -90 to 90 degrees
nangle = angle.length
if (nok_subs EQ nangle) then begin

  ;Determine the signs of the declination angles stored in "angle"
  sign_str = replicate('+', nangle)
  subs = where(angle_use LT 0.0D, nsubs)
  if (nsubs GT 0L) then sign_str[subs] = '-'

  ;Determine the number of degrees, arcminutes, and arcseconds for each declination angle
  angle_use = abs(angle_use)
  deg_num = floor(angle_use)
  angle_use = 60.0D*(temporary(angle_use) - deg_num)
  min_num = floor(angle_use)
  sec_str = scmp(60.0D*(temporary(angle_use) - min_num), FORMAT = format_str)
  subs = where(double(sec_str) EQ 60.0D, nsubs)
  if (nsubs GT 0L) then begin
    sec_str[subs] = scmp(0.0D, FORMAT = format_str)
    min_num[subs] = min_num[subs] + 1L
  endif
  subs = where(min_num EQ 60L, nsubs)
  if (nsubs GT 0L) then begin
    min_num[subs] = 0L
    deg_num[subs] = deg_num[subs] + 1L
  endif

  ;Enforce the format "SS.SSS" for the strings representing the arcseconds for each declination
  ;angle
  subs = where(sec_str.startswith('-') EQ 1B, nsubs)
  if (nsubs GT 0L) then sec_str[subs] = scmp(0.0D, FORMAT = format_str)
  subs = where(sec_str.substring(1, 1) EQ '.', nsubs)
  if (nsubs GT 0L) then sec_str[subs] = '0' + sec_str[subs]
  subs = where(strlen(sec_str) EQ 3L, nsubs)
  if (nsubs GT 0L) then sec_str[subs] = sec_str[subs].substring(0, 1)

  ;Convert the declination angles in degrees stored in "angle" into declination strings of the
  ;format "pDD:MM:SS.SSS"
  angle_str = sign_str + scmp(deg_num, FORMAT='(I02)') + ':' + scmp(min_num, FORMAT='(I02)') + ':' + sec_str

;If not all of the elements of "angle" are in the range -90 to 90 degrees
endif else begin

  ;Prepare the set of output angles
  angle_str = replicate('ERROR', nangle)

  ;Extract the elements of "angle" that are in the range -90 to 90 degrees
  angle_use = angle_use[ok_subs]

  ;Determine the signs of the declination angles stored in "angle"
  sign_str = replicate('+', nok_subs)
  subs = where(angle_use LT 0.0D, nsubs)
  if (nsubs GT 0L) then sign_str[subs] = '-'

  ;Determine the number of degrees, arcminutes, and arcseconds for each declination angle
  angle_use = abs(angle_use)
  deg_num = floor(angle_use)
  angle_use = 60.0D*(temporary(angle_use) - deg_num)
  min_num = floor(angle_use)
  sec_str = scmp(60.0D*(temporary(angle_use) - min_num), FORMAT = format_str)
  subs = where(double(sec_str) EQ 60.0D, nsubs)
  if (nsubs GT 0L) then begin
    sec_str[subs] = scmp(0.0D, FORMAT = format_str)
    min_num[subs] = min_num[subs] + 1L
  endif
  subs = where(min_num EQ 60L, nsubs)
  if (nsubs GT 0L) then begin
    min_num[subs] = 0L
    deg_num[subs] = deg_num[subs] + 1L
  endif

  ;Enforce the format "SS.SSS" for the strings representing the arcseconds for each declination
  ;angle
  subs = where(sec_str.startswith('-') EQ 1B, nsubs)
  if (nsubs GT 0L) then sec_str[subs] = scmp(0.0D, FORMAT = format_str)
  subs = where(sec_str.substring(1, 1) EQ '.', nsubs)
  if (nsubs GT 0L) then sec_str[subs] = '0' + sec_str[subs]
  subs = where(strlen(sec_str) EQ 3L, nsubs)
  if (nsubs GT 0L) then sec_str[subs] = sec_str[subs].substring(0, 1)

  ;Convert the declination angles in degrees stored in "angle" into declination strings of the
  ;format "pDD:MM:SS.SSS"
  angle_str[ok_subs] = sign_str + scmp(deg_num, FORMAT='(I02)') + ':' + scmp(min_num, FORMAT='(I02)') + ':' + sec_str
endelse

;Set "status" to "1"
status = 1

;Return the results of the declination angle conversion of the elements of "angle"
if (angle.ndim EQ 0L) then begin
  return, angle_str[0]
endif else return, reform(angle_str, angle.dim, /OVERWRITE)

END
