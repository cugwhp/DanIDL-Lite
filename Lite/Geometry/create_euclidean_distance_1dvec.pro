PRO create_euclidean_distance_1dvec, xsize, x0, dist, status, SQUARED_DISTANCE = squared_distance, NO_PAR_CHECK = no_par_check

; Description: This module creates a one-dimensional pixel vector "dist" of length "xsize" pixels with
;              values representing the Euclidean distance of each pixel from the x coordinate "x0".
;                The module also provides the option of creating a one-dimensional pixel vector "dist"
;              of length "xsize" pixels with values representing the square of the Euclidean distance
;              of each pixel from the x coordinate "x0" through the use of the keyword SQUARED_DISTANCE.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The length (pix) of the one-dimensional pixel vector "dist" in the x
;                          direction. This parameter must be positive.
;   x0 - FLOAT/DOUBLE - The x coordinate (pix) of the point from which the Euclidean distances are to
;                       be calculated.
;
; Output Parameters:
;
;   dist - DOUBLE VECTOR - A one-dimensional pixel vector of length "xsize" pixels with values
;                          representing the Euclidean distance of each pixel from the x coordinate "x0".
;                          If the keyword SQUARED_DISTANCE is set, then the values in this output
;                          parameter represent the square of the Euclidean distance of each pixel from
;                          the x coordinate "x0".
;   status - INTEGER - If the module successfully created the distance vector "dist", then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword SQUARED_DISTANCE is set (as "/SQUARED_DISTANCE"), then the module will calculate
;   the square of the Euclidean distance of each pixel from the x coordinate "x0" instead of
;   calculating the Euclidean distance.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
dist = [0.0D]
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "xsize" is a positive number of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return
  if (xsize LT 1) then return

  ;Check that "x0" is a number of the correct type
  if (test_fltdbl_scalar(x0) NE 1) then return
endif
x0_use = 0.5D - double(x0)

;If the keyword SQUARED_DISTANCE is set
if keyword_set(squared_distance) then begin

  ;Generate the one-dimensional pixel vector representing the squared Euclidean distances from "x0"
  if (x0_use NE 0.0D) then begin
    dist = (x0_use + dindgen(xsize))^2
  endif else dist = dindgen(xsize)^2

;If the keyword SQUARED_DISTANCE is not set
endif else begin

  ;Generate the one-dimensional pixel vector representing the Euclidean distances from "x0"
  if (x0_use GT 0.0D) then begin
    dist = x0_use + dindgen(xsize)
  endif else if (x0_use LT 0.0D) then begin
    dist = abs(x0_use + dindgen(xsize))
  endif else dist = dindgen(xsize)
endelse

;Set "status" to "1"
status = 1

END
