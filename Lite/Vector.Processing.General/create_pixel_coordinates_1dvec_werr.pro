PRO create_pixel_coordinates_1dvec_werr, xsize, fx, fx_var, x0, x0_var, hires_x, xvec, xvec_var, status, ERROR_PROPAGATION = error_propagation, $
                                         NO_PAR_CHECK = no_par_check

; Description: This module creates a one-dimensional coordinate vector "xvec" with "hires_x*xsize" elements,
;              where the ith element has the value:
;
;              xvec[i] = fx*(((i + 0.5)/hires_x) - x0)           for i = 0,1,...,(hires_x*xsize - 1)
;
;              This coordinate vector represents the pixel coordinates of a one-dimensional pixel vector
;              of length "xsize" elements, oversampled by an integer factor "hires_x", with the origin
;              shifted to the position "x0", and with an overall scale factor of "fx" applied.
;                By setting "fx" to "1.0", "x0" to "0.0", and "hires_x" to "1", the simple vector of pixel
;              coordinates "xvec" is obtained with "xsize" elements, where the ith element has the value:
;
;              xvec[i] = i + 0.5                                 for i = 0,1,...,(xsize - 1)
;
;                The module also performs propagation of the variances "fx_var" and "x0_var" associated
;              with the input parameters "fx" and "x0", respectively. It is assumed that the input
;              parameters are independent, and the variance propagation that is performed is exact. The
;              variances corresponding to the coordinate vector "xvec" are returned via the output
;              parameter "xvec_var". The module provides the option of performing error propagation
;              instead of variance propagation via the use of the keyword ERROR_PROPAGATION.
;                The module does not perform bad pixel mask propagation since it does not make sense for
;              a module with two relevant single-element input parameters "fx" and "x0".
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The length (pix) of the one-dimensional pixel vector. This parameter must be
;                          positive.
;   fx - FLOAT/DOUBLE - The x coordinate scale factor as defined above.
;   fx_var - FLOAT/DOUBLE - The variance of the input parameter "fx". This parameter should be
;                           non-negative. If this input parameter does not satisfy the input requirements,
;                           then the variance is assumed to be zero. If the keyword ERROR_PROPAGATION is
;                           set, then this input parameter is assumed to represent the standard error as
;                           opposed to the variance.
;   x0 - FLOAT/DOUBLE - The x coordinate offset (pix) as defined above.
;   x0_var - FLOAT/DOUBLE - The variance of the input parameter "x0". This parameter should be
;                           non-negative. If this input parameter does not satisfy the input requirements,
;                           then the variance is assumed to be zero. If the keyword ERROR_PROPAGATION is
;                           set, then this input parameter is assumed to represent the standard error as
;                           opposed to the variance.
;   hires_x - INTEGER/LONG - The oversampling factor of the pixel vector. This parameter must be positive.
;
; Output Parameters:
;
;   xvec - DOUBLE VECTOR - A one-dimensional coordinate vector of length "hires_x*xsize" elements
;                          representing pixel coordinates along the x-axis with values as defined above.
;   xvec_var - DOUBLE VECTOR - A one-dimensional vector of the same length as the output parameter "xvec"
;                              where the elements represent the variances corresponding to the elements of
;                              "xvec". If the keyword ERROR_PROPAGATION is set, then the elements of this
;                              output parameter represent the standard errors corresponding to the elements
;                              of "xvec".
;   status - INTEGER - If the module successfully created the coordinate vector "xvec", then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword ERROR_PROPAGATION is set (as "/ERROR_PROPAGATION"), then the module will perform error
;   propagation instead of variance propagation. In other words, the input parameters "fx_var" and "x0_var"
;   are assumed to represent standard errors, and the output parameter "xvec_var" is returned with elements
;   representing standard errors.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
xvec = [0.0D]
xvec_var = [0.0D]
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "xsize" is a positive number of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return
  if (xsize LT 1) then return

  ;Check that "fx" and "x0" are numbers of the correct type
  if (test_fltdbl_scalar(fx) NE 1) then return
  if (test_fltdbl_scalar(x0) NE 1) then return

  ;Check that "hires_x" is a positive number of the correct type
  if (test_intlon_scalar(hires_x) NE 1) then return
  if (hires_x LT 1) then return
endif
lxsize = long(hires_x)*long(xsize)

;Check that "fx_var" is a non-negative scalar number of the correct number type
fx_var_use = 0.0D
if (test_fltdbl_scalar(fx_var) EQ 1) then begin
  if (fx_var GE 0.0) then fx_var_use = double(fx_var)
endif

;Check that "x0_var" is a non-negative scalar number of the correct number type
x0_var_use = 0.0D
if (test_fltdbl_scalar(x0_var) EQ 1) then begin
  if (x0_var GE 0.0) then x0_var_use = double(x0_var)
endif

;Generate the coordinate vector "xvec" for the one-dimensional pixel vector and perform the variance propagation
dx = 1.0D/double(hires_x)
generate_arithmetic_sequence, 0.5D*dx - double(x0), dx, lxsize, tmp_seq, stat, /NO_PAR_CHECK
xvec_var = propagate_variance_for_product_pairs(replicate(fx_var_use, lxsize), x0_var_use, double(fx), tmp_seq, 0.0D, 0.0D, status, PRODUCT_MEAN = xvec, $
                                                ERROR_IN = error_propagation, ERROR_OUT = error_propagation, /NO_PAR_CHECK)

END
