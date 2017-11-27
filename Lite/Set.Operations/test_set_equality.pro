FUNCTION test_set_equality, setA, setB, SETA_ALREADY_SORTED = setA_already_sorted, SETA_UNIQUE_ELEMENTS = setA_unique_elements, SETB_ALREADY_SORTED = setB_already_sorted, $
                                        SETB_UNIQUE_ELEMENTS = setB_unique_elements

; Description: This function tests that the set "setA" is equal to the set "setB". In other words,
;              the function tests that the two sets "setA" and "setB" have exactly the same elements.
;              If the input parameter "setB" is undefined, then the function will treat "setB" as
;              representing the empty set.
;
; Input Parameters:
;
;   setA - ANY SCALAR/VECTOR/ARRAY - A scalar/vector/array containing the elements of the first set.
;                                    This parameter must be defined, and not an IDL structure.
;   setB - ANY SCALAR/VECTOR/ARRAY - A scalar/vector/array containing the elements of the second set.
;                                    This parameter must either have the same variable type as the
;                                    input parameter "setA", or it must be undefined, in which case
;                                    it is treated as representing the empty set.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if the set "setA" is equal to the set "setB",
;   set to "0" if the set "setA" is not equal to the set "setB", and set to "-1" if the function
;   fails.
;
; Keywords:
;
;   If the keyword SETA_ALREADY_SORTED is set (as "/SETA_ALREADY_SORTED"), then the function will
;   assume that the elements in "setA" are sorted into ascending order. This option can be used to
;   avoid unnecessary processing of the input parameter "setA", which allows the user to build more
;   efficient code with this function.
;
;   If the keyword SETA_UNIQUE_ELEMENTS is set (as "/SETA_UNIQUE_ELEMENTS"), then the function will
;   assume that all of the elements in "setA" are unique. This option can be used to avoid
;   unnecessary processing of the input parameter "setA", which allows the user to build more
;   efficient code with this function.
;
;   If the keyword SETB_ALREADY_SORTED is set (as "/SETB_ALREADY_SORTED"), then the function will
;   assume that the elements in "setB" are sorted into ascending order. This option can be used to
;   avoid unnecessary processing of the input parameter "setB", which allows the user to build more
;   efficient code with this function.
;
;   If the keyword SETB_UNIQUE_ELEMENTS is set (as "/SETB_UNIQUE_ELEMENTS"), then the function will
;   assume that all of the elements in "setB" are unique. This option can be used to avoid
;   unnecessary processing of the input parameter "setB", which allows the user to build more
;   efficient code with this function.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Check that "setA" is defined, and that it is not an IDL structure
setA_type = determine_idl_type_as_int(setA)
if ((setA_type EQ 0) OR (setA_type EQ 8)) then return, -1

;If "setB" is undefined, then treat "setB" as representing the empty set. In this case, the fact
;that "setA" has at least one element means that it cannot be equal to the empty set "setB", and
;the function will return a value of "0".
setB_type = determine_idl_type_as_int(setB)
if (setB_type EQ 0) then return, 0

;The rest of the code deals with the case that "setB" is defined. Check that "setB" has the same
;variable type as "setA".
if (setB_type NE setA_type) then return, -1

;If the keyword SETA_UNIQUE_ELEMENTS is set
if keyword_set(setA_unique_elements) then begin

  ;Determine the number of unique elements in "setA"
  nsetA_unique = setA.length

;If the keyword SETA_UNIQUE_ELEMENTS is not set
endif else begin

  ;Determine the set of unique elements in "setA" along with the number of unique elements
  determine_unique_elements, setA, setA_unique, nsetA_unique, DATA_ALREADY_SORTED = setA_already_sorted
endelse

;If the number of unique elements in "setA" is greater than the number of elements in "setB", then
;"setA" is not equal to "setB", and the function will return a value of "0"
nsetB_unique = setB.length
if (nsetA_unique GT nsetB_unique) then return, 0

;If the keyword SETB_UNIQUE_ELEMENTS is not set
if ~keyword_set(setB_unique_elements) then begin

  ;Determine the set of unique elements in "setB" along with the number of unique elements
  determine_unique_elements, setB, setB_unique, nsetB_unique, DATA_ALREADY_SORTED = setB_already_sorted
endif

;If the number of unique elements in "setA" is not equal to the number of unique elements in "setB",
;then "setA" is not equal to "setB", and the function will return a value of "0"
if (nsetA_unique NE nsetB_unique) then return, 0

;If the keyword SETA_UNIQUE_ELEMENTS is set, then sort the elements of "setA" if necessary
if keyword_set(setA_unique_elements) then begin
  if keyword_set(setA_already_sorted) then begin
    setA_unique = setA
  endif else setA_unique = setA[sort(setA)]
endif

;If the keyword SETB_UNIQUE_ELEMENTS is set, then sort the elements of "setB" if necessary
if keyword_set(setB_unique_elements) then begin
  if keyword_set(setB_already_sorted) then begin
    setB_unique = setB
  endif else setB_unique = setB[sort(setB)]
endif

;Directly compare the unique elements of the two sets when they are both ordered in ascending order.
;Since both sets have the same number of unique elements, the set "setA" is equal to the set "setB"
;if and only if all of the unique elements in "setA" match the corresponding unique elements in
;"setB" when they are both ordered in ascending order.
return, fix(array_equal(setA_unique, setB_unique))

END
