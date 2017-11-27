PRO determine_relative_complement_of_two_sets, setA, setB, relative_complement, nrelative_complement, INTERSECTION = intersection, NINTERSECTION = nintersection, $
                                               SETA_ALREADY_SORTED = setA_already_sorted, SETA_UNIQUE_ELEMENTS = setA_unique_elements, SETB_ALREADY_SORTED = setB_already_sorted, $
                                               SETB_UNIQUE_ELEMENTS = setB_unique_elements

; Description: This module determines the set "relative_complement" formed by the relative complement
;              of the set "setB" in the set "setA". In other words, the set "relative_complement" is
;              formed from the elements in the set "setA" that are not in the set "setB". The output
;              parameter "relative_complement" is returned as a vector of "nrelative_complement" unique
;              elements sorted into ascending order. If the input parameter "setB" is undefined, then
;              the module will treat "setB" as representing the empty set. If the relative complement
;              of the set "setB" in the set "setA" is the empty set, then the output parameter
;              "relative_complement" is left undefined and "nrelative_complement" is set to a value of
;              "0".
;                The module also provides the option of returning the set formed by the intersection
;              of the two input sets "setA" and "setB" via the keyword INTERSECTION, which is returned
;              as a vector of unique elements sorted into ascending order. The number of elements in
;              the intersection of the two input sets is optionally returned via the keyword
;              NINTERSECTION. If the intersection of the two input sets is the empty set, then the
;              keyword INTERSECTION is left undefined and the keyword NINTERSECTION is set to a value
;              of "0". This feature is useful if you need to split the elements of a first set into
;              two mutually exclusive subsets based on whether or not they are also members of a
;              second set.
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
;   relative_complement - VECTOR (same type as "setA") - A one-dimensional vector containing the
;                                                        unique elements that make up the relative
;                                                        complement of the set "setB" in the set
;                                                        "setA". The elements of this output parameter
;                                                        are sorted into ascending order. If the
;                                                        relative complement of the set "setB" in the
;                                                        set "setA" is the empty set, or if the module
;                                                        fails, then this parameter is left undefined.
;   nrelative_complement - LONG - The number of elements in the output parameter "relative_complement".
;                                 If the relative complement of the set "setB" in the set "setA" is
;                                 the empty set, then this parameter is set to a value of "0". If the
;                                 module fails, then this parameter is set to a value of "-1".
;
; Keywords:
;
;   If the keyword INTERSECTION is set to a named variable, then, on return, this variable will contain
;   a VECTOR of unique elements of the same type as "setA", sorted into ascending order, that represents
;   the intersection of the two input sets "setA" and "setB". If the intersection of the two input sets
;   is the empty set, or if the module fails, then this keyword is left undefined.
;
;   If the keyword NINTERSECTION is set to a named variable, then, on return, this variable will
;   contain a LONG type SCALAR number representing the number of elements in the intersection of the
;   two input sets "setA" and "setB". If the intersection of the two input sets is the empty set, then
;   this keyword is set to a value of "0". If the module fails, then this keyword is set to a value of
;   "-1".
;
;   If the keyword SETA_ALREADY_SORTED is set (as "/SETA_ALREADY_SORTED"), then the module will assume
;   that the elements in "setA" are sorted into ascending order. This option can be used to avoid
;   unnecessary processing of the input parameter "setA", which allows the user to build more
;   efficient code with this module.
;
;   If the keyword SETA_UNIQUE_ELEMENTS is set (as "/SETA_UNIQUE_ELEMENTS"), then the module will
;   assume that all of the elements in "setA" are unique. This option can be used to avoid
;   unnecessary processing of the input parameter "setA", which allows the user to build more
;   efficient code with this module.
;
;   If the keyword SETB_ALREADY_SORTED is set (as "/SETB_ALREADY_SORTED"), then the module will assume
;   that the elements in "setB" are sorted into ascending order. This option can be used to avoid
;   unnecessary processing of the input parameter "setB", which allows the user to build more
;   efficient code with this module.
;
;   If the keyword SETB_UNIQUE_ELEMENTS is set (as "/SETB_UNIQUE_ELEMENTS"), then the module will
;   assume that all of the elements in "setB" are unique. This option can be used to avoid
;   unnecessary processing of the input parameter "setB", which allows the user to build more
;   efficient code with this module.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
nrelative_complement = -1L
nintersection = -1L

;Check that "setA" is defined, and that it is not an IDL structure
setA_type = determine_idl_type_as_int(setA)
if ((setA_type EQ 0) OR (setA_type EQ 8)) then return

;If "setB" is undefined
setB_type = determine_idl_type_as_int(setB)
if (setB_type EQ 0) then begin

  ;The relative complement of the empty set "setB" in the set "setA" is equal to "setA". Therefore
  ;determine the unique elements of the input set "setA" sorted into ascending order.
  if keyword_set(setA_unique_elements) then begin
    nrelative_complement = setA.length
    if keyword_set(setA_already_sorted) then begin
      relative_complement = reform(setA, nrelative_complement)
    endif else relative_complement = setA[sort(setA)]
  endif else determine_unique_elements, setA, relative_complement, nrelative_complement, DATA_ALREADY_SORTED = setA_already_sorted

  ;The intersection of the input set "setA" with the empty set "setB" is equal to the empty set.
  ;Therefore set the keyword NINTERSECTION to a value of "0" and leave the keyword INTERSECTION
  ;undefined.
  nintersection = 0L

;If "setB" is defined
endif else begin

  ;Check that "setB" has the same variable type as "setA"
  if (setB_type NE setA_type) then return

  ;Determine the unique elements of the input set "setA" sorted into ascending order
  if keyword_set(setA_unique_elements) then begin
    if keyword_set(setA_already_sorted) then begin
      setA_unique = setA
    endif else setA_unique = setA[sort(setA)]
  endif else determine_unique_elements, setA, setA_unique, nsetA_unique, DATA_ALREADY_SORTED = setA_already_sorted

  ;Determine the unique elements of the input set "setB" sorted into ascending order
  if keyword_set(setB_unique_elements) then begin
    if keyword_set(setB_already_sorted) then begin
      setB_unique = setB
    endif else setB_unique = setB[sort(setB)]
  endif else determine_unique_elements, setB, setB_unique, nsetB_unique, DATA_ALREADY_SORTED = setB_already_sorted

  ;Determine the set "relative_complement" formed by the relative complement of the set "setB" in
  ;the set "setA". If the relative complement of the set "setB" in the set "setA" is the empty set,
  ;then set the output parameter "nrelative_complement" to a value of "0" and leave the output
  ;parameter "relative_complement" undefined.
  find_elements_in_set, setA_unique, setB_unique, nmatch, lo_ind, hi_ind, stat, /V1_ALREADY_SORTED, /V2_UNIQUE_ELEMENTS, /NO_PAR_CHECK
  subs = where(nmatch EQ 0L, nrelative_complement, COMPLEMENT = tmp_subs, NCOMPLEMENT = nintersection)
  if (nrelative_complement GT 0L) then relative_complement = setA_unique[subs]

  ;If the intersection of the two input sets "setA" and "setB" is not the empty set, then set the
  ;keyword INTERSECTION appropriately
  if (nintersection GT 0L) then intersection = setA_unique[tmp_subs]
endelse

END
