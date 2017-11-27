FUNCTION test_str_scalar, str

; Description: This function tests that the parameter "str" contains a scalar (single) string.
;
; Input Parameters:
;
;   str - ANY - The parameter to be tested whether or not it satisfies the properties that a scalar (single)
;               string would have.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "str" contains a scalar string, and set to "0" if
;   "str" does not contain a scalar string.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Check that "str" is scalar
result = size(str)
if (result[0] NE 0L) then return, 0

;If "str" is scalar (single) and contains a string, then return a value of "1", otherwise return a value of
;"0"
if (result[1] EQ 7L) then return, 1
return, 0

END
