FUNCTION str2chars, str, status, STR_INDLO = str_indlo, STR_INDHI = str_indhi, NO_PAR_CHECK = no_par_check

; Description: This function splits a string "str" into a vector of characters, with the option of only
;              extracting the characters corresponding to a substring between the string position indices
;              "str_indlo" and "str_indhi".
;
;              N.B: The implementation in this function does not use either of the string methods ".strlen"
;                   or ".charat" because these methods are slower for scalar strings by factors of ~7.4
;                   and ~1.4, respectively.
;
; Input Parameters:
;
;   str - STRING - The string from which the characters are to be extracted.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input string, then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a one-dimensional VECTOR of STRINGS where each element is a string consisting of
;   one character. The ith element of the return vector corresponds to the ith character in "str". If the
;   input parameter "str" is the empty string, then the function returns the empty string.
;
; Keywords:
;
;   If the keyword STR_INDLO is set to an INTEGER/LONG value, then only the characters at and after the
;   string index position specified by this keyword will be extracted. If this keyword has a value that is
;   greater than the value of the keyword STR_INDHI or that is out of range for the input string "str",
;   then it will be ignored.
;
;   If the keyword STR_INDHI is set to an INTEGER/LONG value, then only the characters at and before the
;   string index position specified by this keyword will be extracted. If this keyword has a value that is
;   less than the value of the keyword STR_INDLO or that is out of range for the input string "str", then
;   it will be ignored.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameter, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;If "str" is not a scalar string, then return an empty string
  if (test_str_scalar(str) NE 1) then return, ''
endif

;Set "status" to "1"
status = 1

;If "str" is an empty string, then return an empty string
nchar = strlen(str)
if (nchar EQ 0L) then return, ''
nchar_m1 = nchar - 1L

;If the keyword STR_INDLO is set, then check that it makes sense
str_indlo_use = 0L
if (test_intlon_scalar(str_indlo) EQ 1) then begin
  if ((str_indlo GE 0) AND (str_indlo LT nchar)) then str_indlo_use = long(str_indlo)
endif

;If the keyword STR_INDHI is set, then check that it makes sense
str_indhi_use = nchar_m1
if (test_intlon_scalar(str_indhi) EQ 1) then begin
  if ((str_indhi GE 0) AND (str_indhi LT nchar)) then str_indhi_use = long(str_indhi)
endif

;Check that the lower and upper indices make sense, otherwise reset them
if (str_indhi_use LT str_indlo_use) then begin
  str_indlo_use = 0L
  str_indhi_use = nchar_m1
endif

;Extract the required vector of characters from the input string and return the required vector of characters
return, strmid(str, lindgen(str_indhi_use - str_indlo_use + 1L) + str_indlo_use, 1)

END
