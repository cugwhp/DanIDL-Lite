FUNCTION determine_idl_type_as_str, var

; Description: This function determines the IDL variable-type of the input variable "var" as a string code.
;
; Input Parameters:
;
;   var - ANY - The variable for which the IDL variable-type is to be determined as a string code.
;
; Return Value:
;
;   The function returns a STRING value that represents the IDL variable-type of the input variable "var" as
;   a string code. This function works for all variable types, including undefined variables, whereas the
;   (faster) alternative "Variable Attributes" method "var.tname" fails for undefined variables.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Determine and convert the IDL variable-type integer-code for "var" to a string describing the variable type
;and return this string
case determine_idl_type_as_int(var) of
  0: return, 'UNDEFINED'
  1: return, 'BYTE'
  2: return, 'INT'
  3: return, 'LONG'
  4: return, 'FLOAT'
  5: return, 'DOUBLE'
  6: return, 'COMPLEX'
  7: return, 'STRING'
  8: return, 'STRUCT'
  9: return, 'DCOMPLEX'
  10: return, 'POINTER'
  11: return, 'OBJREF'
  12: return, 'UINT'
  13: return, 'ULONG'
  14: return, 'LONG64'
  15: return, 'ULONG64'
endcase

END
