FUNCTION deg2hms, angle, ndp, status, NO_PAR_CHECK = no_par_check

; Description: This function converts angles in degrees "angle" to strings of the format
;              "HH:MM:SS.SSS" representing valid times in hours (HH, "00" to "23"), minutes
;              (MM, "00" to "59"), and seconds (SS.SSS, "00.000" to "59.999") with a precision of
;              "ndp" decimal places on the seconds. The input parameter "angle" may be a scalar,
;              vector, or array.
;
; Input Parameters:
;
;   angle - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array containing
;                                                                a set of angles in degrees.
;   ndp - INTEGER/LONG - The number of decimal places to return on the seconds in the formatted
;                        time string(s). If this parameter is negative or greater than "16",
;                        then the function will return three decimal places on the seconds in
;                        the formatted time string(s).
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input angle(s), then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of
;                      "0".
;
; Return Value:
;
;   The function returns a STRING type variable, with the same dimensions as the input parameter
;   "angle", where each element represents a time in the format "HH:MM:SS.SSS" and in the range
;   0 to 24 hours. Where elements of "angle" are not valid angles in the range 0 to 360 degrees,
;   the string 'ERROR' is returned.
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

;Return the results of the angle conversion of the elements of "angle"
return, hours2hms((1.0D/15.0D)*angle, ndp, status, /NO_PAR_CHECK)

END
