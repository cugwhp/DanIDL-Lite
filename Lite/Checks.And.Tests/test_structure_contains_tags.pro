FUNCTION test_structure_contains_tags, struct, tags, ONLY_TAGS = only_tags

; Description: This function tests that the parameter "struct" is an IDL structure, and that the structure
;              contains the tag names specified by "tags". The function provides the option to further test
;              that the tag names specified by "tags" are the only tag names present in the structure.
;
; Input Parameters:
;
;   struct - ANY - The parameter to be tested whether or not it is an IDL structure that contains the tag
;                  names "tags".
;   tags - STRING SCALAR/VECTOR/ARRAY - The set of tag names to be tested for their presence in the input
;                                       parameter "struct". Elements of this parameter that are empty
;                                       strings are ignored in the tests performed.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "struct" is an IDL structure that contains the tag
;   names "tags", and set to "0" otherwise.
;
; Keywords:
;
;   If the keyword ONLY_TAGS is set (as "/ONLY_TAGS"), then the function will make the further check that
;   the tag names "tags" are the only tags present in the input parameter "struct". If "struct" fails this
;   test, then the return value of the function is set to "0".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Check that "struct" is an IDL structure
if (test_structure(struct) NE 1) then return, 0

;Check that "tags" is of string type
if (test_str(tags) NE 1) then return, 0

;Extract the tag names from "struct"
struct_tags = tag_names(struct)

;Determine the unique set of tag names in "tags"
determine_unique_elements, strupcase(tags), tags_use, ntags

;For each unique tag name in "tags" to be tested for its presence in "struct"
count = 0L
for i = 0L,(ntags - 1L) do begin

  ;Check that the current tag name is not an empty string
  ctag = tags_use[i]
  if (ctag EQ '') then continue

  ;If the current tag name is not present in the structure "struct", then return a value of "0"
  if (test_set_membership(ctag, struct_tags, /NO_PAR_CHECK) NE 1) then return, 0

  ;Update the number of tag names from "tags" that are present in "struct"
  count = count + 1L
endfor

;If required, check that the tag names in "tags" are the only tag names present in the structure "struct"
if keyword_set(only_tags) then begin
  if (count NE struct_tags.length) then return, 0
endif

;If "struct" has passed all of the tests, then return a value of "1"
return, 1

END
