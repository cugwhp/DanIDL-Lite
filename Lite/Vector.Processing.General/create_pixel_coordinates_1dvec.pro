PRO create_pixel_coordinates_1dvec, xsize, fx, x0, hires_x, xvec, status, NO_PAR_CHECK = no_par_check

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
; Input Parameters:
;
;   xsize - INTEGER/LONG - The length (pix) of the one-dimensional pixel vector. This parameter must be
;                          positive.
;   fx - FLOAT/DOUBLE - The x coordinate scale factor as defined above.
;   x0 - FLOAT/DOUBLE - The x coordinate offset (pix) as defined above.
;   hires_x - INTEGER/LONG - The oversampling factor of the pixel vector. This parameter must be positive.
;
; Output Parameters:
;
;   xvec - DOUBLE VECTOR - A one-dimensional coordinate vector of length "hires_x*xsize" elements
;                          representing pixel coordinates along the x-axis with values as defined above.
;   status - INTEGER - If the module successfully created the coordinate vector "xvec", then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
xvec = [0.0D]
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

;Generate the coordinate vector "xvec" for the one-dimensional pixel vector
fx_use = double(fx)
dx = fx_use/double(hires_x)
generate_arithmetic_sequence, 0.5D*dx - fx_use*double(x0), dx, long(hires_x)*long(xsize), xvec, status, /NO_PAR_CHECK

END
