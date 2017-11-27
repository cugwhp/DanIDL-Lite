FUNCTION test_file_name_scalar, str, IGNORE_WHITE_SPACE = ignore_white_space, IGNORE_SPECIAL_CHARACTERS = ignore_special_characters

; Description: This function tests that the parameter "str" contains a scalar (single) string representing
;              a file name, where the file name can be specified with or without an absolute or relative
;              directory path. The function uses the following logic to determine if the parameter "str"
;              represents a file name:
;
;              (i) If "str" is the empty string, then "str" is not a file name.
;              (ii) If "str" consists solely of white space characters, then "str" is not a file name.
;              (iii) If "str" contains any white space characters other than leading or trailing white
;                    spaces, then "str" is not a file name.
;              (iv) If "str" contains any of the special characters "!", "@", "#", "$", "%", "^", "&", "*",
;                   "(", ")", "<", ">", ":", ";", """, "{", "}", "[", "]", "\", "|" and "?", then "str" is
;                   not a file name.
;              (v) If "str" ends with the character "/" (ignoring trailing white space characters), then
;                  "str" is not a file name.
;
;              The function also provides the option of skipping steps (iii) and/or (iv) if required by
;              setting the keywords IGNORE_WHITE_SPACE and/or IGNORE_SPECIAL_CHARACTERS, respectively.
;
;              N.B: The implementation in this function does not use any of the string methods ".trim",
;                   ".endswith" or ".contains" because these methods are slower for scalar strings by
;                   factors of ~3.4, ~1.3 and ~3.8, respectively.
;
; Input Parameters:
;
;   str - ANY - The parameter to be tested whether or not it satisfies the properties that a scalar (single)
;               string representing a file name would have.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "str" contains a string representing a file name,
;   and set to "0" if "str" does not contain a string representing a file name.
;
; Keywords:
;
;   If the keyword IGNORE_WHITE_SPACE is set (as "/IGNORE_WHITE_SPACE"), then the function will not test
;   whether "str" contains any white space characters other than leading or trailing white spaces (see
;   step (iii)).
;
;   If the keyword IGNORE_SPECIAL_CHARACTERS is set (as "/IGNORE_SPECIAL_CHARACTERS"), then the function
;   will not test whether "str" contains any of the special characters mentioned above (see step (iv)).
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Check that "str" is a scalar string
if (test_str_scalar(str) NE 1) then return, 0

;If "str" is the empty string or it consists solely of white space characters, then "str" is not a file
;name
str_use = strtrim(str, 2)
if (str_use EQ '') then return, 0

;If the keyword IGNORE_WHITE_SPACE is not set
if ~keyword_set(ignore_white_space) then begin

  ;If "str" contains any white space characters other than leading or trailing white spaces, then "str"
  ;is not a file name
  if (strpos(str_use, ' ') GE 0L) then return, 0
endif

;If the keyword IGNORE_SPECIAL_CHARACTERS is not set
if ~keyword_set(ignore_special_characters) then begin

  ;If "str" contains any of the special characters "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "<",
  ;">", ":", ";", """, "{", "}", "[", "]", "\", "|" and "?", then "str" is not a file name
  if (strpos(str_use, '!') GE 0L) then return, 0
  if (strpos(str_use, '@') GE 0L) then return, 0
  if (strpos(str_use, '#') GE 0L) then return, 0
  if (strpos(str_use, '$') GE 0L) then return, 0
  if (strpos(str_use, '%') GE 0L) then return, 0
  if (strpos(str_use, '^') GE 0L) then return, 0
  if (strpos(str_use, '&') GE 0L) then return, 0
  if (strpos(str_use, '*') GE 0L) then return, 0
  if (strpos(str_use, '(') GE 0L) then return, 0
  if (strpos(str_use, ')') GE 0L) then return, 0
  if (strpos(str_use, '<') GE 0L) then return, 0
  if (strpos(str_use, '>') GE 0L) then return, 0
  if (strpos(str_use, ':') GE 0L) then return, 0
  if (strpos(str_use, ';') GE 0L) then return, 0
  if (strpos(str_use, '"') GE 0L) then return, 0
  if (strpos(str_use, '{') GE 0L) then return, 0
  if (strpos(str_use, '}') GE 0L) then return, 0
  if (strpos(str_use, '[') GE 0L) then return, 0
  if (strpos(str_use, ']') GE 0L) then return, 0
  if (strpos(str_use, '\') GE 0L) then return, 0
  if (strpos(str_use, '|') GE 0L) then return, 0
  if (strpos(str_use, '?') GE 0L) then return, 0
endif

;If "str" does not end with the character "/" (ignoring trailing white space characters), then "str" is
;a file name
return, fix(strmid(str_use, 0, 1, /REVERSE_OFFSET) NE '/')

END
