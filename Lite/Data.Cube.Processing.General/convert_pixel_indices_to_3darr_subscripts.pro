PRO convert_pixel_indices_to_3darr_subscripts, xind, yind, zind, xsize, ysize, subs, nsubs, status, NO_PAR_CHECK = no_par_check

; Description: This module converts a set of x, y and z pixel indices "xind", "yind" and "zind",
;              respectively, to a set of subscripts "subs" corresponding to a data cube array with
;              a size of "xsize" and "ysize" pixels along the x- and y-axes, respectively.
;
; Input Parameters:
;
;   xind - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of pixel indices along the
;                                             data cube x-axis. All pixel indices must correspond
;                                             to data cube pixels that lie within the data cube
;                                             volume, and therefore all elements of this parameter
;                                             must have values that are non-negative and less than
;                                             "xsize".
;   yind - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of pixel indices along the
;                                             data cube y-axis. All pixel indices must correspond
;                                             to data cube pixels that lie within the data cube
;                                             volume, and therefore all elements of this parameter
;                                             must have values that are non-negative and less than
;                                             "ysize". This parameter must have the same number of
;                                             elements as "xind".
;   zind - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of non-negative pixel indices
;                                             along the data cube z-axis. This parameter must have
;                                             the same number of elements as "xind".
;   xsize - INTEGER/LONG - The data cube size along the x-axis (pix). This parameter must be
;                          positive.
;   ysize - INTEGER/LONG - The data cube size along the y-axis (pix). This parameter must be
;                          positive.
;
; Output Parameters:
;
;   subs - LONG VECTOR - A one-dimensional vector of subscripts corresponding to the set of x, y
;                        and z pixel indices "xind", "yind" and "zind", respectively, for a data
;                        cube array with a size of "xsize" and "ysize" pixels along the x- and
;                        y-axes, respectively. All elements in this output parameter are
;                        non-negative.
;   nsubs - LONG - The number of subscripts in the vector of subscripts "subs".
;   status - INTEGER - If the module successfully converted the set of x, y and z pixel indices,
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

  ;Check that "zind" is of the correct number type, and that it has the same number of elements
  ;as "xind"
  if (test_intlon(zind) NE 1) then return
  if (zind.length NE nxind) then return

  ;Check that "xsize" is a positive number of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return
  if (xsize LT 1) then return

  ;Check that "ysize" is a positive number of the correct type
  if (test_intlon_scalar(ysize) NE 1) then return
  if (ysize LT 1) then return

  ;Check that all of the elements of "xind", "yind" and "zind" are non-negative, and that all of
  ;the elements of "xind" and "yind" are less than "xsize" and "ysize", respectively
  if (array_equal((xind GE 0) AND (xind LT xsize) AND (yind GE 0) AND (yind LT ysize) AND (zind GE 0), 1B) EQ 0B) then return
endelse
xsize_use = long(xsize)
ysize_use = long(ysize)

;Convert the pixel indices "xind", "yind" and "zind" to data cube subscripts "subs"
if (xsize_use GT 1L) then begin
  if (ysize_use GT 1L) then begin
    subs = reform(long(xind) + (xsize_use*(long(yind) + (ysize_use*long(zind)))), nxind)
  endif else subs = reform(long(xind) + (xsize_use*long(zind)), nxind)
endif else begin
  if (ysize_use GT 1L) then begin
    subs = reform(long(yind) + (ysize_use*long(zind)), nxind)
  endif else subs = long(reform(zind, nxind))
endelse
nsubs = nxind

;Set "status" to "1"
status = 1

END
