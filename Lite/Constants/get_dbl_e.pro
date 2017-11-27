FUNCTION get_dbl_e

; Description: This function returns the value of e (Euler's number or Napier's constant) as a double
;              precision number.
;
; Input Parameters:
;
;   None.
;
; Return Value:
;
;   The return value is a number of DOUBLE type whose value is equal to that of e to 15 decimal places.
;   The return value is also equal to the result of issuing the IDL command "x = exp(1.0D)".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Return the value of e as a number of double type which is precise to 15 decimal places
return, 2.718281828459045D

END
