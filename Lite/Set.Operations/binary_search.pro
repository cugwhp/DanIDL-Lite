PRO binary_search, v1, v2, nmatch, lo_ind, hi_ind, V2_UNIQUE_ELEMENTS = v2_unique_elements, NO_PAR_CHECK = no_par_check

; Description: This module searches for the set of values from a set of input data "v2" that have exactly
;              the same value as "v1". The module employs a fast binary search algorithm and it is for
;              this reason that the set of data values "v2" must already be sorted into ascending order.
;              The indices of the matching data values from "v2" are returned as the range of indices
;              delimited by "lo_ind" and "hi_ind" respectively.
;
;              N.B: (i) If you want to perform multiple binary searches on the same data "v2", but with
;                       different values of "v1", then it is much more efficient to use the DanIDL module
;                       "find_elements_in_set.pro" because the data "v2" is not copied on each call to
;                       the binary search algorithm.
;
;                   (ii) This module works for any number type for the input parameters "v1" and "v2",
;                        and it also works if "v1" and "v2" are of string type.
;
;                   (iii) The code for the binary search algorithm in this module has been copied
;                         "in-line" to the DanIDL module "find_elements_in_set.pro" for reasons of
;                         efficiency. Any changes to this module should therefore be reflected in
;                         "find_elements_in_set.pro" aswell.
;
;                   (iv) I have proved using proof by induction that the algorithm implemented in this
;                        code will always give the correct answer.
;
; Input Parameters:
;
;   v1 - ANY SCALAR - The value for which exactly matching data values in "v2" are to be found. This
;                     parameter must be defined, and not an IDL structure.
;   v2 - ANY SCALAR/VECTOR/ARRAY - The set of data values to be searched for exact matches, already
;                                  sorted into ascending order. This parameter must have the same
;                                  variable type as the parameter "v1".
;
; Output Parameters:
;
;   nmatch - LONG - The number of values from "v2" that have exactly the same value as "v1". If the
;                   module fails, then the value of this parameter is set to "-1".
;   lo_ind - LONG - The lower index of the range of indices for the exactly matching data values from
;                   "v2". If there are no exactly matching data values, then "lo_ind" is returned with
;                   a value of "-1".
;   hi_ind - LONG - The upper index of the range of indices for the exactly matching data values from
;                   "v2". If there are no exactly matching data values, then "hi_ind" is returned with
;                   a value of "-1".
;
; Keywords:
;
;   If the keyword V2_UNIQUE_ELEMENTS is set (as "/V2_UNIQUE_ELEMENTS"), then the module will assume
;   that all of the data values in "v2" are unique. This option can be used to avoid unnecessary
;   processing of the input parameter "v2", which allows the user to build more efficient code with
;   this module.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
nmatch = -1L
lo_ind = -1L
hi_ind = -1L

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "v1" is a scalar, and that it is not an IDL structure
  result = size(v1)
  if (result[0] NE 0L) then return

  ;Check that "v1" is defined
  v1_type = fix(result[1])
  if (v1_type EQ 0) then return

  ;Check that "v2" has the same variable type as "v1"
  if (determine_idl_type_as_int(v2) NE v1_type) then return
endif

;Determine the number of elements in "v2"
nv2_m1 = v2.length - 1L

;If "v1" does not lie in the range of the data values in "v2", then there are no data values in "v2" that
;have exactly the same value as "v1", and the module will return
if ((v1 LT v2[0]) OR (v1 GT v2[nv2_m1])) then begin
  nmatch = 0L
  return
endif

;Use a binary search algorithm to find an index of "v2" with a corresponding data value that exactly
;matches the value of "v1", if it exists
first_ind = 0L
last_ind = nv2_m1
while (last_ind GT first_ind) do begin
  curr_ind = (first_ind + last_ind)/2L
  if (v2[curr_ind] LT v1) then begin
    first_ind = curr_ind + 1L
  endif else last_ind = curr_ind
endwhile

;If there are no data values in "v2" that have exactly the same value as "v1", then the module will return
if (v2[first_ind] NE v1) then begin
  nmatch = 0L
  return
endif

;If the keyword V2_UNIQUE_ELEMENTS is set, then "v2" contains only unique data values and no further
;processing is necessary
if keyword_set(v2_unique_elements) then begin
  nmatch = 1L
  lo_ind = first_ind
  hi_ind = first_ind
  return
endif

;Determine the lowest index in the set of data values "v2" with a corresponding data value that exactly
;matches the value of "v1"
lo_ind = first_ind
if (lo_ind GT 0L) then begin
  curr_ind = lo_ind - 1L
  while (v2[curr_ind] EQ v1) do begin
    curr_ind = curr_ind - 1L
    if (curr_ind LT 0L) then break
  endwhile
  lo_ind = curr_ind + 1L
endif

;Determine the highest index in the set of data values "v2" with a corresponding data value that exactly
;matches the value of "v1"
hi_ind = first_ind
if (hi_ind LT nv2_m1) then begin
  curr_ind = hi_ind + 1L
  while (v2[curr_ind] EQ v1) do begin
    curr_ind = curr_ind + 1L
    if (curr_ind GT nv2_m1) then break
  endwhile
  hi_ind = curr_ind - 1L
endif

;Count the number of matching data values
nmatch = hi_ind - lo_ind + 1L

END
