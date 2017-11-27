FUNCTION test_numstr_scalar, str

; Description: This function tests that the parameter "str" is a scalar (single) string that represents a
;              number, with or without a decimal point and/or a plus or minus sign. The parameter "str"
;              is also considered to represent a number if it starts or ends with a decimal point, or if
;              it ends with a substring of any of the formats "EN...N", "eN...N", "E+N...N", "E-N...N",
;              "e+N...N", or "e-N...N", where "N...N" is a place holder for any set of numerical digits of
;              any length.
;                If "str" is a scalar string that represents a number, then the function returns the string
;              "str", with any leading or trailing white space removed, and any other required neatening
;              of the string format. If "str" is not a scalar string that represents a number, then the
;              function returns the string 'ERROR'.
;
;              N.B: The implementation in this function does not use either of the string methods ".trim"
;                   or ".strlen" because these methods are slower for scalar strings by factors of ~3.4
;                   and ~7.4, respectively.
;
; Input Parameters:
;
;   str - ANY - The parameter to be tested for a scalar (single) string that represents a number. Leading
;               or trailing white space is ignored.
;
; Return Value:
;
;   The function returns a STRING value. In the case that "str" is a scalar string that represents a
;   number, then the return value is the same as "str" but with any leading or trailing white space
;   removed. Furthermore, if the input string "str" starts with a decimal point, then the return value
;   will be modified by the function to include a zero at the beginning. Similarly, if the input string
;   "str" ends with a decimal point, then the return value will be modified by the function to exclude
;   the decimal point. In the case that "str" is not a scalar string that represents a number, then the
;   return value is the string 'ERROR'.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Check that "str" is a scalar string
if (test_str_scalar(str) NE 1) then return, 'ERROR'

;Remove any leading or trailing white space from "str"
str_use = strtrim(str, 2)

;Check that "str" has at least 1 character
nchar = strlen(str_use)
if (nchar LT 1L) then return, 'ERROR'

;If "str" has 1 character, then check that it is a numerical digit
numarr = scmp(indgen(10))
if (nchar EQ 1L) then begin
  if (test_set_membership(str_use, numarr, /NO_PAR_CHECK) NE 1) then return, 'ERROR'
  return, str_use
endif
numarr_dp = ['.', numarr]

;Decompose "str" into individual characters
chars = str2chars(str_use, stat, /NO_PAR_CHECK)
nchar_m1 = nchar - 1L

;Count and check the number of decimal points in "str"
dp_sub = where(chars EQ '.', ndp)
if (ndp GT 1L) then return, 'ERROR'
dp_sub = dp_sub[0]

;Count and check the number of "E" and "e" characters in "str"
e_sub = where((chars EQ 'E') OR (chars EQ 'e'), nall_e)
if (nall_e GT 1L) then return, 'ERROR'
e_sub = e_sub[0]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;If "str" has no decimal points and no "E" or "e" characters, then check that all characters are numerical
;digits, taking into account that the first character may be a "+" or "-" character
if ((ndp EQ 0L) AND (nall_e EQ 0L)) then begin

  ;Check that the first character is a numerical digit or a "+" or "-" character
  if (test_set_membership(chars[0], [numarr, '+', '-'], /NO_PAR_CHECK) NE 1) then return, 'ERROR'

  ;Check that the remaining characters are numerical digits only
  if (numarr.hasvalue(chars[1L:nchar_m1]) EQ 0B) then return, 'ERROR'

  ;By reaching this point, "str" has passed all of the relevant format tests. The function will now return
  ;the formatted string.
  return, str_use
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;If "str" has a decimal point but no "E" or "e" characters
if ((ndp EQ 1L) AND (nall_e EQ 0L)) then begin

  ;If the first character is a "+" or "-" character
  if ((chars[0] EQ '+') OR (chars[0] EQ '-')) then begin

    ;Check that "str" does not consist only of a "+" or "-" character and a decimal point
    if (nchar EQ 2L) then return, 'ERROR'

    ;Check that the remaining characters are numerical digits or a decimal point
    if (numarr_dp.hasvalue(chars[1L:nchar_m1]) EQ 0B) then return, 'ERROR'

    ;If the second character is a decimal point, then insert a zero before the decimal point
    if (dp_sub EQ 1L) then str_use = chars2str([chars[0], '0', chars[1L:nchar_m1]], stat, /NO_PAR_CHECK)

  ;If the first character is not a "+" or "-" character
  endif else begin

    ;Check that the characters in "str" are numerical digits or a decimal point
    if (numarr_dp.hasvalue(chars[0L:nchar_m1]) EQ 0B) then return, 'ERROR'

    ;If the first character is a decimal point, then insert a zero before the decimal point
    if (dp_sub EQ 0L) then str_use = chars2str(['0', chars[0L:nchar_m1]], stat, /NO_PAR_CHECK)
  endelse

  ;If the last character is a decimal point, then remove the decimal point
  if (dp_sub EQ nchar_m1) then str_use = chars2str(chars[0L:(nchar - 2L)], stat, /NO_PAR_CHECK)

  ;By reaching this point, "str" has passed all of the relevant format tests. The function will now return
  ;the formatted string.
  return, str_use
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;If "str" has no decimal point but has one of the characters "E" or "e"
if ((ndp EQ 0L) AND (nall_e EQ 1L)) then begin

  ;Check that "str" has at least 3 characters
  if (nchar LT 3L) then return, 'ERROR'

  ;If the first character is a "+" or "-" character
  if ((chars[0] EQ '+') OR (chars[0] EQ '-')) then begin

    ;Check that "str" has at least 4 characters
    if (nchar LT 4L) then return, 'ERROR'

    ;Check that the "E" or "e" character is not the first character after the "+" or "-" character, and
    ;that it is not the last character
    if (e_sub EQ 1L) then return, 'ERROR'
    if (e_sub EQ nchar_m1) then return, 'ERROR'

    ;Check that the characters between the "+" or "-" character and the "E" or "e" character are numerical
    ;digits only
    if (numarr.hasvalue(chars[1L:(e_sub - 1L)]) EQ 0B) then return, 'ERROR'

  ;If the first character is not a "+" or "-" character
  endif else begin

    ;Check that the "E" or "e" character is not the first or last character
    if (e_sub EQ 0L) then return, 'ERROR'
    if (e_sub EQ nchar_m1) then return, 'ERROR'

    ;Check that the characters before the "E" or "e" character are numerical digits only
    if (numarr.hasvalue(chars[0L:(e_sub - 1L)]) EQ 0B) then return, 'ERROR'
  endelse

  ;Check that the characters after the "E" or "e" character form a number without a decimal point
  nchar_after_e = nchar_m1 - e_sub
  if (nchar_after_e EQ 1L) then begin
    if (test_set_membership(chars[e_sub + 1L], numarr, /NO_PAR_CHECK) NE 1) then return, 'ERROR'
  endif else begin
    if (test_set_membership(chars[e_sub + 1L], [numarr, '+', '-'], /NO_PAR_CHECK) NE 1) then return, 'ERROR'
    if (numarr.hasvalue(chars[(e_sub + 2L):nchar_m1]) EQ 0B) then return, 'ERROR'
  endelse

  ;By reaching this point, "str" has passed all of the relevant format tests. The function will now return
  ;the formatted string.
  return, str_use
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;If "str" has a decimal point and one of the characters "E" or "e", then check that "str" has at least 4
;characters
if (nchar LT 4L) then return, 'ERROR'

;If the first character is a "+" or "-" character
if ((chars[0] EQ '+') OR (chars[0] EQ '-')) then begin

  ;Check that "str" has at least 5 characters
  if (nchar LT 5L) then return, 'ERROR'

  ;Check that the "E" or "e" character is not the first or second character after the "+" or "-" character,
  ;and that it is not the last character
  if (e_sub LT 3L) then return, 'ERROR'
  if (e_sub EQ nchar_m1) then return, 'ERROR'

  ;Check that the characters between the "+" or "-" character and the "E" or "e" character are numerical
  ;digits or a decimal point
  if (numarr_dp.hasvalue(chars[1L:(e_sub - 1L)]) EQ 0B) then return, 'ERROR'

  ;Check that the characters after the "E" or "e" character form a number without a decimal point
  nchar_after_e = nchar_m1 - e_sub
  if (nchar_after_e EQ 1L) then begin
    if (test_set_membership(chars[e_sub + 1L], numarr, /NO_PAR_CHECK) NE 1) then return, 'ERROR'
  endif else begin
    if (test_set_membership(chars[e_sub + 1L], [numarr, '+', '-'], /NO_PAR_CHECK) NE 1) then return, 'ERROR'
    if (numarr.hasvalue(chars[(e_sub + 2L):nchar_m1]) EQ 0B) then return, 'ERROR'
  endelse

  ;If the second character is a decimal point, then insert a zero before the decimal point
  if (dp_sub EQ 1L) then str_use = chars2str([chars[0], '0', chars[1L:nchar_m1]], stat, /NO_PAR_CHECK)

;If the first character is not a "+" or "-" character
endif else begin

  ;Check that the "E" or "e" character is not the first, second or last character
  if (e_sub LT 2L) then return, 'ERROR'
  if (e_sub EQ nchar_m1) then return, 'ERROR'

  ;Check that the characters before the "E" or "e" character are numerical digits or a decimal point
  if (numarr_dp.hasvalue(chars[0L:(e_sub - 1L)]) EQ 0B) then return, 'ERROR'

  ;Check that the characters after the "E" or "e" character form a number without a decimal point
  nchar_after_e = nchar_m1 - e_sub
  if (nchar_after_e EQ 1L) then begin
    if (test_set_membership(chars[e_sub + 1L], numarr, /NO_PAR_CHECK) NE 1) then return, 'ERROR'
  endif else begin
    if (test_set_membership(chars[e_sub + 1L], [numarr, '+', '-'], /NO_PAR_CHECK) NE 1) then return, 'ERROR'
    if (numarr.hasvalue(chars[(e_sub + 2L):nchar_m1]) EQ 0B) then return, 'ERROR'
  endelse

  ;If the first character is a decimal point, then insert a zero before the decimal point
  if (dp_sub EQ 0L) then str_use = chars2str(['0', chars[0L:nchar_m1]], stat, /NO_PAR_CHECK)
endelse

;If the last character before the "E" or "e" character is a decimal point, then remove the decimal point
if (dp_sub EQ (e_sub - 1L)) then str_use = chars2str([chars[0L:(e_sub - 2L)], chars[e_sub:nchar_m1]], stat, /NO_PAR_CHECK)

;By reaching this point, "str" has passed all of the relevant format tests. The function will now return
;the formatted string.
return, str_use

END
