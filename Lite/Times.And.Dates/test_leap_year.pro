FUNCTION test_leap_year, year, status, NO_PAR_CHECK = no_par_check

; Description: This function checks whether the years in "year" are leap years or not. Note that every
;              year that is exactly divisible by 400 is a leap year. For all other years, a year that
;              is exactly divisible by 4 is a leap year, unless it is also exactly divisible by 100.
;              The input parameter "year" may be a scalar, vector, or array.
;
; Input Parameters:
;
;   year - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of numbers to be
;                                             tested for being leap years.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input number(s), then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The return variable is a SCALAR/VECTOR/ARRAY of INTEGER type, with the same dimensions as the
;   input parameter "year", where the value of each element is set to "1" if the corresponding
;   element of the input parameter "year" is a leap year, and set to "0" otherwise.
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

  ;Check that "year" is of the correct number type
  if (test_intlon(year) NE 1) then return, 0
endif

;Set "status" to "1"
status = 1

;Calculate and return the results of the leap year test on "year"
return, fix(((year mod 400) EQ 0) OR (((year mod 4) EQ 0) AND ((year mod 100) NE 0)))

END
