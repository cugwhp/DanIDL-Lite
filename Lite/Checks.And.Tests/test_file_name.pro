FUNCTION test_file_name, str, status, IGNORE_WHITE_SPACE = ignore_white_space, IGNORE_SPECIAL_CHARACTERS = ignore_special_characters, NO_PAR_CHECK = no_par_check

; Description: This function tests that the parameter "str" contains a set of strings that represent file
;              names, where the file names can be specified with or without absolute or relative directory
;              paths. The function uses the following logic to determine if an element of the parameter
;              "str" represents a file name:
;
;              (i) If an element of "str" is the empty string, then this element is not a file name.
;              (ii) If an element of "str" consists solely of white space characters, then this element is
;                   not a file name.
;              (iii) If an element of "str" contains any white space characters other than leading or
;                    trailing white spaces, then this element is not a file name.
;              (iv) If an element of "str" contains any of the special characters "!", "@", "#", "$", "%",
;                   "^", "&", "*", "(", ")", "<", ">", ":", ";", """, "{", "}", "[", "]", "\", "|" and "?",
;                   then this element is not a file name.
;              (v) If an element of "str" ends with the character "/" (ignoring trailing white space
;                  characters), then this element is not a file name.
;
;              The function also provides the option of skipping steps (iii) and/or (iv) if required by
;              setting the keywords IGNORE_WHITE_SPACE and/or IGNORE_SPECIAL_CHARACTERS, respectively.
;
;              N.B: The implementation in this function does not use any of the string methods ".trim",
;                   ".endswith" or ".contains" for the following reasons. The ".trim" method is slower
;                   for scalar strings, and offers no speed improvements for vectors/arrays of strings.
;                   The method ".endswith" is slower for scalar strings but faster for vectors/arrays of
;                   strings. Finally, the method ".contains" is slower for both scalar strings and
;                   vectors/arrays of strings.
;
; Input Parameters:
;
;   str - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of strings to be tested for
;                                      satisfying the properties that a string representing a file name
;                                      would have.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input string(s), then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns an INTEGER type variable, with the same dimensions as the input parameter "str".
;   If an element of "str" is a string representing a file name, then the corresponding element of the
;   return variable is set to "1", otherwise it is set to "0".
;
; Keywords:
;
;   If the keyword IGNORE_WHITE_SPACE is set (as "/IGNORE_WHITE_SPACE"), then the function will not test
;   whether an element of "str" contains any white space characters other than leading or trailing white
;   spaces (see step (iii)).
;
;   If the keyword IGNORE_SPECIAL_CHARACTERS is set (as "/IGNORE_SPECIAL_CHARACTERS"), then the function
;   will not test whether an element of "str" contains any of the special characters mentioned above (see
;   step (iv)).
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
  if (test_str(str) NE 1) then return, 0
endif

;Remove any leading or trailing white space from the elements of "str"
str_use = strtrim(str, 2)

;Set "status" to "1"
status = 1

;If the keyword IGNORE_WHITE_SPACE is set
if keyword_set(ignore_white_space) then begin

  ;If the keyword IGNORE_SPECIAL_CHARACTERS is set
  if keyword_set(ignore_special_characters) then begin

    ;Calculate and return the results of the file name test on the elements of "str"
    return, fix((str_use NE '') AND (strmid(str_use, 0, 1, /REVERSE_OFFSET) NE '/'))

  ;If the keyword IGNORE_SPECIAL_CHARACTERS is not set
  endif else begin

    ;Calculate and return the results of the file name test on the elements of "str"
    return, fix((str_use NE '') AND (strmid(str_use, 0, 1, /REVERSE_OFFSET) NE '/') AND (strpos(str_use, '!') EQ -1L) AND (strpos(str_use, '@') EQ -1L) AND $
                (strpos(str_use, '#') EQ -1L) AND (strpos(str_use, '$') EQ -1L) AND (strpos(str_use, '%') EQ -1L) AND (strpos(str_use, '^') EQ -1L) AND $
                (strpos(str_use, '&') EQ -1L) AND (strpos(str_use, '*') EQ -1L) AND (strpos(str_use, '(') EQ -1L) AND (strpos(str_use, ')') EQ -1L) AND $
                (strpos(str_use, '<') EQ -1L) AND (strpos(str_use, '>') EQ -1L) AND (strpos(str_use, ':') EQ -1L) AND (strpos(str_use, ';') EQ -1L) AND $
                (strpos(str_use, '"') EQ -1L) AND (strpos(str_use, '{') EQ -1L) AND (strpos(str_use, '}') EQ -1L) AND (strpos(str_use, '[') EQ -1L) AND $
                (strpos(str_use, ']') EQ -1L) AND (strpos(str_use, '\') EQ -1L) AND (strpos(str_use, '|') EQ -1L) AND (strpos(str_use, '?') EQ -1L))
  endelse

;If the keyword IGNORE_WHITE_SPACE is not set
endif else begin

  ;If the keyword IGNORE_SPECIAL_CHARACTERS is set
  if keyword_set(ignore_special_characters) then begin

    ;Calculate and return the results of the file name test on the elements of "str"
    return, fix((str_use NE '') AND (strpos(str_use, ' ') EQ -1L) AND (strmid(str_use, 0, 1, /REVERSE_OFFSET) NE '/'))

  ;If the keyword IGNORE_SPECIAL_CHARACTERS is not set
  endif else begin

    ;Calculate and return the results of the file name test on the elements of "str"
    return, fix((str_use NE '') AND (strpos(str_use, ' ') EQ -1L) AND (strmid(str_use, 0, 1, /REVERSE_OFFSET) NE '/') AND $
                (strpos(str_use, '!') EQ -1L) AND (strpos(str_use, '@') EQ -1L) AND (strpos(str_use, '#') EQ -1L) AND (strpos(str_use, '$') EQ -1L) AND $
                (strpos(str_use, '%') EQ -1L) AND (strpos(str_use, '^') EQ -1L) AND (strpos(str_use, '&') EQ -1L) AND (strpos(str_use, '*') EQ -1L) AND $
                (strpos(str_use, '(') EQ -1L) AND (strpos(str_use, ')') EQ -1L) AND (strpos(str_use, '<') EQ -1L) AND (strpos(str_use, '>') EQ -1L) AND $
                (strpos(str_use, ':') EQ -1L) AND (strpos(str_use, ';') EQ -1L) AND (strpos(str_use, '"') EQ -1L) AND (strpos(str_use, '{') EQ -1L) AND $
                (strpos(str_use, '}') EQ -1L) AND (strpos(str_use, '[') EQ -1L) AND (strpos(str_use, ']') EQ -1L) AND (strpos(str_use, '\') EQ -1L) AND $
                (strpos(str_use, '|') EQ -1L) AND (strpos(str_use, '?') EQ -1L))
  endelse
endelse

END
