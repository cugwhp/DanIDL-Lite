PRO convert_pixel_indices_to_2darr_subscripts, xind, yind, xsize, subs, nsubs, status, NO_PAR_CHECK = no_par_check

; Description: This module converts a set of x and y pixel indices "xind" and "yind", respectively,
;              to a set of subscripts "subs" corresponding to an image array with a size of "xsize"
;              pixels along the x-axis.
;
; Input Parameters:
;
;   xind - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of pixel indices along the
;                                             image x-axis. All pixel indices must correspond to
;                                             image pixels that lie within the image area, and
;                                             therefore all elements of this parameter must have
;                                             values that are non-negative and less than "xsize".
;   yind - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of non-negative pixel indices
;                                             along the image y-axis. This parameter must have
;                                             the same number of elements as "xind".
;   xsize - INTEGER/LONG - The image size (pix) along the x-axis. This parameter must be positive.
;
; Output Parameters:
;
;   subs - LONG VECTOR - A one-dimensional vector of subscripts corresponding to the set of x
;                        and y pixel indices "xind" and "yind", respectively, for an image array
;                        with a size of "xsize" pixels along the x-axis. All elements in this
;                        output parameter are non-negative.
;   nsubs - LONG - The number of subscripts in the vector of subscripts "subs".
;   status - INTEGER - If the module successfully converted the set of x and y pixel indices,
;                      then "status" is returned with a value of "1", otherwise it is returned
;                      with a value of "0".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform
;   parameter checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
subs = [-1L]
nsubs = 0L
status = 0

;If parameter checking is not required
if keyword_set(no_par_check) then begin

  ;Determine the number of elements in "xind"
  nxind = xind.length

;If parameter checking is required
endif else begin

  ;Check that "xind" is of the correct number type
  if (test_intlon(xind) NE 1) then return
  nxind = xind.length

  ;Check that "yind" is of the correct number type, and that it has the same number of elements
  ;as "xind"
  if (test_intlon(yind) NE 1) then return
  if (yind.length NE nxind) then return

  ;Check that "xsize" is a positive number of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return
  if (xsize LT 1) then return

  ;Check that all of the elements of "xind" and "yind" are non-negative, and that all of the
  ;elements of "xind" are less than "xsize"
  if (array_equal((xind GE 0) AND (xind LT xsize) AND (yind GE 0), 1B) EQ 0B) then return
endelse
xsize_use = long(xsize)

;Convert the pixel indices "xind" and "yind" to image subscripts "subs"
if (xsize_use GT 1L) then begin
  subs = reform(long(xind) + (xsize_use*long(yind)), nxind)
endif else subs = long(reform(yind, nxind))
nsubs = nxind

;Set "status" to "1"
status = 1

END
