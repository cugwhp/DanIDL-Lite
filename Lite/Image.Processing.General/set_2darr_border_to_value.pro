FUNCTION set_2darr_border_to_value, imdata, border_value, xlo_bw, xhi_bw, ylo_bw, yhi_bw, status, NO_PAR_CHECK = no_par_check

; Description: This function sets the pixel values in the border of an image "imdata" to the value specified by
;              the parameter "border_value". The thickness of the required border (pix) on the left and right
;              hand sides of the image is defined by the input parameters "xlo_bw" and "xhi_bw", respectively.
;              The thickness of the required border (pix) at the bottom and top of the image is defined by the
;              input parameters "ylo_bw" and "yhi_bw", respectively.
;
; Input Parameters:
;
;   imdata - BYTE/INTEGER/LONG/FLOAT/DOUBLE ARRAY - An image array for which the border pixel values are to be
;                                                   replaced.
;   border_value - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The pixel value to be used to replace the pixel values in
;                                                   the required border around the image "imdata". This input
;                                                   parameter will be converted to match the variable type of
;                                                   the image data "imdata" before being used to replace the
;                                                   pixel values in "imdata".
;   xlo_bw - INTEGER/LONG - The thickness of the required border (pix) on the left hand side of the image. If
;                           this parameter is zero or negative, then no border pixels on the left hand side
;                           of the image will be modified.
;   xhi_bw - INTEGER/LONG - The thickness of the required border (pix) on the right hand side of the image. If
;                           this parameter is zero or negative, then no border pixels on the right hand side
;                           of the image will be modified.
;   ylo_bw - INTEGER/LONG - The thickness of the required border (pix) at the bottom of the image. If this
;                           parameter is zero or negative, then no border pixels at the bottom of the image
;                           will be modified.
;   yhi_bw - INTEGER/LONG - The thickness of the required border (pix) at the top of the image. If this
;                           parameter is zero or negative, then no border pixels at the top of the image will
;                           be modified.
;   status - ANY - A variable which will be used to contain the output status of the function on returning (see
;                  output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully replaced the pixel values in the required border of the
;                      input image, then "status" is returned with a value of "1", otherwise it is returned
;                      with a value of "0".
;
; Return Value:
;
;   The return value is a modified version of the image array "imdata" where the required border pixel values
;   have been replaced with the value specified by "border_value". Therefore the return value is also an image
;   array of the same size and number type as "imdata".
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

  ;Determine the dimensions of "imdata"
  result = imdata.dim
  imxsize = result[0]
  imysize = result[1]

;If parameter checking is required
endif else begin

  ;Check that "imdata" is an image of the correct number type
  test_bytintlonfltdbl_2darr, imdata, imstat, imxsize, imysize, imtype
  if (imstat EQ 0) then return, 0.0D

  ;Check that "border_value" is a number of the correct type
  if (test_bytintlonfltdbl_scalar(border_value) NE 1) then return, 0.0D

  ;Check that "xlo_bw", "xhi_bw", "ylo_bw", and "yhi_bw" are all numbers of the correct type
  if (test_intlon_scalar(xlo_bw) NE 1) then return, 0.0D
  if (test_intlon_scalar(xhi_bw) NE 1) then return, 0.0D
  if (test_intlon_scalar(ylo_bw) NE 1) then return, 0.0D
  if (test_intlon_scalar(yhi_bw) NE 1) then return, 0.0D
endelse
xlo_bw_use = long(xlo_bw) > 0L
xhi_bw_use = long(xhi_bw) > 0L
ylo_bw_use = long(ylo_bw) > 0L
yhi_bw_use = long(yhi_bw) > 0L

;Set up the output image
im_out = imdata

;If the thickness of the required border covers all of the image pixels
if (((xlo_bw_use + xhi_bw_use) GE imxsize) OR ((ylo_bw_use + yhi_bw_use) GE imysize)) then begin

  ;Set all of the image pixels to the value specified by "border_value"
  replicate_inplace, im_out, border_value

;If the thickness of the required border does not cover all of the image pixels
endif else begin

  ;If the border on the left hand side of the image is at least one pixel thick, then replace the pixel values
  ;in this border area with the value specified by "border_value"
  if (xlo_bw_use GT 0L) then im_out[0L:(xlo_bw_use - 1L), *] = border_value

  ;If the border on the right hand side of the image is at least one pixel thick, then replace the pixel values
  ;in this border area with the value specified by "border_value"
  if (xhi_bw_use GT 0L) then im_out[(imxsize - xhi_bw_use):(imxsize - 1L), *] = border_value

  ;If the border at the bottom of the image is at least one pixel thick, then replace the pixel values in this
  ;border area with the value specified by "border_value"
  if (ylo_bw_use GT 0L) then im_out[*, 0L:(ylo_bw_use - 1L)] = border_value

  ;If the border at the top of the image is at least one pixel thick, then replace the pixel values in this
  ;border area with the value specified by "border_value"
  if (yhi_bw_use GT 0L) then im_out[*, (imysize - yhi_bw_use):(imysize - 1L)] = border_value
endelse

;Set "status" to "1"
status = 1

;Return the output image
return, im_out

END
