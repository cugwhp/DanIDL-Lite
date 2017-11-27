FUNCTION get_dbl_pi2

; Description: This function returns the value of pi^2 as a double precision number. This function is
;              necessary because the system variable "!PI" in IDL only contains pi as a single
;              precision number (FLOAT type).
;
; Input Parameters:
;
;   None.
;
; Return Value:
;
;   The return value is a number of DOUBLE type whose value is equal to that of pi^2 to 15 decimal
;   places. The return value is also equal to the result of issuing the IDL command "x = acos(-1.0D)^2".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Return the value of pi^2 as a number of double type which is precise to 15 decimal places
return, 9.869604401089358D

END
