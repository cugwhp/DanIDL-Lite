FUNCTION test_numstr, str, status, NO_PAR_CHECK = no_par_check

; Description: This function tests that the elements of "str" are strings that represent numbers, with or
;              without a decimal point and/or a plus or minus sign. An element of "str" is also considered
;              to represent a number if it starts or ends with a decimal point, or if it ends with a
;              substring of any of the formats "EN...N", "eN...N", "E+N...N", "E-N...N", "e+N...N", or
;              "e-N...N", where "N...N" is a place holder for any set of numerical digits of any length.
;                If an element of "str" is a string that represents a number, then the function copies
;              this string element to the corresponding element of the return variable, with any leading
;              or trailing white space removed, and any other required neatening of the string format. If
;              an element of "str" is not a string that represents a number, then the function writes the
;              string 'ERROR' to the corresponding element of the return variable. The input parameter
;              "str" may be a scalar, vector, or array.
;
; Input Parameters:
;
;   str - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of strings to be tested for
;                                      a string that represents a number. Leading or trailing white space
;                                      in each string element will be ignored.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input string(s), then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a STRING type variable, with the same dimensions as the input parameter "str". If
;   an element of "str" is a string that represents a number, then the corresponding element of the return
;   variable is set to the current element of "str" but with any leading or trailing white space removed.
;   Furthermore, if this element of "str" starts with a decimal point, then the corresponding element of
;   the return variable is modified by the function to include a zero at the beginning. Similarly, if this
;   element of "str" ends with a decimal point, then the corresponding element of the return variable is
;   modified by the function to exclude the decimal point. Finally, if an element of "str" is not a string
;   that represents a number, then the corresponding element of the return variable is set to the string
;   'ERROR'.
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameter, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "str" is a variable of string type
  if (test_str(str) NE 1) then return, ''
endif

;Set up the output variable to contain the results of the number string test on the elements of "str"
nstr = str.length
out_str = strarr(nstr)

;Perform the number string test on each element of "str"
for i = 0L,(nstr - 1L) do out_str[i] = test_numstr_scalar(str[i])

;Set "status" to "1"
status = 1

;Return the results of the number string test on the elements of "str"
if (str.ndim EQ 0L) then begin
  return, out_str[0]
endif else return, reform(out_str, str.dim, /OVERWRITE)

END
