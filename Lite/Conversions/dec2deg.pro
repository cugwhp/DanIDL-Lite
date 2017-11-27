FUNCTION dec2deg, str, status, NO_PAR_CHECK = no_par_check

; Description: This function converts strings of the format "pDD:MM:SS.SSS", representing
;              valid declination angles in degrees (DD, "00" to "90"), arcminutes (MM, "00"
;              to "59"), and arcseconds (SS.SSS, "00.000" to "59.999") (where "p" is a sign
;              "+" or "-" and the precision on the arcseconds can extend to any number of
;              decimal places), to numbers representing the angles in degrees. The sign
;              symbol "p" is not required to be present but will be recognised if it is "+"
;              or "-". The input parameter "str" may be a scalar, vector, or array.
;
; Input Parameters:
;
;   str - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of strings
;                                      to be converted from the format "pDD:MM:SS.SSS" to
;                                      angles in degrees.
;   status - ANY - A variable which will be used to contain the output status of the function
;                  on returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the declination string(s),
;                      then "status" is returned with a value of "1", otherwise it is
;                      returned with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision variable, with the same dimensions as the input
;   parameter "str", where each element represents a declination angle in units of degrees
;   and in the range -90 to 90 degrees. Where elements of "str" are not valid representations
;   of a declination angle in the format "pDD:MM:SS.SSS", a value of "-180.0" is returned.
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
  if (test_str(str) NE 1) then return, -180.0D
endif

;Determine which of the elements of "str" are of the format "pDD:MM:SS.SSS"
str_use = test_format_dec(str, stat, /NO_PAR_CHECK)
ok_subs = where(str_use NE 'ERROR', nok_subs)

;If none of the elements of "str" are of the format "pDD:MM:SS.SSS"
if (nok_subs EQ 0L) then begin

  ;Set "status" to "1"
  status = 1

  ;Return the results of the declination string conversion of the elements of "str"
  if (str.ndim EQ 0L) then begin
    return, -180.0D
  endif else return, replicate(-180.0D, str.dim)
endif

;If all of the elements of "str" are of the format "pDD:MM:SS.SSS"
nstr = str.length
fac1 = 1.0D/60.0D
fac2 = 1.0D/3600.0D
if (nok_subs EQ nstr) then begin

  ;Determine the signs of the declination strings stored in "str"
  sign = replicate(1.0D, nstr)
  char_off = fix(str_use.startswith('+'))
  subs = where(str_use.startswith('-') EQ 1B, nsubs)
  if (nsubs GT 0L) then begin
    sign[subs] = -1.0D
    char_off[subs] = 1
  endif

  ;Convert the declination strings stored in "str" into angles in degrees
  angles = sign*(double(str_use.substring(char_off, char_off + 1)) + (fac1*double(str_use.substring(char_off + 3, char_off + 4))) + $
           (fac2*double(str_use.substring(char_off + 6))))

;If not all of the elements of "str" are of the format "pDD:MM:SS.SSS"
endif else begin

  ;Prepare the set of output angles
  angles = replicate(-180.0D, nstr)

  ;Extract the elements of "str" that are of the format "pDD:MM:SS.SSS"
  str_use = str_use[ok_subs]

  ;Determine the signs of the declination strings stored in "str"
  sign = replicate(1.0D, nok_subs)
  char_off = fix(str_use.startswith('+'))
  subs = where(str_use.startswith('-') EQ 1B, nsubs)
  if (nsubs GT 0L) then begin
    sign[subs] = -1.0D
    char_off[subs] = 1
  endif

  ;Convert the declination strings stored in "str" into angles in degrees
  angles[ok_subs] = sign*(double(str_use.substring(char_off, char_off + 1)) + (fac1*double(str_use.substring(char_off + 3, char_off + 4))) + $
                    (fac2*double(str_use.substring(char_off + 6))))
endelse

;Set "status" to "1"
status = 1

;Return the results of the declination string conversion of the elements of "str"
if (str.ndim EQ 0L) then begin
  return, angles[0]
endif else return, reform(angles, str.dim, /OVERWRITE)

END
