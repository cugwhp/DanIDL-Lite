PRO create_minimal_size_kernel, ker_in, ker_out, hkxsize, kxsize, hkysize, kysize, hkzsize, kzsize, status

; Description: This module removes any zero padding from an input one-, two- or three-dimensional convolution
;              kernel "ker_in" by stripping the kernel of any outer rows/columns/slices that contain only zeros
;              until it is the minimum size possible that still contains the original non-zero kernel values while
;              respecting the original symmetry of the kernel dimensions. Accordingly the size of each dimension
;              of the input kernel must be an odd number. A one-dimensional input kernel will be processed to
;              yield a one-dimensional output kernel. A two-dimensional input kernel will be processed to yield
;              either a one- or two-dimensional output kernel as appropriate. However, due to the way that the
;              convolution function "convol" in IDL works, a three-dimensional input kernel will be processed to
;              yield either a one- or three-dimensional output kernel as appropriate, but never a two-dimensional
;              output kernel even if the third dimension can be fully stripped.
;                The output convolution kernel is returned via the parameter "ker_out" with size "kxsize" by
;              "kysize" by "kzsize" pixels. The kernel half-sizes are also returned via the parameters "hkxsize",
;              "hkysize" and "hkzsize".
;
; Input Parameters:
;
;   ker_in - BYTE/INTEGER/LONG/FLOAT/DOUBLE VECTOR/ARRAY - A one-dimensional vector, or a two- or three-dimensional
;                                                          array, containing the input convolution kernel of size
;                                                          Nx by Ny by Nz pixels, where Nx, Ny and Nz are all odd
;                                                          numbers. Note that for the purposes of this module, a
;                                                          one-dimensional vector is considered to represent a
;                                                          convolution kernel of size Nx by 1 by 1 pixels, and a
;                                                          two-dimensional array is considered to represent a
;                                                          convolution kernel of size Nx by Ny by 1 pixels.
;
; Output Parameters:
;
;   ker_out - VECTOR/ARRAY (same type as "ker_in") - A one-dimensional vector, or a two- or three-dimensional array,
;                                                    containing the output convolution kernel of size "kxsize" by
;                                                    "kysize" by "kzsize" pixels, where "kxsize", "kysize" and
;                                                    "kzsize" are odd numbers. The output kernel "ker_out" is the
;                                                    same as the input kernel "ker_in" except that any zero padding
;                                                    has been removed and consequently the number of dimensions may
;                                                    be less. Note that a one-dimensional input kernel yields a
;                                                    one-dimensional output kernel, and that a two-dimensional input
;                                                    kernel yields either a one- or two-dimensional output kernel as
;                                                    appropriate. However, due to the way that the convolution
;                                                    function "convol" in IDL works, a three-dimensional input kernel
;                                                    yields either a one- or three-dimensional output kernel as
;                                                    appropriate, but never a two-dimensional output kernel even if
;                                                    the third dimension can be fully stripped.
;   hkxsize - LONG - The output convolution kernel half-size (pix) along the x-axis such that the size of the output
;                    kernel along the x-axis is "(2*hkxsize) + 1" pixels.
;   kxsize - LONG - The output convolution kernel size (pix) along the x-axis with the value "(2*hkxsize) + 1".
;   hkysize - LONG - The output convolution kernel half-size (pix) along the y-axis such that the size of the output
;                    kernel along the y-axis is "(2*hkysize) + 1" pixels.
;   kysize - LONG - The output convolution kernel size (pix) along the y-axis with the value "(2*hkysize) + 1".
;   hkzsize - LONG - The output convolution kernel half-size (pix) along the z-axis such that the size of the output
;                    kernel along the z-axis is "(2*hkzsize) + 1" pixels.
;   kzsize - LONG - The output convolution kernel size (pix) along the z-axis with the value "(2*hkzsize) + 1".
;   status - INTEGER - If the module successfully created the minimal size output convolution kernel, then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of "0".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
ker_out = [0.0D]
hkxsize = 0L
kxsize = 0L
hkysize = 0L
kysize = 0L
hkzsize = 0L
kzsize = 0L
status = 0

;Check that "ker_in" is a one-dimensional vector, or a two- or three-dimensional array, of the correct number type
;and with odd-sized dimensions
if (test_bytintlonfltdbl(ker_in) NE 1) then return
result = size(ker_in)
ndim = result[0]
if (ndim EQ 1L) then begin
  kxsize_in = result[1]
  kysize_in = 1L
  kzsize_in = 1L
  if ((kxsize_in mod 2L) EQ 0L) then return
endif else if (ndim EQ 2L) then begin
  kxsize_in = result[1]
  kysize_in = result[2]
  kzsize_in = 1L
  if ((kxsize_in mod 2L) EQ 0L) then return
  if ((kysize_in mod 2L) EQ 0L) then return
endif else if (ndim EQ 3L) then begin
  kxsize_in = result[1]
  kysize_in = result[2]
  kzsize_in = result[3]
  if ((kxsize_in mod 2L) EQ 0L) then return
  if ((kysize_in mod 2L) EQ 0L) then return
  if ((kzsize_in mod 2L) EQ 0L) then return
endif else return

;Set up some of the output parameters including setting "status" to "1"
kxsize = kxsize_in
kysize = kysize_in
kzsize = kzsize_in
hkxsize = (kxsize - 1L)/2L
hkysize = (kysize - 1L)/2L
hkzsize = (kzsize - 1L)/2L
status = 1

;If "ker_in" has only one element, then the minimal size output kernel is the same size as the input kernel and
;there is nothing to do, so the module will return
nker = ker_in.length
if (nker EQ 1L) then begin
  ker_out = ker_in
  return
endif

;Determine the subscripts of the non-zero kernel values in the input kernel
subs = where(ker_in NE 0B, nsubs)

;If all of the kernel values are non-zero, then the minimal size output kernel is the same size as the input kernel
;and there is nothing to do, so the module will return
if (nsubs EQ nker) then begin
  ker_out = ker_in
  return
endif

;If all of the kernel values are zero, then create the minimal size output convolution kernel, which in this case is
;a single-element one-dimensional vector, and then return
if (nsubs EQ 0L) then begin
  if (ndim EQ 1L) then begin
    ker_out = [ker_in[hkxsize]]
  endif else if (ndim EQ 2L) then begin
    ker_out = [ker_in[hkxsize, hkysize]]
    hkysize = 0L
    kysize = 1L
  endif else if (ndim EQ 3L) then begin
    ker_out = [ker_in[hkxsize, hkysize, hkzsize]]
    hkysize = 0L
    kysize = 1L
    hkzsize = 0L
    kzsize = 1L
  endif
  hkxsize = 0L
  kxsize = 1L
  return
endif

;If "ker_in" is a one-dimensional vector
if (ndim EQ 1L) then begin

  ;Determine the minimum kernel size along the x-axis and create the minimal size output convolution kernel
  dsx = abs(subs[0] - hkxsize) > abs(subs[nsubs - 1L] - hkxsize)
  if (dsx LT hkxsize) then begin
    ker_out = ker_in[(hkxsize - dsx):(hkxsize + dsx)]
    hkxsize = dsx
    kxsize = (2L*hkxsize) + 1L
  endif else ker_out = ker_in

;If "ker_in" is a two-dimensional array
endif else if (ndim EQ 2L) then begin

  ;If the first dimension of "ker_in" is of size "1"
  if (kxsize EQ 1L) then begin

    ;Determine the minimum kernel size along the y-axis and create the minimal size output convolution kernel
    dsy = abs(subs[0] - hkysize) > abs(subs[nsubs - 1L] - hkysize)
    if (dsy LT hkysize) then begin
      ker_out = ker_in[0L, (hkysize - dsy):(hkysize + dsy)]
      hkysize = dsy
      kysize = (2L*hkysize) + 1L
    endif else ker_out = ker_in

  ;If the first dimension of "ker_in" is of size greater than "1"
  endif else begin

    ;Convert the subscripts for the non-zero kernel values into pixel indices along the x- and y-axes of the input
    ;kernel
    convert_2darr_subscripts_to_pixel_indices, subs, kxsize, xind, yind, nind, stat, /NO_PAR_CHECK

    ;Determine the minimum and maximum values of the pixel indices for the non-zero kernel values along the x- and
    ;y-axes of the input kernel, and use this to determine the minimum kernel size along the x- and y-axes
    xind_min = min(xind, MAX = xind_max)
    dsx = abs(xind_min - hkxsize) > abs(xind_max - hkxsize)
    yind_min = min(yind, MAX = yind_max)
    dsy = abs(yind_min - hkysize) > abs(yind_max - hkysize)

    ;Create the minimal size output convolution kernel
    if ((dsx LT hkxsize) OR (dsy LT hkysize)) then begin
      ker_out = ker_in[(hkxsize - dsx):(hkxsize + dsx), (hkysize - dsy):(hkysize + dsy)]
      hkxsize = dsx
      kxsize = (2L*hkxsize) + 1L
      hkysize = dsy
      kysize = (2L*hkysize) + 1L
    endif else ker_out = ker_in
  endelse

;If "ker_in" is a three-dimensional array
endif else if (ndim EQ 3L) then begin

  ;If the first and second dimensions of "ker_in" are both of size "1"
  if ((kxsize EQ 1L) AND (kysize EQ 1L)) then begin

    ;Determine the minimum kernel size along the z-axis and create the minimal size output convolution kernel
    dsz = abs(subs[0] - hkzsize) > abs(subs[nsubs - 1L] - hkzsize)
    if (dsz LT hkzsize) then begin
      ker_out = ker_in[0L, 0L, (hkzsize - dsz):(hkzsize + dsz)]
      hkzsize = dsz
      kzsize = (2L*hkzsize) + 1L
    endif else ker_out = ker_in

  ;If either the first or second dimensions of "ker_in" are of size greater than "1"
  endif else begin

    ;Convert the subscripts for the non-zero kernel values into pixel indices along the x-, y- and z-axes of the
    ;input kernel
    convert_3darr_subscripts_to_pixel_indices, subs, kxsize, kysize, xind, yind, zind, nind, stat, /NO_PAR_CHECK

    ;Determine the minimum and maximum values of the pixel indices for the non-zero kernel values along the x-, y-
    ;and z-axes of the input kernel, and use this to determine the minimum kernel size along the x-, y- and z-axes
    if (kxsize GT 1L) then begin
      xind_min = min(xind, MAX = xind_max)
      dsx = abs(xind_min - hkxsize) > abs(xind_max - hkxsize)
    endif else dsx = 0L
    if (kysize GT 1L) then begin
      yind_min = min(yind, MAX = yind_max)
      dsy = abs(yind_min - hkysize) > abs(yind_max - hkysize)
    endif else dsy = 0L
    zind_min = min(zind, MAX = zind_max)
    dsz = abs(zind_min - hkzsize) > abs(zind_max - hkzsize)
    if (dsy GT 0L) then dsz = dsz > 1L

    ;Create the minimal size output convolution kernel
    if ((dsx LT hkxsize) OR (dsy LT hkysize) OR (dsz LT hkzsize)) then begin
      ker_out = ker_in[(hkxsize - dsx):(hkxsize + dsx), (hkysize - dsy):(hkysize + dsy), (hkzsize - dsz):(hkzsize + dsz)]
      hkxsize = dsx
      kxsize = (2L*hkxsize) + 1L
      hkysize = dsy
      kysize = (2L*hkysize) + 1L
      hkzsize = dsz
      kzsize = (2L*hkzsize) + 1L
    endif else ker_out = ker_in
  endelse
endif

END
