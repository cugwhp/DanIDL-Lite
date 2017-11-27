FUNCTION grow_binary_bpm_3darr, bpmdata, grad, status, CUBE = cube, BAD_BEYOND_EDGE = bad_beyond_edge, NO_PAR_CHECK = no_par_check

; Description: This function processes a three-dimensional binary bad pixel mask "bpmdata",
;              where the term "binary" refers to the fact that the function only distinguishes
;              between the two states of "good" and "bad" pixels. In the bad pixel mask
;              "bpmdata", good pixels should be flagged with a value of "1", and bad pixels
;              may be flagged with any other value.
;                The function grows the bad pixels in the bad pixel mask "bpmdata" by a radius
;              "grad" (in pixel units). This means that any pixel in the output bad pixel mask
;              with a centre that is at a distance of less than or equal to "grad" pixels from
;              the centre of a bad pixel in the input bad pixel mask "bpmdata" will be flagged
;              as bad. The user also has the alternative option of growing bad pixels by the
;              growth distance "grad" pixels in each of the x, y and z coordinate directions
;              if so required.
;                By default, the function assumes that the pixels are good beyond the edges of
;              the input bad pixel mask. However, the user may wish to assume that the pixels
;              are bad beyond the edges of the input bad pixel mask for the purposes of the
;              bad pixel growth operation, and this functionality is provided by the function
;              through the use of the keyword BAD_BEYOND_EDGE.
;
; Input Parameters:
;
;   bpmdata - BYTE/INTEGER/LONG ARRAY - A three-dimensional bad pixel mask array which flags
;                                       good pixels with a value of "1" and bad pixels with
;                                       any other value.
;   grad - FLOAT/DOUBLE - The radius in pixels by which bad pixels in "bpmdata" are to be
;                         grown. This parameter must be non-negative.
;   status - ANY - A variable which will be used to contain the output status of the function
;                  on returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully grew the bad pixels in "bpmdata", then
;                      "status" is returned with a value of "1", otherwise it is returned
;                      with a value of "0".
;
; Return Value:
;
;   The function returns a three-dimensional bad pixel mask array of INTEGER type numbers of
;   the same size as "bpmdata" which flags good pixels with a value of "1" and bad pixels
;   with a value of "0". The return array is the result of growing the bad pixels in the
;   input bad pixel mask "bpmdata" by a radius of "grad" pixels.
;
; Keywords:
;
;   If the keyword CUBE is set (as "/CUBE"), then instead of growing bad pixels in the input
;   bad pixel mask by a growth radius, the bad pixels are grown by a distance of "grad" pixels
;   along each of the x, y and z coordinate directions.
;
;   If the keyword BAD_BEYOND_EDGE is set (as "/BAD_BEYOND_EDGE"), then the function assumes
;   that the pixels are bad beyond the edges of the input bad pixel mask for the purposes of
;   the bad pixel growth operation.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform
;   parameter checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "bpmdata" is a three-dimensional binary bad pixel mask
  if (test_binary_bpm_3darr(bpmdata, 0.0, 0.0, 0.0) NE 1) then return, 0

  ;Check that "grad" is a non-negative number of the correct type
  if (test_fltdbl_scalar(grad) NE 1) then return, 0
  if (grad LT 0.0) then return, 0
endif

;If "grad" is less than "1.0", then the output bad pixel mask will mask the same pixels as the
;input bad pixel mask
if (grad LT 1.0) then begin
  bpm_subs = where(bpmdata NE 1B, nbpm_subs)
  bpm_out = fix(bpmdata)
  if (nbpm_subs GT 0L) then bpm_out[bpm_subs] = 0
  status = 1
  return, bpm_out
endif

;Determine the convolution kernel required to grow the bad pixels in the input bad pixel mask
hksize = floor(grad)
ksize = (2L*hksize) + 1L
if keyword_set(cube) then begin
  kernel = replicate(1L, ksize, ksize, ksize)
endif else begin
  krad = 0.5D*ksize
  kernel = long(create_spherical_mask_3darr(ksize, ksize, ksize, krad, krad, krad, grad, stat, /NO_PAR_CHECK))
endelse

;Grow the bad pixels in the input bad pixel mask "bpmdata" by a radius of "grad" pixels and
;return the result
return, transform_binary_bpm_3darr_with_kernel(bpmdata, kernel, status, BAD_BEYOND_EDGE = bad_beyond_edge, /NO_PAR_CHECK)

END
