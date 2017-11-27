FUNCTION rad2dec, angle, ndp, status, NO_PAR_CHECK = no_par_check

; Description: This function converts declination angles in radians "angle" to strings of the
;              format "pDD:MM:SS.SSS" representing declination angles in degrees (DD, "00" to
;              "90"), arcminutes (MM, "00" to "59"), and arcseconds (SS.SSS, "00.000" to "59.999")
;              with a precision of "ndp" decimal places on the arcseconds, where "p" is a sign "+"
;              or "-". The input parameter "angle" may be a scalar, vector, or array.
;
; Input Parameters:
;
;   angle - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array containing
;                                                                a set of declination angles in
;                                                                radians.
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
;   range (-pi/2) to (pi/2) radians, the string 'ERROR' is returned.
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

;Return the results of the declination angle conversion of the elements of "angle"
return, deg2dec(rad2deg(angle, stat, /NO_PAR_CHECK), ndp, status, /NO_PAR_CHECK)

END
