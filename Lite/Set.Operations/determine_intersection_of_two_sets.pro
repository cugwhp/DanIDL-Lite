PRO determine_intersection_of_two_sets, setA, setB, intersection, nintersection, SETA_ALREADY_SORTED = setA_already_sorted, SETA_UNIQUE_ELEMENTS = setA_unique_elements, $
                                        SETB_ALREADY_SORTED = setB_already_sorted, SETB_UNIQUE_ELEMENTS = setB_unique_elements

; Description: This module determines the set "intersection" formed by the intersection of the two
;              input sets "setA" and "setB". The output parameter "intersection" is returned as a
;              vector of "nintersection" unique elements sorted into ascending order. If the input
;              parameter "setB" is undefined, then the module will treat "setB" as representing the
;              empty set. If the intersection of the two input sets is the empty set, then the
;              output parameter "intersection" is left undefined and "nintersection" is set to a
;              value of "0".
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
;   intersection - VECTOR (same type as "setA") - A one-dimensional vector containing the unique
;                                                 elements that make up the intersection of the two
;                                                 input sets "setA" and "setB". The elements of
;                                                 this output parameter are sorted into ascending
;                                                 order. If the intersection of the two input sets
;                                                 is the empty set, or if the module fails, then
;                                                 this parameter is left undefined.
;   nintersection - LONG - The number of elements in the output parameter "intersection". If the
;                          intersection of the two input sets is the empty set, then this parameter
;                          is set to a value of "0". If the module fails, then this parameter is set
;                          to a value of "-1".
;
; Keywords:
;
;   If the keyword SETA_ALREADY_SORTED is set (as "/SETA_ALREADY_SORTED"), then the module will
;   assume that the elements in "setA" are sorted into ascending order. This option can be used to
;   avoid unnecessary processing of the input parameter "setA", which allows the user to build more
;   efficient code with this module.
;
;   If the keyword SETA_UNIQUE_ELEMENTS is set (as "/SETA_UNIQUE_ELEMENTS"), then the module will
;   assume that all of the elements in "setA" are unique. This option can be used to avoid
;   unnecessary processing of the input parameter "setA", which allows the user to build more
;   efficient code with this module.
;
;   If the keyword SETB_ALREADY_SORTED is set (as "/SETB_ALREADY_SORTED"), then the module will
;   assume that the elements in "setB" are sorted into ascending order. This option can be used to
;   avoid unnecessary processing of the input parameter "setB", which allows the user to build more
;   efficient code with this module.
;
;   If the keyword SETB_UNIQUE_ELEMENTS is set (as "/SETB_UNIQUE_ELEMENTS"), then the module will
;   assume that all of the elements in "setB" are unique. This option can be used to avoid
;   unnecessary processing of the input parameter "setB", which allows the user to build more
;   efficient code with this module.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
nintersection = -1L

;Check that "setA" is defined, and that it is not an IDL structure
setA_type = determine_idl_type_as_int(setA)
if ((setA_type EQ 0) OR (setA_type EQ 8)) then return

;If "setB" is undefined
setB_type = determine_idl_type_as_int(setB)
if (setB_type EQ 0) then begin

  ;The intersection of the input set "setA" with the empty set "setB" is equal to the empty set.
  ;Therefore set the output parameter "nintersection" to a value of "0" and leave the output
  ;parameter "intersection" undefined.
  nintersection = 0L

;If "setB" is defined
endif else begin

  ;Check that "setB" has the same variable type as "setA"
  if (setB_type NE setA_type) then return

  ;Determine the unique elements of the input set "setA" sorted into ascending order
  if keyword_set(setA_unique_elements) then begin
    nsetA_unique = setA.length
    if keyword_set(setA_already_sorted) then begin
      setA_unique = setA
    endif else setA_unique = setA[sort(setA)]
  endif else determine_unique_elements, setA, setA_unique, nsetA_unique, DATA_ALREADY_SORTED = setA_already_sorted

  ;Determine the unique elements of the input set "setB" sorted into ascending order
  if keyword_set(setB_unique_elements) then begin
    nsetB_unique = setB.length
    if keyword_set(setB_already_sorted) then begin
      setB_unique = setB
    endif else setB_unique = setB[sort(setB)]
  endif else determine_unique_elements, setB, setB_unique, nsetB_unique, DATA_ALREADY_SORTED = setB_already_sorted

  ;Determine the set "intersection" formed by the intersection of the two input sets "setA" and
  ;"setB". If the intersection of the two input sets is the empty set, then set the output
  ;parameter "nintersection" to a value of "0" and leave the output parameter "intersection"
  ;undefined. Note that it is faster to perform the binary search in the DanIDL module
  ;"find_elements_in_set.pro" less times on the larger set than it is to peform the binary
  ;search more times on the smaller set.
  if (nsetA_unique LE nsetB_unique) then begin
    find_elements_in_set, setA_unique, setB_unique, nmatch, lo_ind, hi_ind, stat, /V1_ALREADY_SORTED, /V2_UNIQUE_ELEMENTS, /NO_PAR_CHECK
    subs = where(nmatch GT 0L, nintersection)
    if (nintersection GT 0L) then intersection = setA_unique[subs]
  endif else begin
    find_elements_in_set, setB_unique, setA_unique, nmatch, lo_ind, hi_ind, stat, /V1_ALREADY_SORTED, /V2_UNIQUE_ELEMENTS, /NO_PAR_CHECK
    subs = where(nmatch GT 0L, nintersection)
    if (nintersection GT 0L) then intersection = setB_unique[subs]
  endelse
endelse

END
