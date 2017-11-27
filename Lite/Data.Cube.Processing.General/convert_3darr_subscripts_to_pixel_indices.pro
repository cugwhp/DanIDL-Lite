PRO convert_3darr_subscripts_to_pixel_indices, subs, xsize, ysize, xind, yind, zind, nind, status, NO_PAR_CHECK = no_par_check

; Description: This module converts a set of subscripts "subs" to a set of x, y and z pixel indices
;              "xind", "yind" and "zind", respectively, corresponding to a data cube array with a
;              size of "xsize" and "ysize" pixels along the x- and y-axes, respectively.
;
; Input Parameters:
;
;   subs - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of non-negative subscripts.
;   xsize - INTEGER/LONG - The data cube size along the x-axis (pix). This parameter must be
;                          positive.
;   ysize - INTEGER/LONG - The data cube size along the y-axis (pix). This parameter must be
;                          positive.
;
; Output Parameters:
;
;   xind - LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of pixel indices along the data cube
;                                     x-axis corresponding to the set of subscripts "subs" for a
;                                     data cube array with a size of "xsize" and "ysize" pixels
;                                     along the x- and y-axes, respectively. This output parameter
;                                     has the same dimensions as the input parameter "subs".
;                                     Furthermore, all elements in this output parameter are
;                                     non-negative and less than "xsize".
;   yind - LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of pixel indices along the data cube
;                                     y-axis corresponding to the set of subscripts "subs" for a
;                                     data cube array with a size of "xsize" and "ysize" pixels
;                                     along the x- and y-axes, respectively. This output parameter
;                                     has the same dimensions as the input parameter "subs".
;                                     Furthermore, all elements in this output parameter are
;                                     non-negative and less than "ysize".
;   zind - LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of pixel indices along the data cube
;                                     z-axis corresponding to the set of subscripts "subs" for a
;                                     data cube array with a size of "xsize" and "ysize" pixels
;                                     along the x- and y-axes, respectively. This output parameter
;                                     has the same dimensions as the input parameter "subs".
;                                     Furthermore, all elements in this output parameter are
;                                     non-negative.
;   nind - LONG - The number of pixel indices in each of the output parameters "xind", "yind"
;                 and "zind".
;   status - INTEGER - If the module successfully converted the set of subscripts, then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of
;                      "0".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform
;   parameter checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
xind = 0L
yind = 0L
zind = 0L
nind = 0L
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "subs" is of the correct number type and that it does not have any negative elements
  if (test_intlon(subs) NE 1) then return
  if (array_equal(subs GE 0, 1B) EQ 0B) then return

  ;Check that "xsize" is a positive number of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return
  if (xsize LT 1) then return

  ;Check that "ysize" is a positive number of the correct type
  if (test_intlon_scalar(ysize) NE 1) then return
  if (ysize LT 1) then return
endif
subs_use = long(subs)
xsize_use = long(xsize)
ysize_use = long(ysize)

;Convert the subscripts "subs" to pixel indices "xind", "yind" and "zind"
if (xsize_use GT 1L) then begin
  if (ysize_use GT 1L) then begin
    xsize_times_ysize = xsize_use*ysize_use
    zind = floor(subs_use*(1.0D/double(xsize_times_ysize)))
    subs_use = temporary(subs_use) mod xsize_times_ysize
    yind = floor(subs_use*(1.0D/double(xsize_use)))
  endif else begin
    zind = floor(subs_use*(1.0D/double(xsize_use)))
    yind = subs_use
    replicate_inplace, yind, 0L
  endelse
  xind = subs_use mod xsize_use
endif else begin
  xind = subs_use
  replicate_inplace, xind, 0L
  if (ysize_use GT 1L) then begin
    zind = floor(subs_use*(1.0D/double(ysize_use)))
    yind = subs_use mod ysize_use
  endif else begin
    zind = subs_use
    yind = xind
  endelse
endelse
nind = xind.length

;Set "status" to "1"
status = 1

END
