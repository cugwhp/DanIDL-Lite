PRO split_string_at_nth_occurrence, str, split_char, split_point, outstr1, outstr2, noccur, status, REVERSE = reverse, NO_PAR_CHECK = no_par_check

; Description: This module splits a string "str" at the Nth occurrence of the character "split_char",
;              where the value of N is specified by the parameter "split_point". The two resultant
;              substrings are stored in the output strings "outstr1" and "outstr2", and the character
;              "split_char" is not included in either output string. The original string "str" may
;              therefore be reconstructed as follows:
;
;              str = outstr1 + split_char + outstr2
;
;                The number of occurrences of the character "split_char" in the input string "str"
;              is recorded in the output parameter "noccur". If the character "split_char" is not
;              present in "str", then "noccur" is set to "0", and the output strings are set to
;              empty strings.
;                The module also provides the option of counting N from the end of the input string
;              "str", instead of from the start of the input string, which is useful in the case
;              that the user wishes to split the string at the last occurrence (or last but one
;              occurrence, etc.) of the character "split_char".
;
;              N.B: The implementation in this module does not use the string method ".strlen"
;                   because this method is slower for scalar strings by a factor of ~7.4.
;
; Input Parameters:
;
;   str - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of strings, each
;                                      element of which is to be split into two substrings.
;   split_char - STRING - A single character string which represents the character to be used to
;                         determine the position at which to split each element of "str". It is
;                         perfectly acceptable for this character to be a single white space.
;   split_point - INTEGER/LONG - This parameter specifies the value of N such that the module
;                                splits each string element of "str" into two substrings at the
;                                Nth occurrence of the character "split_char". This parameter
;                                must be positive. If the keyword REVERSE is set (as "/REVERSE"),
;                                then setting "split_point" equal to "1" would instruct the module
;                                to split the string elements at the last occurrence of the
;                                character "split_char", and setting "split_point" equal to "2"
;                                would instruct the module to split the string elements at the
;                                last but one occurrence of the character "split_char", and so on.
;                                If there are less than N occurrences of the character "split_char"
;                                in a string element of "str", then it is assumed that for the
;                                string element in question the value of N is equal to the number
;                                of occurrences of "split_char", which means that the module will
;                                split the string element at the last occurrence of "split_char"
;                                (or at the first occurrence of "split_char" if the keyword REVERSE
;                                is set).
;
; Output Parameters:
;
;   outstr1 - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array of substrings, of the same
;                                          dimensions as "str", that contains the set of left hand
;                                          substrings obtained by splitting the string elements of
;                                          "str" at the Nth occurrence of the character
;                                          "split_char". Elements of this parameter are set to
;                                          empty strings where the Nth occurrence of the character
;                                          "split_char" is the first character in the corresponding
;                                          string element of "str", and where the character
;                                          "split_char" is not present in the corresponding string
;                                          element of "str".
;   outstr2 - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array of substrings, of the same
;                                          dimensions as "str", that contains the set of right
;                                          hand substrings obtained by splitting the string
;                                          elements of "str" at the Nth occurrence of the character
;                                          "split_char". Elements of this parameter are set to
;                                          empty strings where the Nth occurrence of the character
;                                          "split_char" is the last character in the corresponding
;                                          string element of "str", and where the character
;                                          "split_char" is not present in the corresponding string
;                                          element of "str".
;   noccur - LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of the same dimensions as "str"
;                                       specifying the number of occurrences of the character
;                                       "split_char" in each element of "str".
;   status - INTEGER - If the function successfully split the input string(s), then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword REVERSE is set (as "/REVERSE"), then the module will count N from the end of
;   each string element of "str", instead of from the start of each string element, which is
;   useful in the case that the user wishes to split each string element at the last occurrence
;   (or last but one occurrence, etc.) of the character "split_char".
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform
;   parameter checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
outstr1 = ''
outstr2 = ''
noccur = 0L
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "str" is a variable of string type
  if (test_str(str) NE 1) then return

  ;Check that "split_char" is a scalar string with exactly one character
  if (test_str_scalar(split_char) NE 1) then return
  if (strlen(split_char) NE 1L) then return

  ;Check that "split_point" is a positive number of the correct type
  if (test_intlon_scalar(split_point) NE 1) then return
  if (split_point LT 1) then return
endif
nstr = str.length
split_point_use = long(split_point)

;Set up the output arrays of left-hand and right-hand substrings
outstr1 = strarr(nstr)
outstr2 = strarr(nstr)

;Set up the output array "noccur"
noccur = lonarr(nstr)

;For each string element of "str"
for i = 0L,(nstr - 1L) do begin

  ;Extract the current string element of "str"
  cstr = str[i]

  ;If the current string element of "str" is an empty string, then no string processing is
  ;necessary
  if (cstr EQ '') then continue

  ;Decompose the current string element of "str" into individual characters
  chars = str2chars(cstr, stat, /NO_PAR_CHECK)

  ;Find the occurrences of the character "split_char" in the current string element of "str"
  subs = where(chars EQ split_char, nsubs)

  ;If the character "split_char" is not present in the current string element of "str", then
  ;no string processing is necessary
  if (nsubs EQ 0L) then continue

  ;Record the number of occurrences of the character "split_char" in the current string element
  ;of "str"
  noccur[i] = nsubs

  ;Determine at which occurrence of the character "split_char" the current string element should
  ;be split
  if keyword_set(reverse) then begin
    split_sub = subs[(nsubs - split_point_use) > 0L]
  endif else split_sub = subs[(split_point_use < nsubs) - 1L]

  ;If the substring to the left of the character where the current string element should be split
  ;is non-empty, then extract the substring
  if (split_sub GT 0L) then outstr1[i] = chars2str(chars[0L:(split_sub - 1L)], stat, /NO_PAR_CHECK)

  ;If the substring to the right of the character where the current string element should be split
  ;is non-empty, then extract the substring
  nchar_m1 = chars.length - 1L
  if (split_sub LT nchar_m1) then outstr2[i] = chars2str(chars[(split_sub + 1L):nchar_m1], stat, /NO_PAR_CHECK)
endfor

;Set "status" to "1"
status = 1

;Force the dimensions of the output parameters "outstr1", "outstr2" and "noccur" to match the
;dimensions of the input parameter "str"
if (str.ndim EQ 0L) then begin
  outstr1 = outstr1[0]
  outstr2 = outstr2[0]
  noccur = noccur[0]
endif else begin
  size_str = str.dim
  outstr1 = reform(outstr1, size_str, /OVERWRITE)
  outstr2 = reform(outstr2, size_str, /OVERWRITE)
  noccur = reform(noccur, size_str, /OVERWRITE)
endelse

END
