FUNCTION test_dbl_scalar, num

; Description: This function tests that the parameter "num" contains a scalar number of the type DOUBLE.
;
; Input Parameters:
;
;   num - ANY - The parameter to be tested whether or not it satisfies the properties that a scalar number
;               of the type DOUBLE would have.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "num" contains a scalar number of the type DOUBLE,
;   and set to "0" if "num" does not contain a scalar number of the type DOUBLE.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Check that "num" is scalar
result = size(num)
if (result[0] NE 0L) then return, 0

;If "num" is scalar (single) and contains a number of the type DOUBLE, then return a value of "1", otherwise
;return a value of "0"
if (result[1] EQ 5L) then return, 1
return, 0

END
