FUNCTION dec2rad, str, status, NO_PAR_CHECK = no_par_check

; Description: This function converts strings of the format "pDD:MM:SS.SSS", representing
;              valid declination angles in degrees (DD, "00" to "90"), arcminutes (MM, "00"
;              to "59"), and arcseconds (SS.SSS, "00.000" to "59.999") (where "p" is a sign
;              "+" or "-" and the precision on the arcseconds can extend to any number of
;              decimal places), to numbers representing the angles in radians. The sign
;              symbol "p" is not required to be present but will be recognised if it is "+"
;              or "-". The input parameter "str" may be a scalar, vector, or array.
;
; Input Parameters:
;
;   str - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of strings
;                                      to be converted from the format "pDD:MM:SS.SSS" to
;                                      angles in radians.
;   status - ANY - A variable which will be used to contain the output status of the
;                  function on returning (see output parameters below).
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
;   parameter "str", where each element represents an angle in units of radians and in the
;   range (-pi/2) to (pi/2) radians. Where elements of "str" are not valid representations
;   of a declination angle in the format "pDD:MM:SS.SSS", a value of "-2.0" is returned.
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
  if (test_str(str) NE 1) then return, -2.0D
endif

;Convert the declination strings stored in "str" into angles in radians
angles = dec2deg(str, stat, /NO_PAR_CHECK)
subs = where(angles LT -90.0D, nsubs)
angles = deg2rad(angles, status, /NO_PAR_CHECK)
if (nsubs GT 0L) then angles[subs] = -2.0D

;Return the results of the declination string conversion of the elements of "str"
return, angles

END
