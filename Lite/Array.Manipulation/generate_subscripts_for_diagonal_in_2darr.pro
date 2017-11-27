FUNCTION generate_subscripts_for_diagonal_in_2darr, xsize, ysize, xind_start, yind_start, diagonal_length, diagonal_direction, status, NO_PAR_CHECK = no_par_check

; Description: This function generates a one-dimensional vector of subscripts for a set of elements that form
;              a diagonal in a two-dimensional array of size "xsize" by "ysize" elements. The set of elements
;              in the diagonal is defined by the x index "xind_start" and the y index "yind_start" of the first
;              element in the diagonal, the number of elements in the diagonal "diagonal_length", and the
;              direction in which the diagonal runs "diagonal_direction", which may be any combination of
;              increasing or decreasing x index, and increasing or decreasing y index (i.e. four possible
;              directions).
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The size of the two-dimensional array along the x-axis. This parameter must be
;                          positive.
;   ysize - INTEGER/LONG - The size of the two-dimensional array along the y-axis. This parameter must be
;                          positive.
;   xind_start - INTEGER/LONG - The x index of the first element in the diagonal. This parameter must lie in
;                               the range "0 <= xind_start < xsize".
;   yind_start - INTEGER/LONG - The y index of the first element in the diagonal. This parameter must lie in
;                               the range "0 <= yind_start < ysize".
;   diagonal_length - INTEGER/LONG - The number of elements in the diagonal. This parameter must be positive.
;                                    Note that subscripts will only be generated for those elements of the
;                                    diagonal that lie within the two-dimensional array.
;   diagonal_direction - STRING - This parameter defines the direction in the two-dimensional array in which
;                                 the diagonal runs from the first element in the diagonal. The acceptable
;                                 values for this parameter are:
;
;                                 ur - The diagonal runs upwards (increasing y index) and to the right
;                                      (increasing x index) in the two-dimensional array from the first
;                                      element in the diagonal.
;                                 ul - The diagonal runs upwards (increasing y index) and to the left
;                                      (decreasing x index) in the two-dimensional array from the first
;                                      element in the diagonal.
;                                 dr - The diagonal runs downwards (decreasing y index) and to the right
;                                      (increasing x index) in the two-dimensional array from the first
;                                      element in the diagonal.
;                                 dl - The diagonal runs downwards (decreasing y index) and to the left
;                                      (decreasing x index) in the two-dimensional array from the first
;                                      element in the diagonal.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully generated the subscripts for the set of elements in the
;                      required diagonal, then "status" is returned with a value of "1", otherwise it is
;                      returned with a value of "0".
;
; Return Value:
;
;   The return value is a one-dimensional VECTOR of numbers of LONG type representing the subscripts for the
;   set of elements in the required diagonal of the two-dimensional array. All elements of the output vector
;   are non-negative. If the function fails for any reason, then the return value is set to the single element
;   vector "[-1L]".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "xsize" and "ysize" are positive numbers of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return, [-1L]
  if (test_intlon_scalar(ysize) NE 1) then return, [-1L]
  if (xsize LT 1) then return, [-1L]
  if (ysize LT 1) then return, [-1L]

  ;Check that "xind_start" and "yind_start" are non-negative numbers of the correct type, and check that
  ;"xind_start" and "yind_start" are less than "xsize" and "ysize", respectively
  if (test_intlon_scalar(xind_start) NE 1) then return, [-1L]
  if (test_intlon_scalar(yind_start) NE 1) then return, [-1L]
  if (xind_start LT 0) then return, [-1L]
  if (yind_start LT 0) then return, [-1L]
  if (xind_start GE xsize) then return, [-1L]
  if (yind_start GE ysize) then return, [-1L]

  ;Check that "diagonal_length" is a positive number of the correct type
  if (test_intlon_scalar(diagonal_length) NE 1) then return, [-1L]
  if (diagonal_length LT 1) then return, [-1L]

  ;Check that "diagonal_direction" is a scalar string with an acceptable value
  if (test_str_scalar(diagonal_direction) NE 1) then return, [-1L]
  if (test_set_membership(diagonal_direction, ['ur', 'ul', 'dr', 'dl'], /NO_PAR_CHECK) NE 1) then return, [-1L]
endif
xsize_use = long(xsize)
ysize_use = long(ysize)
xind_start_use = long(xind_start)
yind_start_use = long(yind_start)
diagonal_length_use = long(diagonal_length)

;Determine the subscript in the two-dimensional array of the first element in the diagonal
sub_start = xind_start_use + (xsize_use*yind_start_use)

;Set "status" to "1"
status = 1

;If the diagonal runs upwards (increasing y index) and to the right (increasing x index) in the two-dimensional
;array from the first element in the diagonal
if (diagonal_direction EQ 'ur') then begin

  ;Limit the set of elements in the diagonal to those that lie within the two-dimensional array
  diagonal_length_use = (diagonal_length_use < (xsize_use - xind_start_use)) < (ysize_use - yind_start_use)

  ;Return the subscripts for the set of elements in the required diagonal of the two-dimensional array
  return, sub_start + ((xsize_use + 1L)*lindgen(diagonal_length_use))

;If the diagonal runs upwards (increasing y index) and to the left (decreasing x index) in the two-dimensional
;array from the first element in the diagonal
endif else if (diagonal_direction EQ 'ul') then begin

  ;Limit the set of elements in the diagonal to those that lie within the two-dimensional array
  diagonal_length_use = (diagonal_length_use < (xind_start_use + 1L)) < (ysize_use - yind_start_use)

  ;Return the subscripts for the set of elements in the required diagonal of the two-dimensional array
  return, sub_start + ((xsize_use - 1L)*lindgen(diagonal_length_use))

;If the diagonal runs downwards (decreasing y index) and to the right (increasing x index) in the two-dimensional
;array from the first element in the diagonal
endif else if (diagonal_direction EQ 'dr') then begin

  ;Limit the set of elements in the diagonal to those that lie within the two-dimensional array
  diagonal_length_use = (diagonal_length_use < (xsize_use - xind_start_use)) < (yind_start_use + 1L)

  ;Return the subscripts for the set of elements in the required diagonal of the two-dimensional array
  return, sub_start - ((xsize_use - 1L)*lindgen(diagonal_length_use))

;If the diagonal runs downwards (decreasing y index) and to the left (decreasing x index) in the two-dimensional
;array from the first element in the diagonal
endif else if (diagonal_direction EQ 'dl') then begin

  ;Limit the set of elements in the diagonal to those that lie within the two-dimensional array
  diagonal_length_use = (diagonal_length_use < (xind_start_use + 1L)) < (yind_start_use + 1L)

  ;Return the subscripts for the set of elements in the required diagonal of the two-dimensional array
  return, sub_start - ((xsize_use + 1L)*lindgen(diagonal_length_use))
endif

END
