PRO swap_elements_between_variables, var1, var2, subs, status, NO_PAR_CHECK = no_par_check

; Description: This module swaps the elements with subscripts "subs" between two variables "var1"
;              and "var2". Both variables must be of the same variable type and have the same
;              number of elements. The module will fail if either of the input parameters "var1"
;              or "var2" is undefined. Note that this module by definition changes the content
;              of each of the input parameters "var1" and "var2".
;
; Input Parameters:
;
;   var1 - ANY SCALAR/VECTOR/ARRAY - A scalar/vector/array of input data for which some elements
;                                    are to be swapped with the corresponding elements in the
;                                    variable "var2". This input parameter must not be undefined.
;   var2 - ANY SCALAR/VECTOR/ARRAY - A scalar/vector/array of input data for which some elements
;                                    are to be swapped with the corresponding elements in the
;                                    variable "var1". This input parameter must have the same
;                                    variable type as "var1", and it must have the same number
;                                    of elements as "var1".
;   subs - INTEGER/LONG VECTOR - A one-dimensional vector of subscripts for the elements which
;                                are to be swapped between the two variables "var1" and "var2".
;                                All the elements in this input parameter must be non-negative,
;                                and less than N, where N is the number of elements in "var1".
;
; Output Parameters:
;
;   status - INTEGER - If the module successfully swapped the required elements between the
;                      variables "var1" and "var2", then "status" is returned with a value of
;                      "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform
;   parameter checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "var1" is not undefined
  if (test_variable_is_defined(var1) NE 1) then return

  ;Check that "var1" and "var2" are of the same variable type, and that they have the same
  ;number of elements
  if (determine_idl_type_as_int(var2) NE determine_idl_type_as_int(var1)) then return
  n1 = var1.length
  if (var2.length NE n1) then return

  ;Check that "subs" is a one-dimensional vector of the correct number type, and that the
  ;elements of "subs" are non-negative and less than N, where N is the number of elements in
  ;"var1"
  test_intlon_1dvec, subs, stat, nsubs, stype
  if (stat EQ 0) then return
  if (array_equal((subs GE 0) AND (subs LT n1), 1B) EQ 0B) then return
endif

;Swap the required elements between "var1" and "var2"
tmpvec = var1[subs]
var1[subs] = var2[subs]
var2[subs] = temporary(tmpvec)

;Set "status" to "1"
status = 1

END
