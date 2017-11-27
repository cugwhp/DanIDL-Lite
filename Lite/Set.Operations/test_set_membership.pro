FUNCTION test_set_membership, element, setA, SETA_ALREADY_SORTED = setA_already_sorted, NO_PAR_CHECK = no_par_check

; Description: This function tests that the parameter "element" is a scalar variable with a value
;              that is an element of the set "setA". Since the elements of "setA" are not necessarily
;              pre-sorted, the function will use a linear search algorithm with O(N) performance to
;              find "element" in "setA". The alternative method of sorting the elements of "setA"
;              into ascending order (with O(N*log(N)) performance) and then using a binary search
;              algorithm to find "element" in "setA" (with O(log(N)) performance) has an overall
;              performance of O(N*log(N)), which is worse than the O(N) performance of the linear
;              search algorithm.
;                In the case that the elements of "setA" are already sorted into ascending order, it
;              is generally more efficient to use a binary search algorithm with O(log(N)) performance
;              to find "element" in "setA". By setting the keyword SETA_ALREADY_SORTED, the function
;              will assume that the elements of "setA" are sorted into ascending order, and it will
;              use the binary search algorithm to find "element" in "setA". Note that for sets with
;              less than ~1000 elements, it is still more efficient to use the linear search algorithm
;              because of the efficiency of vector operations in IDL, and in these cases it is
;              recommended not to set the keyword SETA_ALREADY_SORTED.
;
; Input Parameters:
;
;   element - ANY SCALAR - A scalar variable to be tested if its value is an element of the set "setA".
;                          This parameter must be defined, and not an IDL structure.
;   setA - ANY SCALAR/VECTOR/ARRAY - A scalar/vector/array containing the elements of the set which
;                                    is to be tested for the presence of the element specified by
;                                    the input parameter "element". This parameter must have the
;                                    same variable type as the input parameter "element".
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "element" has a value that is an element of
;   the set "setA", set to "0" if "element" has a value that is not an element of the set "setA",
;   and set to "-1" if the function fails.
;
; Keywords:
;
;   If the keyword SETA_ALREADY_SORTED is set (as "/SETA_ALREADY_SORTED"), then the function will
;   assume that the elements in "setA" are sorted into ascending order. In this case, the function
;   will use a binary search algorithm with an O(log(N)) performance to find "element" in "setA",
;   as opposed to a linear search algorithm with an O(N) performance, which allows the user to
;   build more efficient code with this function.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform
;   parameter checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "element" is a scalar, and that it is not an IDL structure
  result = size(element)
  if (result[0] NE 0L) then return, -1

  ;Check that "element" is defined
  element_type = result[1]
  if (element_type EQ 0L) then return, -1

  ;Check that "setA" has the same variable type as "element"
  if (size(setA, /TYPE) NE element_type) then return, -1
endif

;If the keyword SETA_ALREADY_SORTED is set
if keyword_set(setA_already_sorted) then begin

  ;Use a binary search algorithm with an O(log(N)) performance to find "element" in "setA". Note
  ;that the keyword V2_UNIQUE_ELEMENTS is used in the call to the DanIDL module "binary_search.pro"
  ;because this function does not need the exact number of matches or the range of matching
  ;subscripts usually returned by "binary_search.pro".
  binary_search, element, setA, nmatch, lo_ind, hi_ind, /V2_UNIQUE_ELEMENTS, /NO_PAR_CHECK

  ;Return the result of the binary search
  return, fix(nmatch)
endif

;Use a linear search algorithm with an O(N) performance to find "element" in "setA"
return, fix(array_equal(element, setA, /NOT_EQUAL) EQ 0B)

END
