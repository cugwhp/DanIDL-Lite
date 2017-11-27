PRO delete_elements_from_variable, var, elements_to_delete, var_kept, nkept, KEPT_SUBS = kept_subs, DELETED_ELEMENTS = deleted_elements, DELETED_SUBS = deleted_subs, $
                                   NDELETED = ndeleted, VAR_SORTED = var_sorted, ETD_SORTED = etd_sorted, ETD_UNIQUE = etd_unique, NO_PAR_CHECK = no_par_check

; Description: This module determines the result "var_kept" of deleting the elements "elements_to_delete"
;              from the variable "var". Both "var" and "elements_to_delete" must be of the same variable
;              type. The module will fail if either of the input parameters "var" or "elements_to_delete"
;              is undefined or an IDL structure.
;                The module provides the option of returning the subscripts in "var" of the elements that
;              were not deleted via the keyword KEPT_SUBS. The module also provides the option of returning
;              the list of elements that were actually deleted from "var", including their subscripts in
;              "var" and the number of such elements, via the keywords DELETED_ELEMENTS, DELETED_SUBS, and
;              NDELETED, respectively.
;
; Input Parameters:
;
;   var - ANY SCALAR/VECTOR/ARRAY - A scalar/vector/array of input data from which elements are to be
;                                   deleted. This parameter must be defined, and not an IDL structure.
;   elements_to_delete - ANY SCALAR/VECTOR/ARRAY - A scalar/vector/array containing the elements to be
;                                                  deleted from the variable "var". This input parameter
;                                                  must have the same variable type as "var".
;
; Output Parameters:
;
;   var_kept - VECTOR (same type as "var") - A one-dimensional vector containing the elements from "var"
;                                            that were not deleted. The ordering of the elements in
;                                            "var_kept" matches the ordering of the elements in "var".
;                                            If all of the elements were deleted from "var", then this
;                                            parameter is left undefined.
;   nkept - LONG - The number of elements in the output parameter "var_kept". If all of the elements were
;                  deleted from "var", then this parameter is set to "0". If the module fails, then this
;                  parameter is set to "-1".
;
; Keywords:
;
;   If the keyword KEPT_SUBS is set to a named variable, then, on return, this variable will contain a
;   VECTOR of LONG type numbers representing the subscripts of the elements in "var" that were not deleted.
;   Note that "var_kept" and "var[kept_subs]" are the same vectors.  If all of the elements were deleted
;   from "var", then this keyword is set to the single element vector "[-1L]".
;
;   If the keyword DELETED_ELEMENTS is set to a named variable, then, on return, this variable will contain
;   a VECTOR of the same variable type as "var" that contains the elements from "var" that were deleted.
;   The ordering of the elements in "deleted_elements" matches the ordering of the elements in "var". If no
;   elements were deleted from "var", then this keyword is left undefined.
;
;   If the keyword DELETED_SUBS is set to a named variable, then, on return, this variable will contain a
;   VECTOR of LONG type numbers representing the subscripts of the elements in "var" that were deleted.
;   Note that "deleted_elements" and "var[deleted_subs]" are the same vectors. If no elements were deleted
;   from "var", then this keyword is set to the single element vector "[-1L]".
;
;   If the keyword NDELETED is set to a named variable, then, on return, this variable will contain a LONG
;   type SCALAR number that represents the number of elements from "var" that were deleted.
;
;   If the keyword VAR_SORTED is set (as "/VAR_SORTED"), then the module will assume that the elements in
;   "var" are sorted into ascending order. This option can be used to avoid unnecessary processing of the
;   input parameter "var", which allows the user to build more efficient code with this module.
;
;   If the keyword ETD_SORTED is set (as "/ETD_SORTED"), then the module will assume that the elements in
;   "elements_to_delete" are sorted into ascending order. This option can be used to avoid unnecessary
;   processing of the input parameter "elements_to_delete", which allows the user to build more efficient
;   code with this module.
;
;   If the keyword ETD_UNIQUE is set (as "/ETD_UNIQUE"), then the module will assume that all of the
;   elements in "elements_to_delete" are unique. This option can be used to avoid unnecessary processing
;   of the input parameter "elements_to_delete", which allows the user to build more efficient code with
;   this module.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
nkept = -1L
kept_subs = [-1L]
deleted_subs = [-1L]
ndeleted = 0L

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "var" is defined, and that it is not an IDL structure
  vtype = determine_idl_type_as_int(var)
  if ((vtype EQ 0) OR (vtype EQ 8)) then return

  ;Check that "elements_to_delete" has the same variable type as "var"
  if (determine_idl_type_as_int(elements_to_delete) NE vtype) then return
endif

;Determine the unique elements in "elements_to_delete" sorted into ascending order
if keyword_set(etd_unique) then begin
  if keyword_set(etd_sorted) then begin
    elements_to_delete_use = elements_to_delete
  endif else elements_to_delete_use = elements_to_delete[sort(elements_to_delete)]
endif else determine_unique_elements, elements_to_delete, elements_to_delete_use, netd, DATA_ALREADY_SORTED = etd_sorted

;Search for each element from "var" in the list of elements to be deleted "elements_to_delete"
find_elements_in_set, var, elements_to_delete_use, nmatch, lo_ind, hi_ind, stat, V1_ALREADY_SORTED = var_sorted, /V2_UNIQUE_ELEMENTS, /NO_PAR_CHECK

;Determine the result "var_kept" of deleting the elements "elements_to_delete" from "var", including setting
;the values of the various keywords
kept_subs = where(nmatch EQ 0L, nkept, COMPLEMENT = deleted_subs, NCOMPLEMENT = ndeleted)
if (nkept GT 0L) then begin
  var_kept = var[kept_subs]
endif else kept_subs = [-1L]
if (ndeleted GT 0L) then begin
  deleted_elements = var[deleted_subs]
endif else deleted_subs = [-1L]

END
