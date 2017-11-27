PRO filter_lines, lines, compare_str, lines_out, nlines_out, status, SKIP = skip, STARTING = starting, ENDING = ending, NO_PAR_CHECK = no_par_check

; Description: This module filters the set of strings "lines" keeping only those strings in "lines"
;              that have at least one occurrence of any non-empty substring drawn from the set of
;              comparison substrings "compare_str". The filtered set of strings is returned via the
;              parameter "lines_out" along with the number of strings in "lines_out" via the
;              parameter "nlines_out".
;                The module also provides the alternative filtering option of keeping only those
;              strings in "lines" that do not have any occurrence of any non-empty substring drawn
;              from the set of comparison substrings "compare_str" via the use of the keyword SKIP.
;                Finally, the module provides the options of only searching for occurrences of any
;              non-empty substring drawn from "compare_str" at the start and/or the end of each
;              string in "lines" via the use of the keywords STARTING and/or ENDING.
;
;              N.B: The implementation in this module does not use the string method ".contains"
;                   because it is slower for both scalar strings and vectors/arrays of strings.
;
; Input Parameters:
;
;   lines - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing the set of strings to be
;                                        filtered.
;   compare_str - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of substrings
;                                              to be used to filter the strings in the input
;                                              parameter "lines". Substrings that are empty strings
;                                              will be ignored during the filtering process.
;
; Output Parameters:
;
;   lines_out - STRING VECTOR - A vector of strings containing the filtered set of strings. The
;                               elements of this parameter are the strings from the input parameter
;                               "lines" that have at least one occurrence of any non-empty
;                               substring drawn from the substrings in the input parameter
;                               "compare_str". Alternatively, if the keyword SKIP is set, then the
;                               elements of this parameter are the strings from "lines" that do
;                               not have any occurrence of any non-empty substring drawn from
;                               "compare_str". If the keyword STARTING is set, then the module will
;                               only search for occurrences of any non-empty substring drawn from
;                               "compare_str" at the start of each string in "lines". If the
;                               keyword ENDING is set, then the module will only search for
;                               occurrences of any non-empty substring drawn from "compare_str" at
;                               the end of each string in "lines". By setting both of the keywords
;                               STARTING and ENDING at the same time, then the module will only
;                               search for occurrences of any non-empty substring drawn from
;                               "compare_str" at the start and the end of each string in "lines".
;   nlines_out - LONG - The number of strings in the output parameter "lines_out". If all of the
;                       strings from "lines" are filtered out, then this parameter is returned with
;                       a value of "0".
;   status - INTEGER - If the module successfully filtered the set of strings "lines", then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of
;                      "0".
;
; Keywords:
;
;   If the keyword SKIP is set (as "/SKIP"), then the module will perform an alternative filtering of
;   the strings in "lines" by keeping only those strings in "lines" that do not have any occurrence
;   of any non-empty substring drawn from the set of comparison substrings "compare_str".
;
;   If the keyword STARTING is set (as "/STARTING"), then the module will only search for occurrences
;   of any non-empty substring drawn from the set of comparison substrings "compare_str" at the start
;   of each string in "lines". If the keyword ENDING is set at the same time as this keyword, then
;   the module will only search for occurrences of any non-empty substring drawn from "compare_str"
;   at the start and the end of each string in "lines".
;
;   If the keyword ENDING is set (as "/ENDING"), then the module will only search for occurrences of
;   any non-empty substring drawn from the set of comparison substrings "compare_str" at the end of
;   each string in "lines". If the keyword STARTING is set at the same time as this keyword, then the
;   module will only search for occurrences of any non-empty substring drawn from "compare_str" at
;   the start and the end of each string in "lines".
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform
;   parameter checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
lines_out = ''
nlines_out = 0L
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "lines" is a variable of string type
  if (test_str(lines) NE 1) then return

  ;Check that "compare_str" is a variable of string type
  if (test_str(compare_str) NE 1) then return
endif

;Set up the output parameters
nlines_out = lines.length
lines_out = reform(lines, nlines_out)

;Set "status" to "1"
status = 1

;Determine the set of non-empty substrings in "compare_str" to be tested for their presence in each
;string in "lines"
subs = where(compare_str NE '', ncompare_str)

;If all of the elements of "compare_str" are empty strings, then do not perform any filtering of the
;strings in "lines" and return
if (ncompare_str EQ 0L) then return

;Determine the set of unique non-empty substrings in "compare_str" to be tested for their presence
;in each string in "lines"
determine_unique_elements, compare_str[subs], compare_str_use, ncompare_str

;If the keyword SKIP is set
if keyword_set(skip) then begin

  ;For each unique non-empty substring in "compare_str" to be tested for its presence in each string
  ;in "lines"
  for i = 0L,(ncompare_str - 1L) do begin

    ;Determine which strings in "lines" do not have any occurrence in the specified position(s) of
    ;the current substring from "compare_str"
    curr_compare_str = compare_str_use[i]
    if keyword_set(ending) then begin
      if keyword_set(starting) then begin
        subs = where((lines_out.startswith(curr_compare_str) EQ 0B) AND (lines_out.endswith(curr_compare_str) EQ 0B), nsubs)
      endif else subs = where(lines_out.endswith(curr_compare_str) EQ 0B, nsubs)
    endif else begin
      if keyword_set(starting) then begin
        subs = where(lines_out.startswith(curr_compare_str) EQ 0B, nsubs)
      endif else subs = where(strpos(lines_out, curr_compare_str) EQ -1L, nsubs)
    endelse

    ;If none of the strings from "lines" have been filtered out using the current substring from
    ;"compare_str", then continue to filter the strings from "lines" using the next substring
    if (nsubs EQ nlines_out) then continue

    ;If all of the strings from "lines" have been filtered out using the current substring from
    ;"compare_str", then return with "nlines_out" set to a value of "0"
    if (nsubs EQ 0L) then begin
      lines_out = ''
      nlines_out = 0L
      return
    endif

    ;Update the filtered set of strings from "lines"
    lines_out = lines_out[subs]
    nlines_out = nsubs
  endfor

  ;At this stage, the set of strings "lines" has been filtered appropriately using the non-empty
  ;substrings from "compare_str" and the module will return
  return
endif

;The rest of the code deals with the case that the keyword SKIP is not set. For each unique non-empty
;substring in "compare_str" to be tested for its presence in each string in "lines".
subs = [-1L]
nsubs = 1L
for i = 0L,(ncompare_str - 1L) do begin

  ;Determine which strings in "lines" have at least one occurrence in the specified position(s) of
  ;the current substring from "compare_str"
  curr_compare_str = compare_str_use[i]
  if keyword_set(ending) then begin
    if keyword_set(starting) then begin
      tmp_subs = where((lines_out.startswith(curr_compare_str) EQ 1B) OR (lines_out.endswith(curr_compare_str) EQ 1B), ntmp_subs)
    endif else tmp_subs = where(lines_out.endswith(curr_compare_str) EQ 1B, ntmp_subs)
  endif else begin
    if keyword_set(starting) then begin
      tmp_subs = where(lines_out.startswith(curr_compare_str) EQ 1B, ntmp_subs)
    endif else tmp_subs = where(strpos(lines_out, curr_compare_str) NE -1L, ntmp_subs)
  endelse

  ;If none of the strings from "lines" have at least one occurrence in the specified position(s) of
  ;the current substring from "compare_str", then continue to filter the strings from "lines" using
  ;the next substring
  if (ntmp_subs EQ 0L) then continue

  ;If at least one of the strings from "lines" has at least one occurrence in the specified
  ;position(s) of the current substring from "compare_str", then save the subscripts of the relevant
  ;strings from "lines"
  determine_union_of_two_sets, subs, tmp_subs, new_subs, nsubs
  subs = temporary(new_subs)

  ;If all of the strings in "lines" have at least one occurrence in the specified position(s) of
  ;any of the substrings from "compare_str" that have been considered so far, then the module will
  ;return
  if (nsubs GT nlines_out) then return
endfor

;Filter the strings in "lines" as required
nlines_out = nsubs - 1L
if (nlines_out GT 0L) then begin
  lines_out = lines_out[subs[1L:nlines_out]]
endif else lines_out = ''

END
