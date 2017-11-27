PRO create_euclidean_distance_1dvec_werr, xsize, x0, x0_var, dist, dist_var, status, SQUARED_DISTANCE = squared_distance, ERROR_PROPAGATION = error_propagation, $
                                          NO_PAR_CHECK = no_par_check

; Description: This module creates a one-dimensional pixel vector "dist" of length "xsize" pixels with
;              values representing the Euclidean distance of each pixel from the x coordinate "x0".
;                The module also provides the option of creating a one-dimensional pixel vector "dist"
;              of length "xsize" pixels with values representing the square of the Euclidean distance
;              of each pixel from the x coordinate "x0" through the use of the keyword SQUARED_DISTANCE.
;                The module also performs propagation of the variance "x0_var" associated with the input
;              parameter "x0". The variance propagation that is performed is approximate (using
;              linearisation by first-order Taylor series expansion), which is especially important to
;              consider for the pixels with x coordinates close to "x0". The variances corresponding to
;              the distance vector "dist" are returned via the output parameter "dist_var". The module
;              provides the option of performing error propagation instead of variance propagation via
;              the use of the keyword ERROR_PROPAGATION.
;                The module does not perform bad pixel mask propagation since it does not make sense for
;              a module with one relevant single-element input parameter "x0".
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The length (pix) of the one-dimensional pixel vector "dist" in the x
;                          direction. This parameter must be positive.
;   x0 - FLOAT/DOUBLE - The x coordinate (pix) of the point from which the Euclidean distances are to be
;                       calculated.
;   x0_var - FLOAT/DOUBLE - The variance of the input parameter "x0". This parameter should be
;                           non-negative. If this input parameter does not satisfy the input requirements,
;                           then the variance is assumed to be zero. If the keyword ERROR_PROPAGATION is
;                           set, then this input parameter is assumed to represent the standard error as
;                           opposed to the variance.
;
; Output Parameters:
;
;   dist - DOUBLE VECTOR - A one-dimensional pixel vector of length "xsize" pixels with values
;                          representing the Euclidean distance of each pixel from the x coordinate "x0".
;                          If the keyword SQUARED_DISTANCE is set, then the values in this output
;                          parameter represent the square of the Euclidean distance of each pixel from
;                          the x coordinate "x0".
;   dist_var - DOUBLE VECTOR - A vector of the same length as the output parameter "dist" where the
;                              elements represent the variances corresponding to the elements of "dist".
;                              If the keyword ERROR_PROPAGATION is set, then the elements of this output
;                              parameter represent the standard errors corresponding to the elements of
;                              "dist".
;   status - INTEGER - If the module successfully created the distance vector "dist", then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword SQUARED_DISTANCE is set (as "/SQUARED_DISTANCE"), then the module will calculate the
;   square of the Euclidean distance of each pixel from the x coordinate "x0" instead of calculating the
;   Euclidean distance.
;
;   If the keyword ERROR_PROPAGATION is set (as "/ERROR_PROPAGATION"), then the module will perform error
;   propagation instead of variance propagation. In other words, the input parameter "x0_var" is assumed
;   to represent a standard error, and the output parameter "dist_var" is returned with elements
;   representing standard errors.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
dist = [0.0D]
dist_var = [0.0D]
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

;Check that "x0_var" is a non-negative scalar number of the correct number type
x0_var_tag = 0
if (test_fltdbl_scalar(x0_var) EQ 1) then x0_var_tag = fix(x0_var GE 0.0)

;Generate the one-dimensional pixel vector representing the Euclidean distances from "x0"
if (x0_use GT 0.0D) then begin
  dist = x0_use + dindgen(xsize)
endif else if (x0_use LT 0.0D) then begin
  dist = abs(x0_use + dindgen(xsize))
endif else dist = dindgen(xsize)

;If the keyword SQUARED_DISTANCE is set
if keyword_set(squared_distance) then begin

  ;If the keyword ERROR_PROPAGATION is set
  if keyword_set(error_propagation) then begin

    ;Perform the variance propagation
    if (x0_var_tag EQ 1) then begin
      dist_var = dist*(2.0D*double(x0_var))
    endif else dist_var = dblarr(xsize)

    ;Calculate the squared Euclidean distances from "x0"
    dist = dist*dist

  ;If the keyword ERROR_PROPAGATION is not set
  endif else begin

    ;Calculate the squared Euclidean distances from "x0"
    dist = dist*dist

    ;Perform the variance propagation
    if (x0_var_tag EQ 1) then begin
      dist_var = dist*(4.0D*double(x0_var))
    endif else dist_var = dblarr(xsize)
  endelse

;If the keyword SQUARED_DISTANCE is not set
endif else begin

  ;Perform the variance propagation
  if (x0_var_tag EQ 1) then begin
    dist_var = replicate(double(x0_var), xsize)
  endif else dist_var = dblarr(xsize)
endelse

;Set "status" to "1"
status = 1

END
