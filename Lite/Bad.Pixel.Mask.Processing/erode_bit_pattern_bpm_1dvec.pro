FUNCTION erode_bit_pattern_bpm_1dvec, bpmdata, erad, status, BPM_BEYOND_EDGE = bpm_beyond_edge, NO_PAR_CHECK = no_par_check

; Description: This function processes a one-dimensional bit-pattern bad pixel mask "bpmdata",
;              which stores an integer value at each pixel that represents the pattern of
;              bits that are set (or the equivalent binary number). If no bits are set, then
;              the integer value is "0", and this is generally considered to be a good pixel.
;              If at least one bit is set, then the integer value will be positive, and this
;              is generally considered to be a bad pixel with the "bad pixel" properties
;              indicated by which bits are set.
;                For each pixel in the output bad pixel mask, the function sets only those
;              bits that are also set in all of the pixels in the input bad pixel mask
;              "bpmdata" that have a centre that is at a distance of less than or equal to
;              "erad" pixels from the centre of the current pixel in the output bad pixel
;              mask. This is equivalent to eroding the ends of each connected length of
;              pixels with the same bit set in the input bad pixel mask "bpmdata" by a
;              distance of "erad" (in pixel units).
;                By default, the function assumes that the pixel values are "0" beyond the
;              ends of the input bad pixel mask. However, the user may wish to assume that
;              the pixel values beyond the ends of the input bad pixel mask are set to
;              some other non-negative integer value for the purposes of the bit-pattern
;              erosion operation, and this functionality is provided by the function through
;              the use of the keyword BPM_BEYOND_EDGE.
;
; Input Parameters:
;
;   bpmdata - BYTE/INTEGER/LONG VECTOR - A one-dimensional bad pixel mask vector which stores
;                                        an integer value at each pixel that represents the
;                                        pattern of bits that are set (or the equivalent
;                                        binary number). If no bits are set, then the integer
;                                        value is "0", and this is generally considered to be
;                                        a good pixel. If at least one bit is set, then the
;                                        integer value will be positive, and this is generally
;                                        considered to be a bad pixel with the "bad pixel"
;                                        properties indicated by which bits are set. All
;                                        elements in this vector must be non-negative.
;   erad - FLOAT/DOUBLE - The distance in pixels by which to erode the ends of each connected
;                         length of pixels with the same bit set in the input bad pixel mask
;                         "bpmdata". This parameter must be non-negative.
;   status - ANY - A variable which will be used to contain the output status of the function
;                  on returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully performed the erosion operation on the
;                      pixel values of the input bad pixel mask "bpmdata", then "status" is
;                      returned with a value of "1", otherwise it is returned with a value
;                      of "0".
;
; Return Value:
;
;   The function returns a one-dimensional bit-pattern bad pixel mask vector of LONG type
;   numbers of the same length as "bpmdata". The return vector is the result of eroding the
;   ends of each connected length of pixels with the same bit set in the input bad pixel
;   mask "bpmdata" by a distance of "erad" pixels.
;
; Keywords:
;
;   If the keyword BPM_BEYOND_EDGE is set to a non-negative BYTE/INTEGER/LONG value, then
;   the function assumes that the pixel values beyond the ends of the input bad pixel mask
;   are set to the value of the keyword BPM_BEYOND_EDGE for the purposes of the bit-pattern
;   erosion operation.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not
;   perform parameter checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "bpmdata" is a one-dimensional bit-pattern bad pixel mask
  if (test_bit_pattern_bpm_1dvec(bpmdata, 0.0) NE 1) then return, 0L

  ;Check that "erad" is a non-negative number of the correct type
  if (test_fltdbl_scalar(erad) NE 1) then return, 0L
  if (erad LT 0.0) then return, 0L
endif

;If "erad" is less than "1.0", then the output bad pixel mask will be the same as the input
;bad pixel mask
if (erad LT 1.0) then begin
  status = 1
  return, long(bpmdata)
endif

;Erode the ends of each connected length of pixels with the same bit set in the input bad
;pixel mask "bpmdata" by a distance of "erad" pixels and return the result
return, transform_bit_pattern_bpm_1dvec_with_kernel(bpmdata, replicate(1L, (2L*floor(erad)) + 1L), status, /BITWISE_AND, BPM_BEYOND_EDGE = bpm_beyond_edge, /NO_PAR_CHECK)

END
