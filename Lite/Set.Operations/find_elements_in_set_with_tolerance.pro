PRO find_elements_in_set_with_tolerance, v1, v2, tol, nmatch, lo_ind, hi_ind, status, V1_ALREADY_SORTED = v1_already_sorted, NO_PAR_CHECK = no_par_check

; Description: For each element in the set of data "v1", the module searches for the set of values from
;              a set of input data "v2" that match within a tolerance "tol". A value y from "v2" is
;              considered to match a value x from "v1" within a tolerance of "tol" if it lies in the
;              range "(x - tol) <= y <= (x + tol)". The module employs a fast binary search algorithm
;              and it is for this reason that the set of data values "v2" must already be sorted into
;              ascending order. For each element in the set of data "v1", the module returns the number
;              of matching data values from "v2" via the vector "nmatch", and it returns the indices of
;              the smallest and largest matching data values from "v2" via the vectors "lo_ind" and
;              "hi_ind" respectively.
;
;              N.B: (i) The code for the binary search algorithm in this module is a copy of the code
;                       from the DanIDL module "binary_search_with_tolerance.pro" and it has been
;                       written "in-line" in this module for reasons of efficiency. Any changes to
;                       "binary_search_with_tolerance.pro" should therefore be reflected in this module
;                       aswell.
;
;                   (ii) I have proved using proof by induction that the algorithm implemented in this
;                        code will always give the correct answer.
;
;                   (iii) Note that when searching for matching elements between two sets it is faster
;                         to perform the binary search less times on the larger set than it is to
;                         perform the binary search more times on the smaller set. In other words, in
;                         this case it is recommended to set the input parameters "v1" and "v2" to the
;                         smaller and larger sets, respectively.
;
; Input Parameters:
;
;   v1 - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - The set of data for which matching data values in "v2" are
;                                           to be found.
;   v2 - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - The set of data values to be searched for matches, already
;                                           sorted into ascending order.
;   tol - FLOAT/DOUBLE - The maximum difference between values that is considered a match. This parameter
;                        must be non-negative.
;
; Output Parameters:
;
;   nmatch - LONG VECTOR - A one-dimensional vector with the same number of elements as the input
;                          parameter "v1", where each element represents the number of data values from
;                          "v2" that match within a tolerance "tol" of the corresponding element of "v1".
;                          A value y from "v2" is considered to match a value x from "v1" within a
;                          tolerance of "tol" if it lies in the range "(x - tol) <= y <= (x + tol)".
;   lo_ind - LONG VECTOR - A one-dimensional vector with the same number of elements as the input
;                          parameter "v1", where each element represents the index in "v2" of the
;                          smallest matching data value from "v2" for the corresponding element of "v1".
;                          If there are no matching data values in "v2" for an element of "v1", then the
;                          corresponding element of "lo_ind" is set to a value of "-1".
;   hi_ind - LONG VECTOR - A one-dimensional vector with the same number of elements as the input
;                          parameter "v1", where each element represents the index in "v2" of the
;                          largest matching data value from "v2" for the corresponding element of "v1".
;                          If there are no matching data values in "v2" for an element of "v1", then the
;                          corresponding element of "hi_ind" is set to a value of "-1".
;   status - INTEGER - If the module successfully completed its processing, then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword V1_ALREADY_SORTED is set (as "/V1_ALREADY_SORTED"), then the module will assume that
;   the values of "v1" are sorted into ascending order. This option can be used to avoid a sort operation
;   on the input parameter "v1", which allows the user to build more efficient code with this module.
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

  ;Check that "v1" contains number data of the correct type
  if (test_fltdbl(v1) NE 1) then return

  ;Check that "v2" contains number data of the correct type
  if (test_fltdbl(v2) NE 1) then return

  ;Check that "tol" is a non-negative number of the correct type
  if (test_fltdbl_scalar(tol) NE 1) then return
  if (tol LT 0.0) then return
endif
v1_use = double(v1)
v2_use = double(v2)
tol_use = double(tol)

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
endif else subs = sort(v1_use)

;For each element of "v1"
v2_first = v2_use[0]
v2_last = v2_use[nv2_m1]
clo_ind = 0L
for i = 0L,(nv1 - 1L) do begin

  ;Determine the current element of "v1" when it is sorted into ascending order
  csub = subs[i]
  cv1 = v1_use[csub]

  ;If the value of the current element of "v1" plus the search tolerance "tol" is less than the minimum
  ;value of "v2", then there are no data values in "v2" that match within the tolerance "tol" of the
  ;current element of "v1", and the module will move on to the next element of "v1" when it is sorted
  ;into ascending order
  cv1_hi = cv1 + tol_use
  if (cv1_hi LT v2_first) then continue

  ;If the value of the current element of "v1" minus the search tolerance "tol" is greater than the
  ;maximum value of "v2", then there are no data values in "v2" that match within the tolerance "tol"
  ;of the current element of "v1", and the module will exit the loop over the elements of "v1" because
  ;all of the remaining elements of "v1" when it is sorted into ascending order are also greater than
  ;the maximum value of "v2" plus the search tolerance "tol"
  cv1_lo = cv1 - tol_use
  if (cv1_lo GT v2_last) then break

  ;Find the lowest subscript in the set of data values "v2" such that the corresponding value is greater
  ;than or equal to the current element of "v1" minus the search tolerance "tol". Note that for extra
  ;speed, the first index in the binary search is set to the lower index for the range of matching
  ;indices in "v2" for the previously considered element of "v1", since we are considering the elements
  ;of "v1" in ascending order.
  if (v2_use[clo_ind] LT cv1_lo) then begin
    lo_first_ind = clo_ind
    lo_last_ind = nv2_m1
    while ((lo_last_ind - lo_first_ind) GT 1L) do begin
      new_ind = (lo_first_ind + lo_last_ind)/2L
      if (v2_use[new_ind] LT cv1_lo) then begin
        lo_first_ind = new_ind
      endif else lo_last_ind = new_ind
    endwhile
    clo_ind = lo_last_ind
  endif

  ;Find the highest subscript in the set of data values "v2" such that the corresponding value is less
  ;than or equal to the current element of "v1" plus the search tolerance "tol"
  if (v2_last LE cv1_hi) then begin
    chi_ind = nv2_m1
  endif else begin
    hi_first_ind = (clo_ind - 1L) > 0L
    hi_last_ind = nv2_m1
    while ((hi_last_ind - hi_first_ind) GT 1L) do begin
      new_ind = (hi_first_ind + hi_last_ind)/2L
      if (v2_use[new_ind] GT cv1_hi) then begin
        hi_last_ind = new_ind
      endif else hi_first_ind = new_ind
    endwhile
    chi_ind = hi_first_ind
  endelse

  ;If the lowest subscript that was found is greater than the highest subscript that was found, then
  ;this implies that the tolerance range around the current element of "v1" lies between two consecutive
  ;data values in "v2", and therefore there are no data values in "v2" that match within the tolerance
  ;"tol" of the current element of "v1". In this case, the module will move on to the next element of
  ;"v1" when it is sorted into ascending order.
  if (clo_ind GT chi_ind) then continue

  ;Count the number of matching data values
  nmatch[csub] = chi_ind - clo_ind + 1L

  ;Save the range of indices for the matching data values from "v2"
  lo_ind[csub] = clo_ind
  hi_ind[csub] = chi_ind
endfor

;Set "status" to "1"
status = 1

END
