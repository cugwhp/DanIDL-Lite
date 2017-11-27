FUNCTION scmp, str, FORMAT = format

; Description: This function converts the input variable "str" to a string type variable,
;              removing any white space that may be present. If the keyword FORMAT is set
;              to an appropriate string (see under "Keywords"), then the input variable
;              "str" is formatted accordingly. The input variable "str" may be a scalar,
;              vector, or array. The function returns the converted (and optionally
;              formatted) input variable "str".
;
; Input Parameters:
;
;   str - ANY SCALAR/VECTOR/ARRAY - The input parameter to be converted to a string type
;                                   variable.
;
; Return Value:
;
;   The function returns the input parameter "str" as a STRING type variable with the same
;   dimensions as "str".  White space will be removed from the elements of the return
;   variable. If the FORMAT keyword is set to an appropriate string, then the elements of
;   the return variable will be formatted acoordingly.
;
; Keywords:
;
;   If the keyword FORMAT is set to a scalar STRING, then the value of this keyword will
;   be fed to the IDL function "string" that converts the elements of the input variable
;   to strings. The value of this keyword should be given exactly as if it was being
;   given as a format code to the IDL function "string". Note that this module does not
;   check that the value of the keyword is a valid IDL format code.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Convert the input variable "str" to a string with the requested format and no white space,
;and return the result
if (test_str_scalar(format) EQ 1) then begin
  return, strcompress(string(str, FORMAT = format), /REMOVE_ALL)
endif else return, strcompress(string(str), /REMOVE_ALL)

END
