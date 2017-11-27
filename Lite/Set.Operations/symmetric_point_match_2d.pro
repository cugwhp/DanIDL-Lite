PRO symmetric_point_match_2d, x1, y1, x2, y2, tol, nmatch, subs1, subs2, dist, X1_ALREADY_SORTED = x1_already_sorted, X2_ALREADY_SORTED = x2_already_sorted, $
                              NO_PAR_CHECK = no_par_check

; Description: This module searches for matching coordinate pairs between a pair of coordinate lists of
;              two-dimensional points. A pair of two-dimensional points P and Q from each coordinate list
;              are considered a match if P is the closest point to Q, and Q is the closest point to P
;              (symmetric point matching), and the Euclidean distance between P and Q is less than or
;              equal to "tol". A binary search algorithm is used for speed and efficiency. The module
;              returns the number of matched points "nmatch" along with the subscripts "subs1" and "subs2"
;              of the matching points within the two coordinate lists.
;                Note that it is quite possible that multiple points from one coordinate list are equally
;              close to the same point from the other coordinate list. In each of these cases, this module
;              will only return one pair of symmetrically matching points.
;
; Input Parameters:
;
;   x1 - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of x coordinates for the points in the
;                                           first coordinate list.
;   y1 - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of y coordinates for the points in the
;                                           first coordinate list. This parameter must have the same number
;                                           of elements as "x1".
;   x2 - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of x coordinates for the points in the
;                                           second coordinate list.
;   y2 - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of y coordinates for the points in the
;                                           second coordinate list. This parameter must have the same
;                                           number of elements as "x2".
;   tol - FLOAT/DOUBLE - A pair of points P and Q from each coordinate list are considered a match if the
;                        Euclidean distance between them is less than or equal to "tol". This parameter
;                        must be non-negative.
;
; Output Parameters:
;
;   nmatch - LONG - The number of matching coordinate pairs between the coordinate lists. If the module
;                   fails, then the value of this parameter is set to "-1".
;   subs1 - LONG VECTOR - A one-dimensional vector of subscripts from the first coordinate list
;                         corresponding to the matched points. This vector has "nmatch" elements, and each
;                         element in "subs1" corresponds in order with the subscripts of the matching
;                         points from the second coordinate list "subs2".
;   subs2 - LONG VECTOR - A one-dimensional vector of subscripts from the second coordinate list
;                         corresponding to the matched points. This vector has "nmatch" elements, and each
;                         element in "subs2" corresponds in order with the subscripts of the matching
;                         points from the first coordinate list "subs1".
;   dist - DOUBLE VECTOR - A one-dimensional vector of Euclidean distances between the matched points.
;                          This vector has "nmatch" elements, and each element in "dist" corresponds in
;                          order with the subscripts stored in the output vectors "subs1" and "subs2".
;
; Keywords:
;
;   If the keyword X1_ALREADY_SORTED is set (as "/X1_ALREADY_SORTED"), then the module will assume that
;   the values of "x1" are sorted into ascending order. This option can be used to avoid a sort operation
;   on the input parameter "x1", which allows the user to build more efficient code with this module.
;
;   If the keyword X2_ALREADY_SORTED is set (as "/X2_ALREADY_SORTED"), then the module will assume that
;   the values of "x2" are sorted into ascending order. This option can be used to avoid a sort operation
;   on the input parameter "x2", which allows the user to build more efficient code with this module.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
nmatch = -1L
subs1 = [-1L]
subs2 = [-1L]
dist = [0.0D]

;If parameter checking is not required
if keyword_set(no_par_check) then begin

  ;Determine the number of elements in "x1" and "x2"
  nx1 = x1.length
  nx2 = x2.length

;If parameter checking is required
endif else begin

  ;Check that "x1" and "y1" are of the correct number type
  if (test_fltdbl(x1) NE 1) then return
  if (test_fltdbl(y1) NE 1) then return

  ;Check that "y1" has the same number of elements as "x1"
  nx1 = x1.length
  if (y1.length NE nx1) then return

  ;Check that "x2" and "y2" are of the correct number type
  if (test_fltdbl(x2) NE 1) then return
  if (test_fltdbl(y2) NE 1) then return

  ;Check that "y2" has the same number of elements as "x2"
  nx2 = x2.length
  if (y2.length NE nx2) then return

  ;Check that "tol" is a non-negative number of the correct type
  if (test_fltdbl_scalar(tol) NE 1) then return
  if (tol LT 0.0) then return
endelse
x1_use = double(x1)
y1_use = double(y1)
x2_use = double(x2)
y2_use = double(y2)
tol_use = double(tol)
tol2 = tol_use*tol_use

;If the keyword X1_ALREADY_SORTED is not set, then determine the subscripts of "x1" when it is sorted into
;ascending order, and sort the first coordinate list such that the elements of "x1" are in ascending order
if ~keyword_set(x1_already_sorted) then begin
  x1_sort_subs = sort(x1_use)
  x1_use = x1_use[x1_sort_subs]
  y1_use = y1_use[x1_sort_subs]
endif

;If the keyword X2_ALREADY_SORTED is not set, then determine the subscripts of "x2" when it is sorted into
;ascending order, and sort the second coordinate list such that the elements of "x2" are in ascending order
if ~keyword_set(x2_already_sorted) then begin
  x2_sort_subs = sort(x2_use)
  x2_use = x2_use[x2_sort_subs]
  y2_use = y2_use[x2_sort_subs]
endif

;For each point in the first coordinate list, find the set of points from the second coordinate list with
;x coordinates within a distance of "tol" from the x coordinate of the current point in the first coordinate
;list
find_elements_in_set_with_tolerance, x1_use, x2_use, tol_use, nm, lo_ind, hi_ind, stat, /V1_ALREADY_SORTED, /NO_PAR_CHECK

;For each point in the first coordinate list, find the closest point in the second coordinate list within
;the specified distance tolerance "tol"
s12 = replicate(-1L, nx1)
d12 = dblarr(nx1)
subs = where(nm GT 0L, nsubs)
if (nsubs GT 0L) then begin
  for i = 0L,(nsubs - 1L) do begin

    ;For the current point in the first coordinate list, find the closest point from the second coordinate
    ;list within the specified distance tolerance, if at least one such point exists
    csub = subs[i]
    clo_ind = lo_ind[csub]
    chi_ind = hi_ind[csub]
    min_dist2 = min(((x1_use[csub] - x2_use[clo_ind:chi_ind])^2) + ((y1_use[csub] - y2_use[clo_ind:chi_ind])^2), min_sub)
    if (min_dist2 LE tol2) then begin
      s12[csub] = clo_ind + min_sub
      d12[csub] = min_dist2
    endif
  endfor
endif
d12 = sqrt(temporary(d12))

;For each point in the second coordinate list, find the set of points from the first coordinate list with
;x coordinates within a distance of "tol" from the x coordinate of the current point in the second coordinate
;list
find_elements_in_set_with_tolerance, x2_use, x1_use, tol_use, nm, lo_ind, hi_ind, stat, /V1_ALREADY_SORTED, /NO_PAR_CHECK

;For each point in the second coordinate list, find the closest point in the first coordinate list within
;the specified distance tolerance "tol"
s21 = replicate(-1L, nx2)
subs = where(nm GT 0L, nsubs)
if (nsubs GT 0L) then begin
  for i = 0L,(nsubs - 1L) do begin

    ;For the current point in the second coordinate list, find the closest point from the first coordinate
    ;list within the specified distance tolerance, if at least one such point exists
    csub = subs[i]
    clo_ind = lo_ind[csub]
    chi_ind = hi_ind[csub]
    min_dist2 = min(((x2_use[csub] - x1_use[clo_ind:chi_ind])^2) + ((y2_use[csub] - y1_use[clo_ind:chi_ind])^2), min_sub)
    if (min_dist2 LE tol2) then s21[csub] = clo_ind + min_sub
  endfor
endif

;If there is at least one point in the first coordinate list for which the closest point in the second
;coordinate list is within the specified distance tolerance "tol"
tmp_subs1 = where(s12 GE 0L, ntmp_subs1)
if (ntmp_subs1 GT 0L) then begin

  ;Determine which pairs of points P and Q from each coordinate list satisfy P being the closest point to
  ;Q, and Q being the closest point to P, and that have a Euclidean distance between them of less than or
  ;equal to the specified distance tolerance "tol"
  tmp_subs2 = where(s21[s12[tmp_subs1]] EQ tmp_subs1, nmatch)

  ;If there is at least one symmetrically matching coordinate pair between the two coordinate lists
  if (nmatch GT 0L) then begin

    ;Set the values of the output parameters "subs1", "subs2", and "dist" appropriately
    subs1 = tmp_subs1[tmp_subs2]
    subs2 = s12[subs1]
    dist = d12[subs1]
    if ~keyword_set(x1_already_sorted) then subs1 = x1_sort_subs[subs1]
    if ~keyword_set(x2_already_sorted) then subs2 = x2_sort_subs[subs2]
  endif

;If there are no points in the first coordinate list for which the closest point in the second coordinate
;list is within the specified distance tolerance "tol", then there are no matching coordinate pairs between
;the two coordinate lists
endif else nmatch = 0L

END
