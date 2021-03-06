FUNCTION erode_bit_pattern_bpm_3darr, bpmdata, erad, status, CUBE = cube, BPM_BEYOND_EDGE = bpm_beyond_edge, NO_PAR_CHECK = no_par_check

; Description: This function processes a three-dimensional bit-pattern bad pixel mask "bpmdata",
;              which stores an integer value at each pixel that represents the pattern of bits
;              that are set (or the equivalent binary number). If no bits are set, then the
;              integer value is "0", and this is generally considered to be a good pixel. If at
;              least one bit is set, then the integer value will be positive, and this is
;              generally considered to be a bad pixel with the "bad pixel" properties indicated
;              by which bits are set.
;                For each pixel in the output bad pixel mask, the function sets only those bits
;              that are also set in all of the pixels in the input bad pixel mask "bpmdata" that
;              have a centre that is at a distance of less than or equal to "erad" pixels from
;              the centre of the current pixel in the output bad pixel mask. This is equivalent
;              to eroding the edges of each connected volume of pixels with the same bit set in
;              the input bad pixel mask "bpmdata" by a radius of "erad" (in pixel units). The
;              user also has the alternative option of eroding these volumes of connected pixels
;              with the same bit set in the input bad pixel mask "bpmdata" by the erosion
;              distance "erad" pixels in each of the x, y and z coordinate directions if so
;              required.
;                By default, the function assumes that the pixel values are "0" beyond the edges
;              of the input bad pixel mask. However, the user may wish to assume that the pixel
;              values beyond the edges of the input bad pixel mask are set to some other
;              non-negative integer value for the purposes of the bit-pattern erosion operation,
;              and this functionality is provided by the function through the use of the keyword
;              BPM_BEYOND_EDGE.
;
; Input Parameters:
;
;   bpmdata - BYTE/INTEGER/LONG ARRAY - A three-dimensional bad pixel mask array which stores an
;                                       integer value at each pixel that represents the pattern
;                                       of bits that are set (or the equivalent binary number).
;                                       If no bits are set, then the integer value is "0", and
;                                       this is generally considered to be a good pixel. If at
;                                       least one bit is set, then the integer value will be
;                                       positive, and this is generally considered to be a bad
;                                       pixel with the "bad pixel" properties indicated by which
;                                       bits are set. All elements in this array must be
;                                       non-negative.
;   erad - FLOAT/DOUBLE - The radius in pixels by which to erode the edges of each connected
;                         volume of pixels with the same bit set in the input bad pixel mask
;                         "bpmdata". This parameter must be non-negative.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully performed the erosion operation on the pixel
;                      values of the input bad pixel mask "bpmdata", then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a three-dimensional bit-pattern bad pixel mask array of LONG type
;   numbers of the same size as "bpmdata". The return array is the result of eroding the edges
;   of each connected volume of pixels with the same bit set in the input bad pixel mask "bpmdata"
;   by a radius of "erad" pixels.
;
; Keywords:
;
;   If the keyword CUBE is set (as "/CUBE"), then instead of eroding the edges of each connected
;   volume of pixels with the same bit set in the input bad pixel mask by an erosion radius, the
;   edges are eroded by a distance of "erad" pixels along each of the x, y and z coordinate
;   directions.
;
;   If the keyword BPM_BEYOND_EDGE is set to a non-negative BYTE/INTEGER/LONG value, then the
;   function assumes that the pixel values beyond the edges of the input bad pixel mask are set
;   to the value of the keyword BPM_BEYOND_EDGE for the purposes of the bit-pattern erosion
;   operation.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform
;   parameter checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "bpmdata" is a three-dimensional bit-pattern bad pixel mask
  if (test_bit_pattern_bpm_3darr(bpmdata, 0.0, 0.0, 0.0) NE 1) then return, 0L

  ;Check that "erad" is a non-negative number of the correct type
  if (test_fltdbl_scalar(erad) NE 1) then return, 0L
  if (erad LT 0.0) then return, 0L
endif

;If "erad" is less than "1.0", then the output bad pixel mask will be the same as the input bad
;pixel mask
if (erad LT 1.0) then begin
  status = 1
  return, long(bpmdata)
endif

;Determine the convolution kernel required to erode the edges of each connected volume of pixels
;with the same bit set in the input bad pixel mask
hksize = floor(erad)
ksize = (2L*hksize) + 1L
if keyword_set(cube) then begin
  kernel = replicate(1L, ksize, ksize, ksize)
endif else begin
  krad = 0.5D*ksize
  kernel = long(create_spherical_mask_3darr(ksize, ksize, ksize, krad, krad, krad, erad, stat, /NO_PAR_CHECK))
endelse

;Erode the edges of each connected volume of pixels with the same bit set in the input bad pixel
;mask "bpmdata" by a radius of "erad" pixels and return the result
return, transform_bit_pattern_bpm_3darr_with_kernel(bpmdata, kernel, status, /BITWISE_AND, BPM_BEYOND_EDGE = bpm_beyond_edge, /NO_PAR_CHECK)

END
