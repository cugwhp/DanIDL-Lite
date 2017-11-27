FUNCTION test_dirstr_scalar, str

; Description: This function tests that the parameter "str" contains a scalar (single) string representing a
;              directory path. The parameter "str" is considered to represent a directory path if it starts
;              with the character "/".
;
;              N.B: The implementation in this function does not use the string method ".startswith" because
;                   this method is slower for scalar strings by a factor of ~3.3.
;
; Input Parameters:
;
;   str - ANY - The parameter to be tested whether or not it satisfies the properties that a scalar (single)
;               string representing a directory path would have.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "str" contains a string representing a directory path,
;   and set to "0" if "str" does not contain a string representing a directory path.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Check that "str" is a scalar string
if (test_str_scalar(str) NE 1) then return, 0

;Return the result of the directory path test on "str"
return, fix(strpos(str, '/') EQ 0L)

END
