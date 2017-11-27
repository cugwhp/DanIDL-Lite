PRO binary_search_with_tolerance, v1, v2, tol, nmatch, lo_ind, hi_ind, NO_PAR_CHECK = no_par_check

; Description: This module searches for the set of values from a set of input data "v2" that match
;              within a tolerance "tol" of the value "v1". A value x from "v2" is considered to
;              match the value "v1" within a tolerance of "tol" if it lies in the range
;              "(v1 - tol) <= x <= (v1 + tol)". The module employs a fast binary search algorithm
;              and it is for this reason that the set of data values "v2" must already be sorted
;              into ascending order. The indices of the smallest and largest matching data values
;              from "v2" are returned as the indices "lo_ind" and "hi_ind" respectively.
;
;              N.B: (i) If you want to perform multiple binary searches with tolerance on the same
;                       data "v2", but with different values of "v1", then it is much more efficient
;                       to use the DanIDL module "find_elements_in_set_with_tolerance.pro" because
;                       the data "v2" is not copied on each call to the binary search algorithm.
;
;                   (ii) The code for the binary search algorithm in this module has been copied
;                        "in-line" to the DanIDL module "find_elements_in_set_with_tolerance.pro"
;                        for reasons of efficiency. Any changes to this module should therefore
;                        be reflected in "find_elements_in_set_with_tolerance.pro" aswell.
;
;                   (iii) I have proved using proof by induction that the algorithm implemented
;                         in this code will always give the correct answer.
;
; Input Parameters:
;
;   v1 - FLOAT/DOUBLE - The value for which matching data values in "v2" are to be found.
;   v2 - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - The set of data values to be searched for matches,
;                                           already sorted into ascending order.
;   tol - FLOAT/DOUBLE - The maximum difference between values that is considered a match. This
;                        parameter must be non-negative.
;
; Output Parameters:
;
;   nmatch - LONG - The number of values from "v2" that match within a tolerance "tol" of the
;                   value "v1". A value x from "v2" is considered to match the value "v1" within
;                   a tolerance of "tol" if it lies in the range "(v1 - tol) <= x <= (v1 + tol)".
;                   If the module fails, then the value of this parameter is set to "-1".
;   lo_ind - LONG - The index of the smallest matching data value from "v2". If there are no
;                   matching data values, then "lo_ind" is returned with a value of "-1".
;   hi_ind - LONG - The index of the largest matching data value from "v2". If there are no
;                   matching data values, then "hi_ind" is returned with a value of "-1".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform
;   parameter checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
nmatch = -1L
lo_ind = -1L
hi_ind = -1L

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "v1" is a number of the correct type
  if (test_fltdbl_scalar(v1) NE 1) then return

  ;Check that "v2" contains number data of the correct type
  if (test_fltdbl(v2) NE 1) then return

  ;Check that "tol" is a non-negative number of the correct type
  if (test_fltdbl_scalar(tol) NE 1) then return
  if (tol LT 0.0) then return
endif
v1_use = double(v1)
v2_use = double(v2)
tol_use = double(tol)

;Determine the number of elements in "v2"
nv2_m1 = v2.length - 1L

;If "v1" does not lie in the range of the data values in "v2" including the tolerance, then there
;are no data values in "v2" that match within a tolerance "tol" of the value "v1", and the module
;will return
nmatch = 0L
v1_hi = v1_use + tol_use
v2_first = v2_use[0]
if (v2_first GT v1_hi) then return
v1_lo = v1_use - tol_use
v2_last = v2_use[nv2_m1]
if (v2_last LT v1_lo) then return

;Find the lowest index in the set of data values "v2" such that the corresponding value is greater
;than or equal to the value "v1" minus the search tolerance "tol"
if (v2_first GE v1_lo) then begin
  lo_ind = 0L
endif else begin
  lo_first_ind = 0L
  lo_last_ind = nv2_m1
  while ((lo_last_ind - lo_first_ind) GT 1L) do begin
    new_ind = (lo_first_ind + lo_last_ind)/2L
    if (v2_use[new_ind] LT v1_lo) then begin
      lo_first_ind = new_ind
    endif else lo_last_ind = new_ind
  endwhile
  lo_ind = lo_last_ind
endelse

;Find the highest index in the set of data values "v2" such that the corresponding value is less
;than or equal to the value "v1" plus the search tolerance "tol"
if (v2_last LE v1_hi) then begin
  hi_ind = nv2_m1
endif else begin
  hi_first_ind = (lo_ind - 1L) > 0L
  hi_last_ind = nv2_m1
  while ((hi_last_ind - hi_first_ind) GT 1L) do begin
    new_ind = (hi_first_ind + hi_last_ind)/2L
    if (v2_use[new_ind] GT v1_hi) then begin
      hi_last_ind = new_ind
    endif else hi_first_ind = new_ind
  endwhile
  hi_ind = hi_first_ind
endelse

;If the lowest index that was found is greater than the highest index that was found, then this
;implies that the tolerance range around the value "v1" lies between two consecutive data values
;in "v2", and therefore there are no data values in "v2" that match within the tolerance "tol"
;of the value "v1". In this case, the module will return.
if (lo_ind GT hi_ind) then begin
  lo_ind = -1L
  hi_ind = -1L
  return
endif

;Count the number of matching data values
nmatch = hi_ind - lo_ind + 1L

END
