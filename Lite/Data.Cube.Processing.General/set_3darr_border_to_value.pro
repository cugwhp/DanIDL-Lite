FUNCTION set_3darr_border_to_value, data, border_value, xlo_bw, xhi_bw, ylo_bw, yhi_bw, zlo_bw, zhi_bw, status, NO_PAR_CHECK = no_par_check

; Description: This function sets the pixel values in the border of a data cube "data" to the value specified
;              by the parameter "border_value". The thickness of the required border (pix) on the low and high
;              x coordinate sides of the data cube is defined by the input parameters "xlo_bw" and "xhi_bw",
;              respectively. The thickness of the required border (pix) on the low and high y coordinate sides
;              of the data cube is defined by the input parameters "ylo_bw" and "yhi_bw", respectively. The
;              thickness of the required border (pix) on the low and high z coordinate sides of the data cube
;              is defined by the input parameters "zlo_bw" and "zhi_bw", respectively.
;
; Input Parameters:
;
;   data - BYTE/INTEGER/LONG/FLOAT/DOUBLE ARRAY - A data cube array for which the border pixel values are to
;                                                 be replaced.
;   border_value - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The pixel value to be used to replace the pixel values in
;                                                   the required border around the data cube "data". This
;                                                   input parameter will be converted to match the variable
;                                                   type of the data cube "data" before being used to replace
;                                                   the pixel values in "data".
;   xlo_bw - INTEGER/LONG - The thickness of the required border (pix) on the low x coordinate side of the
;                           data cube. If this parameter is zero or negative, then no border pixels on the low
;                           x coordinate side of the data cube will be modified.
;   xhi_bw - INTEGER/LONG - The thickness of the required border (pix) on the high x coordinate side of the
;                           data cube. If this parameter is zero or negative, then no border pixels on the
;                           high x coordinate side of the data cube will be modified.
;   ylo_bw - INTEGER/LONG - The thickness of the required border (pix) on the low y coordinate side of the
;                           data cube. If this parameter is zero or negative, then no border pixels on the low
;                           y coordinate side of the data cube will be modified.
;   yhi_bw - INTEGER/LONG - The thickness of the required border (pix) on the high y coordinate side of the
;                           data cube. If this parameter is zero or negative, then no border pixels on the
;                           high y coordinate side of the data cube will be modified.
;   zlo_bw - INTEGER/LONG - The thickness of the required border (pix) on the low z coordinate side of the
;                           data cube. If this parameter is zero or negative, then no border pixels on the low
;                           z coordinate side of the data cube will be modified.
;   zhi_bw - INTEGER/LONG - The thickness of the required border (pix) on the high z coordinate side of the
;                           data cube. If this parameter is zero or negative, then no border pixels on the
;                           high z coordinate side of the data cube will be modified.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully replaced the pixel values in the required border of the
;                      input data cube, then "status" is returned with a value of "1", otherwise it is
;                      returned with a value of "0".
;
; Return Value:
;
;   The return value is a modified version of the data cube array "data" where the required border pixel values
;   have been replaced with the value specified by "border_value". Therefore the return value is also a data
;   cube array of the same size and number type as "data".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;If parameter checking is not required
if keyword_set(no_par_check) then begin

  ;Determine the dimensions of "data"
  result = data.dim
  xsize = result[0]
  ysize = result[1]
  zsize = result[2]

;If parameter checking is required
endif else begin

  ;Check that "data" is a data cube of the correct number type
  test_bytintlonfltdbl_3darr, data, dstat, xsize, ysize, zsize, dtype
  if (dstat EQ 0) then return, 0.0D

  ;Check that "border_value" is a number of the correct type
  if (test_bytintlonfltdbl_scalar(border_value) NE 1) then return, 0.0D

  ;Check that "xlo_bw", "xhi_bw", "ylo_bw", "yhi_bw", "zlo_bw" and "zhi_bw" are all numbers of the correct type
  if (test_intlon_scalar(xlo_bw) NE 1) then return, 0.0D
  if (test_intlon_scalar(xhi_bw) NE 1) then return, 0.0D
  if (test_intlon_scalar(ylo_bw) NE 1) then return, 0.0D
  if (test_intlon_scalar(yhi_bw) NE 1) then return, 0.0D
  if (test_intlon_scalar(zlo_bw) NE 1) then return, 0.0D
  if (test_intlon_scalar(zhi_bw) NE 1) then return, 0.0D
endelse
xlo_bw_use = long(xlo_bw) > 0L
xhi_bw_use = long(xhi_bw) > 0L
ylo_bw_use = long(ylo_bw) > 0L
yhi_bw_use = long(yhi_bw) > 0L
zlo_bw_use = long(zlo_bw) > 0L
zhi_bw_use = long(zhi_bw) > 0L

;Set up the output data cube
data_out = data

;If the thickness of the required border covers all of the data cube pixels
if (((xlo_bw_use + xhi_bw_use) GE xsize) OR ((ylo_bw_use + yhi_bw_use) GE ysize) OR ((zlo_bw_use + zhi_bw_use) GE zsize)) then begin

  ;Set all of the data cube pixels to the value specified by "border_value"
  replicate_inplace, data_out, border_value

;If the thickness of the required border does not cover all of the data cube pixels
endif else begin

  ;If the border on the low x coordinate side of the data cube is at least one pixel thick, then replace the
  ;pixel values in this border volume with the value specified by "border_value"
  if (xlo_bw_use GT 0L) then data_out[0L:(xlo_bw_use - 1L), *, *] = border_value

  ;If the border on the high x coordinate side of the data cube is at least one pixel thick, then replace the
  ;pixel values in this border volume with the value specified by "border_value"
  if (xhi_bw_use GT 0L) then data_out[(xsize - xhi_bw_use):(xsize - 1L), *, *] = border_value

  ;If the border on the low y coordinate side of the data cube is at least one pixel thick, then replace the
  ;pixel values in this border volume with the value specified by "border_value"
  if (ylo_bw_use GT 0L) then data_out[*, 0L:(ylo_bw_use - 1L), *] = border_value

  ;If the border on the high y coordinate side of the data cube is at least one pixel thick, then replace the
  ;pixel values in this border volume with the value specified by "border_value"
  if (yhi_bw_use GT 0L) then data_out[*, (ysize - yhi_bw_use):(ysize - 1L), *] = border_value

  ;If the border on the low z coordinate side of the data cube is at least one pixel thick, then replace the
  ;pixel values in this border volume with the value specified by "border_value"
  if (zlo_bw_use GT 0L) then data_out[*, *, 0L:(zlo_bw_use - 1L)] = border_value

  ;If the border on the high z coordinate side of the data cube is at least one pixel thick, then replace the
  ;pixel values in this border volume with the value specified by "border_value"
  if (zhi_bw_use GT 0L) then data_out[*, *, (zsize - zhi_bw_use):(zsize - 1L)] = border_value
endelse

;Set "status" to "1"
status = 1

;Return the output data cube
return, data_out

END
