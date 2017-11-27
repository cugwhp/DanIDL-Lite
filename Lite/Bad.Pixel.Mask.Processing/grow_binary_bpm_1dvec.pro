FUNCTION grow_binary_bpm_1dvec, bpmdata, grad, status, BAD_BEYOND_EDGE = bad_beyond_edge, NO_PAR_CHECK = no_par_check

; Description: This function processes a one-dimensional binary bad pixel mask "bpmdata",
;              where the term "binary" refers to the fact that the function only
;              distinguishes between the two states of "good" and "bad" pixels. In the
;              bad pixel mask "bpmdata", good pixels should be flagged with a value of
;              "1", and bad pixels may be flagged with any other value.
;                The function grows the bad pixels in the bad pixel mask "bpmdata" by a
;              distance "grad" (in pixel units). This means that any pixel in the output
;              bad pixel mask with a centre that is at a distance of less than or equal
;              to "grad" pixels from the centre of a bad pixel in the input bad pixel
;              mask "bpmdata" will be flagged as bad.
;                By default, the function assumes that the pixels are good beyond the
;              ends of the input bad pixel mask. However, the user may wish to assume
;              that the pixels are bad beyond the ends of the input bad pixel mask for
;              the purposes of the bad pixel growth operation, and this functionality is
;              provided by the function through the use of the keyword BAD_BEYOND_EDGE.
;
; Input Parameters:
;
;   bpmdata - BYTE/INTEGER/LONG VECTOR - A one-dimensional bad pixel mask vector which
;                                        flags good pixels with a value of "1" and bad
;                                        pixels with any other value.
;   grad - FLOAT/DOUBLE - The distance in pixels by which bad pixels in "bpmdata" are to
;                         be grown. This parameter must be non-negative.
;   status - ANY - A variable which will be used to contain the output status of the
;                  function on returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully grew the bad pixels in "bpmdata", then
;                      "status" is returned with a value of "1", otherwise it is returned
;                      with a value of "0".
;
; Return Value:
;
;   The function returns a one-dimensional bad pixel mask vector of INTEGER type numbers
;   of the same length as "bpmdata" which flags good pixels with a value of "1" and bad
;   pixels with a value of "0". The return vector is the result of growing the bad pixels
;   in the input bad pixel mask "bpmdata" by a distance of "grad" pixels.
;
; Keywords:
;
;   If the keyword BAD_BEYOND_EDGE is set (as "/BAD_BEYOND_EDGE"), then the function
;   assumes that the pixels are bad beyond the ends of the input bad pixel mask for the
;   purposes of the bad pixel growth operation.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not
;   perform parameter checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "bpmdata" is a one-dimensional binary bad pixel mask
  if (test_binary_bpm_1dvec(bpmdata, 0.0) NE 1) then return, 0

  ;Check that "grad" is a non-negative number of the correct type
  if (test_fltdbl_scalar(grad) NE 1) then return, 0
  if (grad LT 0.0) then return, 0
endif

;If "grad" is less than "1.0", then the output bad pixel mask will mask the same pixels
;as the input bad pixel mask
if (grad LT 1.0) then begin
  bpm_subs = where(bpmdata NE 1B, nbpm_subs)
  bpm_out = fix(bpmdata)
  if (nbpm_subs GT 0L) then bpm_out[bpm_subs] = 0
  status = 1
  return, bpm_out
endif

;Grow the bad pixels in the input bad pixel mask "bpmdata" by a distance of "grad" pixels
;and return the result
return, transform_binary_bpm_1dvec_with_kernel(bpmdata, replicate(1L, (2L*floor(grad)) + 1L), status, BAD_BEYOND_EDGE = bad_beyond_edge, /NO_PAR_CHECK)

END
