PRO str2londbl, str, value, type, status, NO_PAR_CHECK = no_par_check

; Description: This module will convert the string parameter "str" to a number "value" of either LONG or
;              DOUBLE type. If "str" is a string that represents a valid number, consists only of
;              characters from the set "+-0123456789", and has a value x that lies in the range
;              (-2^31) <= x <= (2^31 - 1), then the module will convert "str" to a number "value" of LONG
;              type. If "str" is a string that represents a valid number but includes a character that is
;              not from the set "+-0123456789", or it has a value x that lies outside of the range
;              (-2^31) <= x <= (2^31 - 1), then the module will convert "str" to a number "value" of
;              DOUBLE type. If "str" is not a string that represents a valid number, then the module will
;              fail.
;
;              N.B: The implementation in this module does not use the string method ".trim" because this
;                   method is slower for scalar strings by a factor of ~3.4.
;
; Input Parameters:
;
;   str - STRING - The string representing a valid number that is to be converted to a number of LONG or
;                  DOUBLE type.
;
; Output Parameters:
;
;   value - LONG/DOUBLE - The value of the converted string "str" as a number of LONG or DOUBLE type.
;   type - INTEGER - If "str" is a string that represents a valid number, consists only of characters
;                    from the set "+-0123456789", and has a value x that lies in the range
;                    (-2^31) <= x <= (2^31 - 1), then the module will convert "str" to a number "value"
;                    of LONG type, and the parameter "type" will be set to "3". If "str" is a string
;                    that represents a valid number but includes a character that is not from the set
;                    "+-0123456789", or it has a value x that lies outside of the range
;                    (-2^31) <= x <= (2^31 - 1), then the module will convert "str" to a number "value"
;                    of DOUBLE type, and the parameter "type" will be set to "5". If the module fails
;                    in any way, then the parameter "type" will be set to "0".
;   status - INTEGER - If the module successfully converted "str" to a number "value" of either LONG or
;                      DOUBLE type, then "status" is returned with a value of "1", otherwise it is
;                      returned with a value of "0".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameter, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
value = 0L
type = 0
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "str" is a scalar string that represents a valid number
  if (test_numstr_scalar(str) EQ 'ERROR') then return
endif

;Remove any leading or trailing white space from "str"
str_use = strtrim(str, 2)

;Set "status" to "1"
status = 1

;If "str" has a value x that lies outside the range (-2^31) <= x <= (2^31 - 1), then return the
;corresponding number "value" as a number of DOUBLE type
value = double(str_use)
type = 5
if (value LT -2147483648.0D) then return
if (value GT 2147483647.0D) then return

;Decompose "str" into individual characters
chars = str2chars(str_use, stat, /NO_PAR_CHECK)

;Determine if "str" consists only of the characters "+-0123456789" or not
char_tag = (['+', '-', scmp(indgen(10))]).hasvalue(chars)

;If "str" contains characters other than those in the set "+-0123456789", then return the corresponding
;number "value" as a number of DOUBLE type
if (char_tag EQ 0B) then return

;By reaching this point, "str" may be converted safely to a number of LONG type
value = long(str_use)
type = 3

END
