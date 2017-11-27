FUNCTION hms2rad, str, status, NO_PAR_CHECK = no_par_check

; Description: This function converts strings of the format "HH:MM:SS.SSS", representing
;              valid times in hours (HH, "00" to "23"), minutes (MM, "00" to "59"), and
;              seconds (SS.SSS, "00.000" to "59.999") (where the precision on the seconds
;              can extend to any number of decimal places), to numbers representing the
;              angles in radians. The input parameter "str" may be a scalar, vector, or
;              array.
;
; Input Parameters:
;
;   str - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of strings
;                                      to be converted from the format "HH:MM:SS.SSS" to
;                                      angles in radians.
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
;   parameter "str", where each element represents an angle in units of radians and in the
;   range 0 to 2*pi radians. Where elements of "str" are not valid representations of a time
;   in the format "HH:MM:SS.SSS", a value of "-1.0" is returned.
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

;Convert the time strings stored in "str" into angles in radians
angles = (get_dbl_pi()/12.0D)*hms2hours(str, status, /NO_PAR_CHECK)
subs = where(angles LT 0.0D, nsubs)
if (nsubs GT 0L) then angles[subs] = -1.0D

;Return the results of the time string conversion of the elements of "str"
return, angles

END
