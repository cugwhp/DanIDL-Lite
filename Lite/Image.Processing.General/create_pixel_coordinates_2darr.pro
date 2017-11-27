PRO create_pixel_coordinates_2darr, xsize, ysize, fx, fy, x0, y0, hires_x, hires_y, xarr, yarr, status, ONLY_XCOORDS = only_xcoords, ONLY_YCOORDS = only_ycoords, $
                                    NO_PAR_CHECK = no_par_check

; Description: This module creates the two-dimensional coordinate arrays "xarr" and "yarr", each with
;              "hires_x*xsize" by "hires_y*ysize" elements, where the (i,j)th element of each array has
;              the value:
;
;              xarr[i,j] = fx*(((i + 0.5)/hires_x) - x0)           for i = 0,1,...,(hires_x*xsize - 1)
;              yarr[i,j] = fy*(((j + 0.5)/hires_y) - y0)           for j = 0,1,...,(hires_y*ysize - 1)
;
;              These coordinate arrays represent the x and y pixel coordinates of a two-dimensional
;              pixel array of size "xsize" by "ysize" pixels, oversampled by integer factors of "hires_x"
;              and "hires_y" in the x and y directions respectively, with the origin shifted to the
;              coordinates "(x0,y0)", and with overall scale factors of "fx" and "fy" applied in the x
;              and y directions respectively.
;                By setting "fx" to "1.0", "fy" to "1.0", "x0" to "0.0", "y0" to "0.0", "hires_x" to "1"
;              and "hires_y" to "1", the simple arrays of pixel coordinates "xarr" and "yarr" are
;              obtained, each with "xsize" by "ysize" elements, where the (i,j)th element of each array
;              has the value:
;
;              xarr[i,j] = i + 0.5                                 for i = 0,1,...,(xsize - 1)
;              yarr[i,j] = j + 0.5                                 for j = 0,1,...,(ysize - 1)
;
;                The module provides options to create only one of the coordinate arrays "xarr" or "yarr"
;              via use of one of the keywords ONLY_XCOORDS or ONLY_YCOORDS.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The size (pix) of the two-dimensional pixel array in the x direction. This
;                          parameter must be positive.
;   ysize - INTEGER/LONG - The size (pix) of the two-dimensional pixel array in the y direction. This
;                          parameter must be positive.
;   fx - FLOAT/DOUBLE - The x coordinate scale factor as defined above. This parameter is ignored if the
;                       keyword ONLY_YCOORDS is set.
;   fy - FLOAT/DOUBLE - The y coordinate scale factor as defined above. This parameter is ignored if the
;                       keyword ONLY_XCOORDS is set.
;   x0 - FLOAT/DOUBLE - The x coordinate offset (pix) as defined above. This parameter is ignored if the
;                       keyword ONLY_YCOORDS is set.
;   y0 - FLOAT/DOUBLE - The y coordinate offset (pix) as defined above. This parameter is ignored if the
;                       keyword ONLY_XCOORDS is set.
;   hires_x - INTEGER/LONG - The oversampling factor of the two-dimensional pixel array in the x
;                            direction. This parameter must be positive.
;   hires_y - INTEGER/LONG - The oversampling factor of the two-dimensional pixel array in the y
;                            direction. This parameter must be positive.
;
; Output Parameters:
;
;   xarr - DOUBLE ARRAY - A two-dimensional coordinate array of size "hires_x*xsize" by "hires_y*ysize"
;                         elements representing pixel coordinates along the x-axis with values as
;                         defined above. Note that if "hires_y" and "ysize" are both set to "1", then
;                         this parameter is returned as a one-dimensional vector of length "hires_x*xsize"
;                         elements since IDL treats an Nx1 array as an N-element one-dimensional vector.
;                         If the keyword ONLY_YCOORDS is set, then this parameter is returned with the
;                         value "0.0D".
;   yarr - DOUBLE ARRAY - A two-dimensional coordinate array of size "hires_x*xsize" by "hires_y*ysize"
;                         elements representing pixel coordinates along the y-axis with values as
;                         defined above. Note that if "hires_y" and "ysize" are both set to "1", then
;                         this parameter is returned as a one-dimensional vector of length "hires_x*xsize"
;                         elements since IDL treats an Nx1 array as an N-element one-dimensional vector.
;                         If the keyword ONLY_XCOORDS is set, then this parameter is returned with the
;                         value "0.0D".
;   status - INTEGER - If the module successfully created the coordinate arrays "xarr" and "yarr",
;                      then "status" is returned with a value of "1", otherwise it is returned with a
;                      value of "0".
;
; Keywords:
;
;   If the keyword ONLY_XCOORDS is set (as "/ONLY_XCOORDS"), then the module will only create the
;   coordinate array "xarr". Note that this keyword cannot be set at the same time as the keyword
;   ONLY_YCOORDS.
;
;   If the keyword ONLY_YCOORDS is set (as "/ONLY_YCOORDS"), then the module will only create the
;   coordinate array "yarr". Note that this keyword cannot be set at the same time as the keyword
;   ONLY_XCOORDS.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
xarr = 0.0D
yarr = 0.0D
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "xsize" and "ysize" are positive numbers of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return
  if (test_intlon_scalar(ysize) NE 1) then return
  if (xsize LT 1) then return
  if (ysize LT 1) then return

  ;Check that not both of the keywords ONLY_XCOORDS and ONLY_YCOORDS are set at the same time
  if (keyword_set(only_xcoords) AND keyword_set(only_ycoords)) then return

  ;Check that "fx", "fy", "x0" and "y0" are numbers of the correct type
  if ~keyword_set(only_ycoords) then begin
    if (test_fltdbl_scalar(fx) NE 1) then return
    if (test_fltdbl_scalar(x0) NE 1) then return
  endif
  if ~keyword_set(only_xcoords) then begin
    if (test_fltdbl_scalar(fy) NE 1) then return
    if (test_fltdbl_scalar(y0) NE 1) then return
  endif

  ;Check that "hires_x" and "hires_y" are positive numbers of the correct type
  if (test_intlon_scalar(hires_x) NE 1) then return
  if (test_intlon_scalar(hires_y) NE 1) then return
  if (hires_x LT 1) then return
  if (hires_y LT 1) then return
endif
lxsize = long(hires_x)*long(xsize)
lysize = long(hires_y)*long(ysize)

;If the keyword ONLY_YCOORDS is not set
if ~keyword_set(only_ycoords) then begin

  ;Generate the coordinate array "xarr" for the two-dimensional pixel array
  fx_use = double(fx)
  dx = fx_use/double(hires_x)
  generate_arithmetic_sequence, 0.5D*dx - fx_use*double(x0), dx, lxsize, xvec, stat, /NO_PAR_CHECK
  xarr = replicate_1dvec_into_2darr(xvec, 'x', lysize, stat, /NO_PAR_CHECK)
endif

;If the keyword ONLY_XCOORDS is not set
if ~keyword_set(only_xcoords) then begin

  ;Generate the coordinate array "yarr" for the two-dimensional pixel array
  fy_use = double(fy)
  dy = fy_use/double(hires_y)
  generate_arithmetic_sequence, 0.5D*dy - fy_use*double(y0), dy, lysize, yvec, stat, /NO_PAR_CHECK
  yarr = replicate_1dvec_into_2darr(yvec, 'y', lxsize, stat, /NO_PAR_CHECK)
endif

;Set "status" to "1"
status = 1

END
