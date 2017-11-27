FUNCTION test_binary_bpm_1dvec, bpmdata, xsize

; Description: This function tests that the parameter "bpmdata" contains a one-dimensional
;              binary bad pixel mask of length "xsize" pixels. The term "binary" refers to
;              the fact that such a bad pixel mask only contains information at each pixel
;              as to whether the pixel is good or bad (although this is not tested by the
;              module).
;                Therefore, this function tests that the parameter "bpmdata" is a
;              one-dimensional vector of length "xsize" pixels that is of BYTE, INTEGER,
;              or LONG type.
;
; Input Parameters:
;
;   bpmdata - ANY - The parameter to be tested whether or not it satisfies the properties
;                   that a one-dimensional binary bad pixel mask should have.
;   xsize - INTEGER/LONG - The length of the input parameter "bpmdata" should be equal to
;                          the value of "xsize". If this parameter is not of the correct
;                          number type, or if it is zero or negative, then the input
;                          parameter "bpmdata" is allowed to be of any length.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "bpmdata" satsifies the properties
;   that a one-dimensional binary bad pixel mask should have. Otherwise, the function
;   returns an INTEGER value set to "0".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Check that "bpmdata" is a one-dimensional vector that contains numbers of the type BYTE,
;INTEGER, or LONG
test_bytintlon_1dvec, bpmdata, bpmstat, bpmxsize, bpmtype
if (bpmstat EQ 0) then return, 0

;If required, check that "bpmdata" is of length "xsize" pixels
if (test_intlon_scalar(xsize) EQ 1) then begin
  if (xsize GT 0) then begin
    if (bpmxsize NE xsize) then return, 0
  endif
endif

;If "bpmdata" satisfies the properties that a one-dimensional binary bad pixel mask should
;have, then return a value of "1"
return, 1

END
