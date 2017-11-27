PRO create_euclidean_distance_3darr_werr, xsize, ysize, zsize, x0, x0_var, y0, y0_var, z0, z0_var, dist, dist_var, status, SQUARED_DISTANCE = squared_distance, $
                                          ERROR_PROPAGATION = error_propagation, NO_PAR_CHECK = no_par_check

; Description: This module creates a three-dimensional pixel array "dist" of size "xsize" by "ysize" by "zsize"
;              pixels with values representing the Euclidean distance of each pixel from the pixel coordinates
;              "(x0,y0,z0)".
;                The module also provides the option of creating a three-dimensional pixel array "dist" of size
;              "xsize" by "ysize" by "zsize" pixels with values representing the square of the Euclidean distance
;              of each pixel from the pixel coordinates "(x0,y0,z0)" through the use of the keyword
;              SQUARED_DISTANCE.
;                The module also performs propagation of the variances "x0_var", "y0_var" and "z0_var" associated
;              with the input parameters "x0", "y0" and "z0", respectively. It is assumed that the input
;              parameters are independent. The variance propagation that is performed is approximate (using
;              linearisation by first-order Taylor series expansion), which is especially important to consider
;              for the pixels with coordinates close to "(x0,y0,z0)". The variances corresponding to the distance
;              array "dist" are returned via the output parameter "dist_var". The module provides the option of
;              performing error propagation instead of variance propagation via the use of the keyword
;              ERROR_PROPAGATION.
;                The module does not perform bad pixel mask propagation since it does not make sense for a module
;              with three relevant single-element input parameters "x0", "y0" and "z0".
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
;   x0_var - FLOAT/DOUBLE - The variance of the input parameter "x0". This parameter should be non-negative. If
;                           this input parameter does not satisfy the input requirements, then the variance is
;                           assumed to be zero. If the keyword ERROR_PROPAGATION is set, then this input
;                           parameter is assumed to represent the standard error as opposed to the variance.
;   y0 - FLOAT/DOUBLE - The y coordinate (pix) of the point from which the Euclidean distances are to be
;                       calculated.
;   y0_var - FLOAT/DOUBLE - The variance of the input parameter "y0". This parameter should be non-negative. If
;                           this input parameter does not satisfy the input requirements, then the variance is
;                           assumed to be zero. If the keyword ERROR_PROPAGATION is set, then this input
;                           parameter is assumed to represent the standard error as opposed to the variance.
;   z0 - FLOAT/DOUBLE - The z coordinate (pix) of the point from which the Euclidean distances are to be
;                       calculated.
;   z0_var - FLOAT/DOUBLE - The variance of the input parameter "z0". This parameter should be non-negative. If
;                           this input parameter does not satisfy the input requirements, then the variance is
;                           assumed to be zero. If the keyword ERROR_PROPAGATION is set, then this input
;                           parameter is assumed to represent the standard error as opposed to the variance.
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
;   dist_var - DOUBLE ARRAY - An array of the same size as the output parameter "dist" where the elements
;                             represent the variances corresponding to the elements of "dist". If the keyword
;                             ERROR_PROPAGATION is set, then the elements of this output parameter represent
;                             the standard errors corresponding to the elements of "dist".
;   status - INTEGER - If the module successfully created the distance array "dist", then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword SQUARED_DISTANCE is set (as "/SQUARED_DISTANCE"), then the module will calculate the square
;   of the Euclidean distance of each pixel from the pixel coordinates "(x0,y0,z0)" instead of calculating the
;   Euclidean distance.
;
;   If the keyword ERROR_PROPAGATION is set (as "/ERROR_PROPAGATION"), then the module will perform error
;   propagation instead of variance propagation. In other words, the input parameters "x0_var", "y0_var" and
;   "z0_var" are assumed to represent standard errors, and the output parameter "dist_var" is returned with
;   elements representing standard errors.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter checking
;   on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
dist = 0.0D
dist_var = 0.0D
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

;Check that "x0_var" is a non-negative scalar number of the correct number type
x0_var_use = 0.0D
if (test_fltdbl_scalar(x0_var) EQ 1) then begin
  if (x0_var GE 0.0) then x0_var_use = double(x0_var)
endif

;Check that "y0_var" is a non-negative scalar number of the correct number type
y0_var_use = 0.0D
if (test_fltdbl_scalar(y0_var) EQ 1) then begin
  if (y0_var GE 0.0) then y0_var_use = double(y0_var)
endif

;Check that "z0_var" is a non-negative scalar number of the correct number type
z0_var_use = 0.0D
if (test_fltdbl_scalar(z0_var) EQ 1) then begin
  if (z0_var GE 0.0) then z0_var_use = double(z0_var)
endif

;If the keyword ERROR_PROPAGATION is set, then square the input parameters "x0_var", "y0_var" and "z0_var"
if keyword_set(error_propagation) then begin
  x0_var_use = x0_var_use*x0_var_use
  y0_var_use = y0_var_use*y0_var_use
  z0_var_use = z0_var_use*z0_var_use
endif

;Generate a three-dimensional pixel array representing the squared Euclidean distances from "(x0,y0,z0)" and
;perform the variance propagation
create_euclidean_distance_1dvec_werr, xsize, x0, x0_var_use, xd2, xd2_var, stat, /SQUARED_DISTANCE, /NO_PAR_CHECK
create_euclidean_distance_1dvec_werr, ysize, y0, y0_var_use, yd2, yd2_var, stat, /SQUARED_DISTANCE, /NO_PAR_CHECK
create_euclidean_distance_1dvec_werr, zsize, z0, z0_var_use, zd2, zd2_var, stat, /SQUARED_DISTANCE, /NO_PAR_CHECK
dist = calculate_outer_sum_of_three_vectors_werr(xd2, xd2_var, xd2_bpm, yd2, yd2_var, yd2_bpm, zd2, zd2_var, zd2_bpm, dist_var, dist_bpm, stat, $
                                                 /NO_BPM_PROPAGATION, /NO_PAR_CHECK)

;If the keyword SQUARED_DISTANCE is set
if keyword_set(squared_distance) then begin

  ;If the keyword ERROR_PROPAGATION is set, then convert the output variances to standard errors
  if keyword_set(error_propagation) then dist_var = sqrt(temporary(dist_var))

;If the keyword SQUARED_DISTANCE is not set
endif else begin

  ;Find any zero values in the array of squared Euclidean distances
  subs = where(dist EQ 0.0D, nsubs)

  ;If there is at least one zero value in the array of squared Euclidean distances
  if (nsubs GT 0L) then begin

    ;Perform the variance propagation for the conversion of the array of squared Euclidean distances to an array
    ;of Euclidean distances. The approximation used in this step of the variance propagation breaks down for
    ;squared Euclidean distances of zero. For these cases, assume that the output variance is equal to the
    ;greatest value from the input parameters "x0_var", "y0_var" and "z0_var", which is a conservative estimate
    ;of the output variance.
    dist[subs] = 0.25D
    dist_var[subs] = (x0_var_use > y0_var_use) > z0_var_use
    dist_var = propagate_variance_for_square_root_of_rv(dist_var, dist, stat, ERROR_OUT = error_propagation, /NO_PAR_CHECK)
    dist[subs] = 0.0D

  ;If there are no zero values in the array of squared Euclidean distances
  endif else begin

    ;Perform the variance propagation for the conversion of the array of squared Euclidean distances to an array
    ;of Euclidean distances
    dist_var = propagate_variance_for_square_root_of_rv(dist_var, dist, stat, ERROR_OUT = error_propagation, /NO_PAR_CHECK)
  endelse

  ;Convert the array of squared Euclidean distances to an array of Euclidean distances
  dist = sqrt(temporary(dist))
endelse

;Set "status" to "1"
status = 1

END
