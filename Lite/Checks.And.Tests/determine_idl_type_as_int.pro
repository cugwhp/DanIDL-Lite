FUNCTION determine_idl_type_as_int, var

; Description: This function determines the IDL variable-type integer-code for the input variable "var".
;
; Input Parameters:
;
;   var - ANY - The variable for which the IDL variable-type integer-code is to be determined.
;
; Return Value:
;
;   The function returns an INTEGER value that represents the IDL variable-type integer-code for the
;   input variable "var". This function works for all variable types, including undefined variables,
;   whereas the (faster) alternative "Variable Attributes" method "var.typecode" fails for undefined
;   variables.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Return the IDL variable-type integer-code for "var"
return, fix(size(var, /TYPE))

END
