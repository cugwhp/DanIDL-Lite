PRO find_elements_in_set, v1, v2, nmatch, lo_ind, hi_ind, status, V1_ALREADY_SORTED = v1_already_sorted, V2_UNIQUE_ELEMENTS = v2_unique_elements, NO_PAR_CHECK = no_par_check

; Description: For each element in the set of data "v1", the module searches for the elements in the set
;              of data "v2" that have exactly matching values. The module employs a fast binary search
;              algorithm and it is for this reason that the set of data values "v2" must already be sorted
;              into ascending order. For each element in the set of data "v1", the module returns the
;              number of matching data values from "v2" via the vector "nmatch", and it returns the range
;              of indices of the matching data values from "v2" via the vectors "lo_ind" and "hi_ind"
;              representing the lower and upper bounds of the index range respectively.
;
;              N.B: (i) The code for the binary search algorithm in this module is a copy of the code
;                       from the DanIDL module "binary_search.pro" and it has been written "in-line" in
;                       this module for reasons of efficiency. Any changes to "binary_search.pro" should
;                       therefore be reflected in this module aswell.
;
;                   (ii) This module works for any number type for the input parameters "v1" and "v2",
;                        and it also works if "v1" and "v2" are of string type.
;
;                   (iii) I have proved using proof by induction that the algorithm implemented in this
;                         code will always give the correct answer.
;
;                   (iv) Note that when searching for matching elements between two sets it is faster to
;                        perform the binary search less times on the larger set than it is to perform the
;                        binary search more times on the smaller set. In other words, in this case it is
;                        recommended to set the input parameters "v1" and "v2" to the smaller and larger
;                        sets, respectively.
;
; Input Parameters:
;
;   v1 - ANY SCALAR/VECTOR/ARRAY - The set of data for which exactly matching data values in "v2" are to
;                                  be found. This parameter must be defined, and not an IDL structure.
;   v2 - ANY SCALAR/VECTOR/ARRAY - The set of data values to be searched for exact matches, already sorted
;                                  into ascending order. This parameter must have the same variable type
;                                  as the parameter "v1".
;
; Output Parameters:
;
;   nmatch - LONG VECTOR - A one-dimensional vector with the same number of elements as the input parameter
;                          "v1", where each element represents the number of data values from "v2" that
;                          have exactly the same value as the corresponding element of "v1".
;   lo_ind - LONG VECTOR - A one-dimensional vector with the same number of elements as the input parameter
;                          "v1", where each element represents the lower index in "v2" of the range of
;                          indices for the exactly matching data values from "v2" for the corresponding
;                          element of "v1". If there are no exactly matching data values in "v2" for an
;                          element of "v1", then the corresponding element of "lo_ind" is set to a value
;                          of "-1".
;   hi_ind - LONG VECTOR - A one-dimensional vector with the same number of elements as the input parameter
;                          "v1", where each element represents the upper index in "v2" of the range of
;                          indices for the exactly matching data values from "v2" for the corresponding
;                          element of "v1". If there are no exactly matching data values in "v2" for an
;                          element of "v1", then the corresponding element of "hi_ind" is set to a value
;                          of "-1".
;   status - INTEGER - If the module successfully completed its processing, then "status" is returned with
;                      a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword V1_ALREADY_SORTED is set (as "/V1_ALREADY_SORTED"), then the module will assume that the
;   data values in "v1" are sorted into ascending order. This option can be used to avoid a sort operation
;   on the input parameter "v1", which allows the user to build more efficient code with this module.
;
;   If the keyword V2_UNIQUE_ELEMENTS is set (as "/V2_UNIQUE_ELEMENTS"), then the module will assume that
;   all of the data values in "v2" are unique. This option can be used to avoid unnecessary processing of
;   the input parameter "v2", which allows the user to build more efficient code with this module.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
nmatch = [0L]
lo_ind = [-1L]
hi_ind = [-1L]
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "v1" is defined, and that it is not an IDL structure
  v1_type = determine_idl_type_as_int(v1)
  if ((v1_type EQ 0) OR (v1_type EQ 8)) then return

  ;Check that "v2" has the same variable type as "v1"
  if (determine_idl_type_as_int(v2) NE v1_type) then return
endif

;Determine the number of elements in "v1" and "v2"
nv1 = v1.length
nv2_m1 = v2.length - 1L

;Set up the output parameter vectors
nmatch = lonarr(nv1)
lo_ind = replicate(-1L, nv1)
hi_ind = replicate(-1L, nv1)

;Determine the subscripts of "v1" when it is sorted into ascending order
if keyword_set(v1_already_sorted) then begin
  subs = lindgen(nv1)
endif else subs = sort(v1)

;For each element of "v1"
v2_first = v2[0]
v2_last = v2[nv2_m1]
chi_ind = 0L
for i = 0L,(nv1 - 1L) do begin

  ;Determine the current element of "v1" when it is sorted into ascending order
  csub = subs[i]
  cv1 = v1[csub]

  ;If the current element of "v1" is less than the minimum value of "v2", then there are no data values in
  ;"v2" that have exactly the same value as the current element of "v1", and the module will move on to the
  ;next element of "v1" when it is sorted into ascending order
  if (cv1 LT v2_first) then continue

  ;If the current element of "v1" is greater than the maximum value of "v2", then there are no data values
  ;in "v2" that have exactly the same value as "v1", and the module will exit the loop over the elements of
  ;"v1" because all of the remaining elements of "v1" when it is sorted into ascending order are also greater
  ;than the maximum value of "v2"
  if (cv1 GT v2_last) then break

  ;Use a binary search algorithm to find a subscript of "v2" with a corresponding data value that exactly
  ;matches the value of the current element of "v1", if it exists. Note that for extra speed, the first index
  ;in the binary search is set to the higher index for the range of matching indices in "v2" for the
  ;previously considered element of "v1", since we are considering the elements of "v1" in ascending order.
  first_ind = chi_ind
  last_ind = nv2_m1
  while (last_ind GT first_ind) do begin
    curr_ind = (first_ind + last_ind)/2L
    if (v2[curr_ind] LT cv1) then begin
      first_ind = curr_ind + 1L
    endif else last_ind = curr_ind
  endwhile

  ;If there are no data values in "v2" that have exactly the same value as the current element of "v1", then
  ;the module will move on to the next element of "v1" when it is sorted into ascending order
  if (v2[first_ind] NE cv1) then continue

  ;If the keyword V2_UNIQUE_ELEMENTS is set, then "v2" contains only unique data values
  if keyword_set(v2_unique_elements) then begin

    ;Save the index for the exactly matching data value from "v2"
    chi_ind = first_ind
    nmatch[csub] = 1L
    lo_ind[csub] = first_ind
    hi_ind[csub] = first_ind

    ;Move on to the next element of "v1" when it is sorted into ascending order
    continue
  endif

  ;Determine the lowest subscript in the set of data values "v2" with a corresponding data value that exactly
  ;matches the value of the current element of "v1"
  clo_ind = first_ind
  if (clo_ind GT 0L) then begin
    curr_ind = clo_ind - 1L
    while (v2[curr_ind] EQ cv1) do begin
      curr_ind = curr_ind - 1L
      if (curr_ind LT 0L) then break
    endwhile
    clo_ind = curr_ind + 1L
  endif

  ;Determine the highest subscript in the set of data values "v2" with a corresponding data value that exactly
  ;matches the value of the current element of "v1"
  chi_ind = first_ind
  if (chi_ind LT nv2_m1) then begin
    curr_ind = chi_ind + 1L
    while (v2[curr_ind] EQ cv1) do begin
      curr_ind = curr_ind + 1L
      if (curr_ind GT nv2_m1) then break
    endwhile
    chi_ind = curr_ind - 1L
  endif

  ;Count the number of matching data values
  nmatch[csub] = chi_ind - clo_ind + 1L

  ;Save the range of indices for the exactly matching data values from "v2"
  lo_ind[csub] = clo_ind
  hi_ind[csub] = chi_ind
endfor

;Set "status" to "1"
status = 1

END
