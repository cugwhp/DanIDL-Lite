FUNCTION deg2arcmin, deg, status, NO_PAR_CHECK = no_par_check

; Description: This function converts angles in degrees "deg" to angles in arcminutes. The
;              input parameter "deg" may be a scalar, vector, or array.
;
; Input Parameters:
;
;   deg - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array containing
;                                                              a set of angles in degrees.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input angle(s), then "status"
;                      is returned with a value of "1", otherwise it is returned with a value
;                      of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision variable, with the same dimensions as the input
;   parameter "deg", where each element represents an angle in units of arcminutes.
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform
;   parameter checking on the input parameter, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "deg" is of the correct number type
  if (test_bytintlonfltdbl(deg) NE 1) then return, 0.0D
endif

;Set "status" to "1"
status = 1

;Return the input angles in units of arcminutes
return, 60.0D*deg

END
