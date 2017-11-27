FUNCTION transform_bit_pattern_bpm_2darr_with_kernel, bpmdata, kernel, status, BITWISE_AND = bitwise_and, BPM_BEYOND_EDGE = bpm_beyond_edge, NO_PAR_CHECK = no_par_check

; Description: This function processes a two-dimensional bit-pattern bad pixel mask "bpmdata", which stores an
;              integer value at each pixel that represents the pattern of bits that are set (or the equivalent
;              binary number). If no bits are set, then the integer value is "0", and this is generally
;              considered to be a good pixel. If at least one bit is set, then the integer value is positive,
;              and this is generally considered to be a bad pixel with the "bad pixel" properties indicated by
;              which bits are set.
;                The function performs an operation similar to that of convolution, but using the bit-wise OR
;              operator instead of the summation operator, to transform the pixel values of the input bad
;              pixel mask "bpmdata" into the pixel values of the output bad pixel mask. The "convolution"
;              operation used by this function is defined by:
;
;                          [                    ]
;              B'_ij = OR  [ K_uv * B_(i+u,j+v) ]           for all non-zero K_uv
;                      u,v [                    ]
;
;              where B_ij and B'_ij represent the pixel values of the input and output bad pixel masks,
;              respectively, for the pixel in the ith column and jth row. The operator OR represents the
;              bit-wise OR operator, and it is performed over the set of kernel pixels with non-zero values
;              K_uv. If all of the kernel pixel values are zero, then all of the pixels in the output bad
;              pixel mask are set to zero. Note that the kernel pixel indices u and v are defined such that
;              the central kernel pixel has (u,v) pixel indices of (0,0).
;                This function is intended to be used for "growing" the bits that are set in the pixels of
;              the input bad pixel mask by an arbitrary shape that is defined by the input kernel "kernel".
;              For this usage, the user should design the input kernel to take the value "1" for the relative
;              positions where bits are to be propagated from, and to take the value "0" for the relative
;              positions from where bits are to be ignored. Having said this, the user is free to provide
;              any integer-valued input kernel, which maintains the flexibility of this function. Note that
;              since the kernel is centred over each pixel in the bad pixel mask during the "convolution",
;              the size of the kernel in each of the x and y coordinate directions must be an odd number.
;              Kernels not satisfying this criterion will be rejected.
;                The function provides the option of using the bit-wise AND operator in place of the bit-wise
;              OR operator in the "convolution" operation defined above. This may be achieved by setting the
;              keyword BITWISE_AND. Use of this option allows the user to "erode" the edges of connected
;              groups of pixels with the same bit set in the input bad pixel mask.
;                In order to be able to perform the "convolution" operation at the edges of the input bad
;              pixel mask, the function assumes that the pixel values are "0" beyond the edges of the input
;              bad pixel mask. However, the user may wish to assume that the pixel values beyond the edges
;              of the input bad pixel mask are set to some other non-negative integer value for the purposes
;              of the "convolution" operation, and this functionality is provided by the function through
;              the use of the keyword BPM_BEYOND_EDGE.
;
; Input Parameters:
;
;   bpmdata - BYTE/INTEGER/LONG ARRAY - A two-dimensional bad pixel mask array which stores an integer value
;                                       at each pixel that represents the pattern of bits that are set (or
;                                       the equivalent binary number). If no bits are set, then the integer
;                                       value is "0", and this is generally considered to be a good pixel.
;                                       If at least one bit is set, then the integer value is positive, and
;                                       this is generally considered to be a bad pixel with the "bad pixel"
;                                       properties indicated by which bits are set. All elements in this
;                                       array must be non-negative.
;   kernel - BYTE/INTEGER/LONG VECTOR/ARRAY - A one- or two-dimensional kernel array which is to be used to
;                                             transform the bits that are set in the pixels of the input bad
;                                             pixel mask using the "convolution" operation defined above.
;                                             The size of each dimension of the kernel array must be an odd
;                                             number since the kernel will be centred over each pixel in the
;                                             bad pixel mask during the "convolution". If this is not the
;                                             case, then the function will fail. Usually kernels for
;                                             transforming the bits that are set in the pixels of the input
;                                             bad pixel mask consist solely of the values "1" and "0".
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully transformed the bits that are set in each pixel of the
;                      input bad pixel mask "bpmdata", then "status" is returned with a value of "1",
;                      otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a two-dimensional bit-pattern bad pixel mask array of LONG type numbers of the
;   same size as "bpmdata". The return array is the result of transforming each bit that is set in each
;   pixel of the input bad pixel mask "bpmdata" using the "convolution" operation defined above.
;
; Keywords:
;
;   If the keyword BITWISE_AND is set (as "/BITWISE_AND"), then the function will employ the bit-wise AND
;   operator in place of the bit-wise OR operator in the "convolution" operation defined above.
;
;   If the keyword BPM_BEYOND_EDGE is set to a non-negative BYTE/INTEGER/LONG value, then the function
;   assumes that the pixel values beyond the edges of the input bad pixel mask are set to the value of the
;   keyword BPM_BEYOND_EDGE for the purposes of the "convolution" operation.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "bpmdata" is a two-dimensional bit-pattern bad pixel mask
  if (test_bit_pattern_bpm_2darr(bpmdata, 0.0, 0.0) NE 1) then return, 0L

  ;Check that "kernel" is a one-dimensional vector, or a two-dimensional array, of the correct number type
  if (test_bytintlon(kernel) NE 1) then return, 0L
  ndim = kernel.ndim
  if ((ndim NE 1L) AND (ndim NE 2L)) then return, 0L
endif
result = bpmdata.dim
bpmxsize = result[0]
bpmysize = result[1]

;Check that the size of each dimension of "kernel" is odd while enforcing a minimal size kernel for efficiency
create_minimal_size_kernel, long(kernel), kernel_use, hkxsize, kxsize, hkysize, kysize, hkzsize, kzsize, kstat
if (kstat EQ 0) then return, 0L

;If the (minimal size) input kernel has a single element
if ((kxsize EQ 1L) AND (kysize EQ 1L)) then begin

  ;Create the output bad pixel mask array
  kval = kernel_use[0]
  if (kval EQ 0L) then begin
    bpm_out = lonarr(bpmxsize, bpmysize)
  endif else if (kval EQ 1L) then begin
    bpm_out = long(bpmdata)
  endif else bpm_out = kval*long(bpmdata)

  ;Set "status" to "1"
  status = 1

  ;Return the transformed bad pixel mask
  return, bpm_out
endif

;Extract the pixel value to be used for the pixels beyond the edges of the input bad pixel mask from the
;keyword BPM_BEYOND_EDGE, adopting the default value of "0" if the keyword is not defined correctly
bpm_beyond_edge_use = 0L
if (test_bytintlon_scalar(bpm_beyond_edge) EQ 1) then begin
  if (bpm_beyond_edge GT 0B) then bpm_beyond_edge_use = long(bpm_beyond_edge)
endif

;Create a padded version of the input bad pixel mask
padx = kxsize - 1L
pady = kysize - 1L
bpmxsize_padx = bpmxsize + padx
bpmysize_pady = bpmysize + pady
bpmxsize_padx_m1 = bpmxsize_padx - 1L
bpmysize_pady_m1 = bpmysize_pady - 1L
bpmdata_padded = replicate(bpm_beyond_edge_use, bpmxsize_padx, bpmysize_pady)
bpmdata_padded[hkxsize,hkysize] = long(bpmdata)

;Set up a double-padded output bad pixel mask array
bpm_out = lonarr(bpmxsize_padx + padx, bpmysize_pady + pady)

;Rotate the kernel by a half-turn around the centre kernel pixel, which is necessary for the "convolution"
;method implemented in this function
kernel_use = rotate(kernel_use, 2)

;Determine the subscripts and values of the non-zero pixels in the input kernel
ksubs = where(kernel_use NE 0L, nksubs)
kvals = kernel_use[ksubs]

;Determine the kernel pixel indices along the kernel u- and v-axes for the non-zero kernel pixels
convert_2darr_subscripts_to_pixel_indices, ksubs, kxsize, kxind, kyind, nksubs, stat, /NO_PAR_CHECK

;For the first non-zero pixel in the input kernel, perform the scaling of the padded input bad pixel mask
;and insert the result into the appropriate place in the double-padded output bad pixel mask array
ckval = kvals[0]
if (ckval EQ 1L) then begin
  bpm_out[kxind[0],kyind[0]] = bpmdata_padded
endif else bpm_out[kxind[0],kyind[0]] = ckval*bpmdata_padded

;If there are multiple non-zero pixels in the input kernel
if (nksubs GT 1L) then begin

  ;For each remaining non-zero pixel in the input kernel
  for i = 1L,(nksubs - 1L) do begin

    ;Extract the current non-zero kernel pixel value
    ckval = kvals[i]

    ;Extract the kernel pixel indices along the kernel u- and v-axes for the current non-zero kernel pixel
    ckxind = kxind[i]
    ckyind = kyind[i]

    ;Perform the scaling of the padded input bad pixel mask for the current kernel pixel and then perform
    ;the bit-wise OR combination of the result with the double-padded output bad pixel mask array in the
    ;appropriate place. Alternatively use bit-wise AND combination if the keyword BITWISE_AND is set.
    if keyword_set(bitwise_and) then begin
      if (ckval EQ 1L) then begin
        bpm_out[ckxind,ckyind] = bpm_out[ckxind:(ckxind + bpmxsize_padx_m1),ckyind:(ckyind + bpmysize_pady_m1)] AND bpmdata_padded
      endif else bpm_out[ckxind,ckyind] = bpm_out[ckxind:(ckxind + bpmxsize_padx_m1),ckyind:(ckyind + bpmysize_pady_m1)] AND (ckval*bpmdata_padded)
    endif else begin
      if (ckval EQ 1L) then begin
        bpm_out[ckxind,ckyind] = bpm_out[ckxind:(ckxind + bpmxsize_padx_m1),ckyind:(ckyind + bpmysize_pady_m1)] OR bpmdata_padded
      endif else bpm_out[ckxind,ckyind] = bpm_out[ckxind:(ckxind + bpmxsize_padx_m1),ckyind:(ckyind + bpmysize_pady_m1)] OR (ckval*bpmdata_padded)
    endelse
  endfor
endif

;Set "status" to "1"
status = 1

;Trim the double-padding and return the transformed bad pixel mask
return, bpm_out[padx:bpmxsize_padx_m1, pady:bpmysize_pady_m1]

END
