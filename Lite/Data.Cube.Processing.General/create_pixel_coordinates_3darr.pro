PRO create_pixel_coordinates_3darr, xsize, ysize, zsize, fx, fy, fz, x0, y0, z0, hires_x, hires_y, hires_z, xarr, yarr, zarr, status, ONLY_XCOORDS = only_xcoords, $
                                    ONLY_YCOORDS = only_ycoords, ONLY_ZCOORDS = only_zcoords, NO_PAR_CHECK = no_par_check

; Description: This module creates the three-dimensional coordinate arrays "xarr", "yarr" and "zarr",
;              each with "hires_x*xsize" by "hires_y*ysize" by "hires_z*zsize" elements, where the
;              (i,j,k)th element of each array has the value:
;
;              xarr[i,j,k] = fx*(((i + 0.5)/hires_x) - x0)           for i = 0,1,...,(hires_x*xsize - 1)
;              yarr[i,j,k] = fy*(((j + 0.5)/hires_y) - y0)           for j = 0,1,...,(hires_y*ysize - 1)
;              zarr[i,j,k] = fz*(((k + 0.5)/hires_z) - z0)           for k = 0,1,...,(hires_z*zsize - 1)
;
;              These coordinate arrays represent the x, y and z pixel coordinates of a three-dimensional
;              pixel array of size "xsize" by "ysize" by "zsize" pixels, oversampled by integer factors
;              of "hires_x", "hires_y" and "hires_z" in the x, y and z directions respectively, with the
;              origin shifted to the coordinates "(x0,y0,z0)", and with overall scale factors of "fx",
;              "fy" and "fz" applied in the x, y and z directions respectively.
;                By setting "fx" to "1.0", "fy" to "1.0", "fz" to "1.0", "x0" to "0.0", "y0" to "0.0",
;              "z0" to "0.0", "hires_x" to "1", "hires_y" to "1" and "hires_z" to "1", the simple arrays
;              of pixel coordinates "xarr", "yarr" and "zarr" are obtained, each with "xsize" by "ysize"
;              by "zsize" elements, where the (i,j,k)th element of each array has the value:
;
;              xarr[i,j,k] = i + 0.5                                 for i = 0,1,...,(xsize - 1)
;              yarr[i,j,k] = j + 0.5                                 for j = 0,1,...,(ysize - 1)
;              zarr[i,j,k] = k + 0.5                                 for k = 0,1,...,(zsize - 1)
;
;                The module provides options to create only one of the coordinate arrays "xarr", "yarr"
;              or "zarr" via use of one of the keywords ONLY_XCOORDS, ONLY_YCOORDS or ONLY_ZCOORDS.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The size (pix) of the three-dimensional pixel array in the x direction. This
;                          parameter must be positive.
;   ysize - INTEGER/LONG - The size (pix) of the three-dimensional pixel array in the y direction. This
;                          parameter must be positive.
;   zsize - INTEGER/LONG - The size (pix) of the three-dimensional pixel array in the z direction. This
;                          parameter must be positive.
;   fx - FLOAT/DOUBLE - The x coordinate scale factor as defined above. This parameter is ignored if
;                       either of the keywords ONLY_YCOORDS or ONLY_ZCOORDS are set.
;   fy - FLOAT/DOUBLE - The y coordinate scale factor as defined above. This parameter is ignored if
;                       either of the keywords ONLY_XCOORDS or ONLY_ZCOORDS are set.
;   fz - FLOAT/DOUBLE - The z coordinate scale factor as defined above. This parameter is ignored if
;                       either of the keywords ONLY_XCOORDS or ONLY_YCOORDS are set.
;   x0 - FLOAT/DOUBLE - The x coordinate offset (pix) as defined above. This parameter is ignored if
;                       either of the keywords ONLY_YCOORDS or ONLY_ZCOORDS are set.
;   y0 - FLOAT/DOUBLE - The y coordinate offset (pix) as defined above. This parameter is ignored if
;                       either of the keywords ONLY_XCOORDS or ONLY_ZCOORDS are set.
;   z0 - FLOAT/DOUBLE - The z coordinate offset (pix) as defined above. This parameter is ignored if
;                       either of the keywords ONLY_XCOORDS or ONLY_YCOORDS are set.
;   hires_x - INTEGER/LONG - The oversampling factor of the three-dimensional pixel array in the x
;                            direction. This parameter must be positive.
;   hires_y - INTEGER/LONG - The oversampling factor of the three-dimensional pixel array in the y
;                            direction. This parameter must be positive.
;   hires_z - INTEGER/LONG - The oversampling factor of the three-dimensional pixel array in the z
;                            direction. This parameter must be positive.
;
; Output Parameters:
;
;   xarr - DOUBLE ARRAY - A three-dimensional coordinate array of size "hires_x*xsize" by "hires_y*ysize"
;                         by "hires_z*zsize" elements representing pixel coordinates along the x-axis
;                         with values as defined above. Note that if "hires_y", "ysize", "hires_z" and
;                         "zsize" are all set to "1", then this parameter is returned as a one-dimensional
;                         vector of length "hires_x*xsize" elements since IDL treats an Nx1x1 array as an
;                         N-element one-dimensional vector. Also, if only "hires_z" and "zsize" are both
;                         set to "1", then this parameter is returned as a two-dimensional array of size
;                         "hires_x*xsize" by "hires_y*ysize" elements since IDL treats an MxNx1 array as
;                         an MxN-element two-dimensional array. If either of the keywords ONLY_YCOORDS or
;                         ONLY_ZCOORDS are set, then this parameter is returned with the value "0.0D".
;   yarr - DOUBLE ARRAY - A three-dimensional coordinate array of size "hires_x*xsize" by "hires_y*ysize"
;                         by "hires_z*zsize" elements representing pixel coordinates along the y-axis
;                         with values as defined above. Note that if "hires_y", "ysize", "hires_z" and
;                         "zsize" are all set to "1", then this parameter is returned as a one-dimensional
;                         vector of length "hires_x*xsize" elements since IDL treats an Nx1x1 array as an
;                         N-element one-dimensional vector. Also, if only "hires_z" and "zsize" are both
;                         set to "1", then this parameter is returned as a two-dimensional array of size
;                         "hires_x*xsize" by "hires_y*ysize" elements since IDL treats an MxNx1 array as
;                         an MxN-element two-dimensional array. If either of the keywords ONLY_XCOORDS or
;                         ONLY_ZCOORDS are set, then this parameter is returned with the value "0.0D".
;   zarr - DOUBLE ARRAY - A three-dimensional coordinate array of size "hires_x*xsize" by "hires_y*ysize"
;                         by "hires_z*zsize" elements representing pixel coordinates along the z-axis
;                         with values as defined above. Note that if "hires_y", "ysize", "hires_z" and
;                         "zsize" are all set to "1", then this parameter is returned as a one-dimensional
;                         vector of length "hires_x*xsize" elements since IDL treats an Nx1x1 array as an
;                         N-element one-dimensional vector. Also, if only "hires_z" and "zsize" are both
;                         set to "1", then this parameter is returned as a two-dimensional array of size
;                         "hires_x*xsize" by "hires_y*ysize" elements since IDL treats an MxNx1 array as
;                         an MxN-element two-dimensional array. If either of the keywords ONLY_XCOORDS or
;                         ONLY_YCOORDS are set, then this parameter is returned with the value "0.0D".
;   status - INTEGER - If the module successfully created the coordinate arrays "xarr", "yarr" and "zarr",
;                      then "status" is returned with a value of "1", otherwise it is returned with a
;                      value of "0".
;
; Keywords:
;
;   If the keyword ONLY_XCOORDS is set (as "/ONLY_XCOORDS"), then the module will only create the
;   coordinate array "xarr". Note that this keyword cannot be set at the same time as either of the
;   keywords ONLY_YCOORDS or ONLY_ZCOORDS.
;
;   If the keyword ONLY_YCOORDS is set (as "/ONLY_YCOORDS"), then the module will only create the
;   coordinate array "yarr". Note that this keyword cannot be set at the same time as either of the
;   keywords ONLY_XCOORDS or ONLY_ZCOORDS.
;
;   If the keyword ONLY_ZCOORDS is set (as "/ONLY_ZCOORDS"), then the module will only create the
;   coordinate array "zarr". Note that this keyword cannot be set at the same time as either of the
;   keywords ONLY_XCOORDS or ONLY_YCOORDS.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
xarr = 0.0D
yarr = 0.0D
zarr = 0.0D
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "xsize", "ysize" and "zsize" are positive numbers of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return
  if (test_intlon_scalar(ysize) NE 1) then return
  if (test_intlon_scalar(zsize) NE 1) then return
  if (xsize LT 1) then return
  if (ysize LT 1) then return
  if (zsize LT 1) then return

  ;Check that at most only one of the keywords ONLY_XCOORDS, ONLY_YCOORDS or ONLY_ZCOORDS are set
  if keyword_set(only_xcoords) then begin
    if keyword_set(only_ycoords) then return
    if keyword_set(only_zcoords) then return
  endif else begin
    if (keyword_set(only_ycoords) AND keyword_set(only_zcoords)) then return
  endelse

  ;Check that "fx", "fy", "fz", "x0", "y0" and "z0" are numbers of the correct type
  if (~keyword_set(only_ycoords) AND ~keyword_set(only_zcoords)) then begin
    if (test_fltdbl_scalar(fx) NE 1) then return
    if (test_fltdbl_scalar(x0) NE 1) then return
  endif
  if (~keyword_set(only_xcoords) AND ~keyword_set(only_zcoords)) then begin
    if (test_fltdbl_scalar(fy) NE 1) then return
    if (test_fltdbl_scalar(y0) NE 1) then return
  endif
  if (~keyword_set(only_xcoords) AND ~keyword_set(only_ycoords)) then begin
    if (test_fltdbl_scalar(fz) NE 1) then return
    if (test_fltdbl_scalar(z0) NE 1) then return
  endif

  ;Check that "hires_x", "hires_y" and "hires_z" are positive numbers of the correct type
  if (test_intlon_scalar(hires_x) NE 1) then return
  if (test_intlon_scalar(hires_y) NE 1) then return
  if (test_intlon_scalar(hires_z) NE 1) then return
  if (hires_x LT 1) then return
  if (hires_y LT 1) then return
  if (hires_z LT 1) then return
endif
lxsize = long(hires_x)*long(xsize)
lysize = long(hires_y)*long(ysize)
lzsize = long(hires_z)*long(zsize)

;If the keywords ONLY_YCOORDS and ONLY_ZCOORDS are not set
if (~keyword_set(only_ycoords) AND ~keyword_set(only_zcoords)) then begin

  ;Generate the coordinate array "xarr" for the three-dimensional pixel array
  fx_use = double(fx)
  dx = fx_use/double(hires_x)
  generate_arithmetic_sequence, 0.5D*dx - fx_use*double(x0), dx, lxsize, xvec, stat, /NO_PAR_CHECK
  xarr = replicate_1dvec_into_3darr(xvec, 'x', lysize, lzsize, stat, /NO_PAR_CHECK)
endif

;If the keywords ONLY_XCOORDS and ONLY_ZCOORDS are not set
if (~keyword_set(only_xcoords) AND ~keyword_set(only_zcoords)) then begin

  ;Generate the coordinate array "yarr" for the three-dimensional pixel array
  fy_use = double(fy)
  dy = fy_use/double(hires_y)
  generate_arithmetic_sequence, 0.5D*dy - fy_use*double(y0), dy, lysize, yvec, stat, /NO_PAR_CHECK
  yarr = replicate_1dvec_into_3darr(yvec, 'y', lxsize, lzsize, stat, /NO_PAR_CHECK)
endif

;If the keywords ONLY_XCOORDS and ONLY_YCOORDS are not set
if (~keyword_set(only_xcoords) AND ~keyword_set(only_ycoords)) then begin

  ;Generate the coordinate array "zarr" for the three-dimensional pixel array
  fz_use = double(fz)
  dz = fz_use/double(hires_z)
  generate_arithmetic_sequence, 0.5D*dz - fz_use*double(z0), dz, lzsize, zvec, stat, /NO_PAR_CHECK
  zarr = replicate_1dvec_into_3darr(zvec, 'z', lxsize, lysize, stat, /NO_PAR_CHECK)
endif

;Set "status" to "1"
status = 1

END
