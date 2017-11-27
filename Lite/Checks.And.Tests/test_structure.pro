FUNCTION test_structure, struct

; Description: This function tests that the parameter "struct" contains an IDL structure.
;
; Input Parameters:
;
;   struct - ANY - The parameter to be tested whether or not it satisfies the properties that an IDL
;                  structure would have.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "struct" contains an IDL structure, and set to
;   "0" if "struct" does not contain an IDL structure.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;If "struct" is a variable containing an IDL structure, then return a value of "1", otherwise return
;a value of "0"
if (determine_idl_type_as_int(struct) EQ 8) then return, 1
return, 0

END
