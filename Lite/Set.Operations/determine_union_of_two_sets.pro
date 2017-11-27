PRO determine_union_of_two_sets, setA, setB, union, nunion

; Description: This module determines the set "union" formed by the union of the two input sets "setA"
;              and "setB". The output parameter "union" is returned as a vector of "nunion" unique
;              elements sorted into ascending order. If the input parameter "setB" is undefined, then
;              the module will treat "setB" as representing the empty set.
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
; Output Parameters:
;
;   union - VECTOR (same type as "setA") - A one-dimensional vector containing the unique elements
;                                          that make up the union of the two input sets "setA" and
;                                          "setB". The elements of this output parameter are sorted
;                                          into ascending order. If the module fails, then this
;                                          parameter is left undefined.
;   nunion - LONG - The number of elements in the output parameter "union". If the module succeeds
;                   in determining the union of the two input sets, then the value of this parameter
;                   is always greater than zero since the input parameter "setA" must be defined
;                   (i.e. "setA" must have at least one element). If the module fails, then this
;                   parameter is set to a value of "-1".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
nunion = -1L

;Check that "setA" is defined, and that it is not an IDL structure
setA_type = determine_idl_type_as_int(setA)
if ((setA_type EQ 0) OR (setA_type EQ 8)) then return

;If "setB" is undefined
setB_type = determine_idl_type_as_int(setB)
if (setB_type EQ 0) then begin

  ;The union of the input set "setA" with the empty set "setB" is equal to "setA". Therefore
  ;determine the unique elements of the input set "setA" sorted into ascending order.
  determine_unique_elements, setA, union, nunion

;If "setB" is defined
endif else begin

  ;Check that "setB" has the same variable type as "setA"
  if (setB_type NE setA_type) then return

  ;Determine the set "union" formed by the union of the two input sets "setA" and "setB"
  determine_unique_elements, [reform(setA, setA.length), reform(setB, setB.length)], union, nunion
endelse

END
