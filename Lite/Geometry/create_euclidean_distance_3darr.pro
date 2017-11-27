PRO create_euclidean_distance_3darr, xsize, ysize, zsize, x0, y0, z0, dist, status, SQUARED_DISTANCE = squared_distance, NO_PAR_CHECK = no_par_check

; Description: This module creates a three-dimensional pixel array "dist" of size "xsize" by "ysize" by "zsize"
;              pixels with values representing the Euclidean distance of each pixel from the pixel coordinates
;              "(x0,y0,z0)".
;                The module also provides the option of creating a three-dimensional pixel array "dist" of size
;              "xsize" by "ysize" by "zsize" pixels with values representing the square of the Euclidean distance
;              of each pixel from the pixel coordinates "(x0,y0,z0)" through the use of the keyword
;              SQUARED_DISTANCE.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The size (pix) of the three-dimensional pixel array "dist" in the x direction. This
;                          parameter must be positive.
;   ysize - INTEGER/LONG - The size (pix) of the three-dimensional pixel array "dist" in the y direction. This
;                          parameter must be positive.
;   zsize - INTEGER/LONG - The size (pix) of the three-dimensional pixel array "dist" in the z direction. This
;                          parameter must be positive.
;   x0 - FLOAT/DOUBLE - The x coordinate (pix) of the point from which the Euclidean distances are to be
;                       calculated.
;   y0 - FLOAT/DOUBLE - The y coordinate (pix) of the point from which the Euclidean distances are to be
;                       calculated.
;   z0 - FLOAT/DOUBLE - The z coordinate (pix) of the point from which the Euclidean distances are to be
;                       calculated.
;
; Output Parameters:
;
;   dist - DOUBLE ARRAY - A three-dimensional pixel array of size "xsize" by "ysize" by "zsize" pixels with
;                         values representing the Euclidean distance of each pixel from the pixel coordinates
;                         "(x0,y0,z0)". If the keyword SQUARED_DISTANCE is set, then the values in this output
;                         parameter represent the square of the Euclidean distance of each pixel from the pixel
;                         coordinates "(x0,y0,z0)". Note that if "ysize" and "zsize" are both set to "1", then
;                         this parameter is returned as a one-dimensional vector of length "xsize" pixels since
;                         IDL treats an Nx1x1 array as an N-element one-dimensional vector. Also, if only
;                         "zsize" is set to "1", then this parameter is returned as a two-dimensional array of
;                         size "xsize" by "ysize" pixels since IDL treats an MxNx1 array as an MxN-element
;                         two-dimensional array.
;   status - INTEGER - If the module successfully created the distance array "dist", then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword SQUARED_DISTANCE is set (as "/SQUARED_DISTANCE"), then the module will calculate the square
;   of the Euclidean distance of each pixel from the pixel coordinates "(x0,y0,z0)" instead of calculating the
;   Euclidean distance.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter checking
;   on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
dist = 0.0D
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "xsize", "ysize" and "zsize" are all positive numbers of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return
  if (test_intlon_scalar(ysize) NE 1) then return
  if (test_intlon_scalar(zsize) NE 1) then return
  if (xsize LT 1) then return
  if (ysize LT 1) then return
  if (zsize LT 1) then return

  ;Check that "x0", "y0" and "z0" are all numbers of the correct type
  if (test_fltdbl_scalar(x0) NE 1) then return
  if (test_fltdbl_scalar(y0) NE 1) then return
  if (test_fltdbl_scalar(z0) NE 1) then return
endif

;Generate a three-dimensional pixel array representing the squared Euclidean distances from "(x0,y0,z0)"
create_euclidean_distance_1dvec, xsize, x0, xd2, stat, /SQUARED_DISTANCE, /NO_PAR_CHECK
create_euclidean_distance_1dvec, ysize, y0, yd2, stat, /SQUARED_DISTANCE, /NO_PAR_CHECK
create_euclidean_distance_1dvec, zsize, z0, zd2, stat, /SQUARED_DISTANCE, /NO_PAR_CHECK
dist = calculate_outer_sum_of_three_vectors(xd2, yd2, zd2, stat, /NO_PAR_CHECK)

;If the keyword SQUARED_DISTANCE is not set, then convert the array of squared Euclidean distances to an array
;of Euclidean distances
if ~keyword_set(squared_distance) then dist = sqrt(temporary(dist))

;Set "status" to "1"
status = 1

END
