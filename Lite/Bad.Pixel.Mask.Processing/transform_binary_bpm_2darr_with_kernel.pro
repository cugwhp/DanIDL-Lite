FUNCTION transform_binary_bpm_2darr_with_kernel, bpmdata, kernel, status, GROW_GOOD_PIX = grow_good_pix, BAD_BEYOND_EDGE = bad_beyond_edge, NO_PAR_CHECK = no_par_check

; Description: This function processes a two-dimensional binary bad pixel mask "bpmdata", where the term
;              "binary" refers to the fact that the function only distinguishes between the two states of
;              "good" and "bad" pixels. In the bad pixel mask "bpmdata", good pixels should be flagged
;              with a value of "1", and bad pixels may be flagged with any other value.
;                The function converts the input bad pixel mask into an internal format that flags good
;              pixels with a value of "0" and bad pixels with a value of "1". The function then convolves
;              the internal-format bad pixel mask using the input kernel "kernel". Pixel values of "0"
;              in the resulting array are set to good pixels with a value of "1" in the output bad pixel
;              mask, and non-zero pixel values in the resulting array are set to bad pixels with a value
;              of "0" in the output bad pixel mask.
;                This function is intended to be used for "growing" the bad pixels in the input bad pixel
;              mask by an arbitrary shape that is defined by the input kernel "kernel". For this usage,
;              the user should design the input kernel to take the value "1" for the relative positions
;              where bad pixels are to be propagated from, and to take the value "0" for the relative
;              positions from where bad pixels are to be ignored. Having said this, the user is free to
;              provide any integer-valued input kernel, which maintains the flexibility of this function.
;              Note that since the kernel is centred over each pixel in the bad pixel mask during the
;              convolution, the size of the kernel in each of the x and y coordinate directions must be
;              an odd number. Kernels not satisfying this criterion will be rejected.
;                The function also provides an alternative method for transforming the input bad pixel
;              mask. By setting the keyword GROW_GOOD_PIX, the function will convert the input bad pixel
;              mask into an internal format that flags good pixels with a value of "1" and bad pixels
;              with a value of "0". The function then convolves the internal-format bad pixel mask using
;              the input kernel "kernel". Pixel values of "0" in the resulting array are set to bad pixels
;              with a value of "0" in the output bad pixel mask, and non-zero pixel values in the resulting
;              array are set to good pixels with a value of "1" in the output bad pixel mask. This option
;              is intended to be used for "growing" the good pixels in the input bad pixel mask by an
;              arbitrary shape that is defined by the input kernel "kernel".
;                In order to be able to perform the convolution operation at the edges of the input bad
;              pixel mask, the function assumes that the pixels are good beyond the edges of the input bad
;              pixel mask. However, the user may wish to assume that the pixels are bad beyond the edges
;              of the input bad pixel mask for the purposes of the convolution operation, and this
;              functionality is provided by the function through the use of the keyword BAD_BEYOND_EDGE.
;
; Input Parameters:
;
;   bpmdata - BYTE/INTEGER/LONG ARRAY - A two-dimensional bad pixel mask array which flags good pixels
;                                       with a value of "1" and bad pixels with any other value.
;   kernel - BYTE/INTEGER/LONG VECTOR/ARRAY - A one- or two-dimensional kernel array which is to be used
;                                             to transform the bad pixels in the bad pixel mask using the
;                                             convolution operation defined above. The size of each
;                                             dimension of the kernel array must be an odd number since
;                                             the kernel will be centred over each pixel in the bad pixel
;                                             mask during the convolution. If this is not the case, then
;                                             the function will fail. Usually kernels for transforming
;                                             the bad pixels in the input bad pixel mask consist solely
;                                             of the values "1" and "0".
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully transformed the bad pixels in "bpmdata", then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a two-dimensional bad pixel mask array of INTEGER type numbers of the same size
;   as "bpmdata" which flags good pixels with a value of "1" and bad pixels with a value of "0". The
;   return array is the result of having transformed the input bad pixel mask using the convolution
;   operation defined above.
;
; Keywords:
;
;   If the keyword GROW_GOOD_PIX is set (as "/GROW_GOOD_PIX"), then the function will employ the alternative
;   method for transforming the input bad pixel mask as described above, which is equivalent to "growing"
;   the good pixels (instead of "growing" the bad pixels).
;
;   If the keyword BAD_BEYOND_EDGE is set (as "/BAD_BEYOND_EDGE"), then the function assumes that the pixels
;   are bad beyond the edges of the input bad pixel mask for the purposes of the convolution operation.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;If parameter checking is not required
if keyword_set(no_par_check) then begin

  ;Determine the size of "bpmdata"
  result = bpmdata.dim
  bpmxsize = result[0]
  bpmysize = result[1]

;If parameter checking is required
endif else begin

  ;Check that "bpmdata" is a two-dimensional binary bad pixel mask
  test_bytintlon_2darr, bpmdata, bpmstat, bpmxsize, bpmysize, bpmtype
  if (bpmstat EQ 0) then return, 0

  ;Check that "kernel" is a one-dimensional vector, or a two-dimensional array, of the correct number type
  if (test_bytintlon(kernel) NE 1) then return, 0
  ndim = kernel.ndim
  if ((ndim NE 1L) AND (ndim NE 2L)) then return, 0
endelse

;Check that the size of each dimension of "kernel" is odd while enforcing a minimal size kernel for efficiency
create_minimal_size_kernel, long(kernel), kernel_use, hkxsize, kxsize, hkysize, kysize, hkzsize, kzsize, kstat
if (kstat EQ 0) then return, 0

;If the (minimal size) input kernel has a single element
if ((kxsize EQ 1L) AND (kysize EQ 1L)) then begin

  ;If the (minimal size) input kernel has a single element with a value of zero
  if (kernel_use[0] EQ 0L) then begin

    ;Create the output bad pixel mask array
    if keyword_set(grow_good_pix) then begin
      bpm_out = intarr(bpmxsize, bpmysize)
    endif else bpm_out = replicate(1, bpmxsize, bpmysize)

  ;If the (minimal size) input kernel has a single element with a non-zero value
  endif else begin

    ;Create the output bad pixel mask array
    bpm_out = fix(bpmdata)
    bpm_subs = where(bpmdata NE 1B, nbpm_subs)
    if (nbpm_subs GT 0L) then bpm_out[bpm_subs] = 0
  endelse

  ;Set "status" to "1"
  status = 1

  ;Return the transformed bad pixel mask
  return, bpm_out
endif

;Create an internal-format version of the input bad pixel mask array which flags good pixels with a value of
;"1" and bad pixels with a value of "0"
bpm_out = long(bpmdata)
bpm_subs = where(bpmdata NE 1B, nbpm_subs)
if (nbpm_subs GT 0L) then bpm_out[bpm_subs] = 0L
undefine_variables, bpm_subs

;Create a padded version of the internal-format bad pixel mask such that the pixel values for the padding
;pixels are set to "0" or "1" depending on whether the keyword BAD_BEYOND_EDGE is set or not set,
;respectively
bpmxsize_m1 = bpmxsize - 1L
bpmysize_m1 = bpmysize - 1L
if keyword_set(bad_beyond_edge) then begin
  bpmdata_padded = lonarr(bpmxsize_m1 + kxsize, bpmysize_m1 + kysize)
endif else bpmdata_padded = replicate(1L, bpmxsize_m1 + kxsize, bpmysize_m1 + kysize)
bpmdata_padded[hkxsize,hkysize] = bpm_out

;Transform the bad pixels in the input bad pixel mask
if keyword_set(grow_good_pix) then begin
  bpm_out = fix(convol(bpmdata_padded, kernel_use, /CENTER) NE 0L)
endif else bpm_out = fix(convol(1L - bpmdata_padded, kernel_use, /CENTER) EQ 0L)

;Set "status" to "1"
status = 1

;Trim the padding and return the transformed bad pixel mask
return, bpm_out[hkxsize:(bpmxsize_m1 + hkxsize), hkysize:(bpmysize_m1 + hkysize)]

END
