FUNCTION test_binary_bpm_2darr, bpmdata, xsize, ysize

; Description: This function tests that the parameter "bpmdata" contains a two-dimensional
;              binary bad pixel mask of size "xsize" by "ysize" pixels. The term "binary"
;              refers to the fact that such a bad pixel mask only contains information at
;              each pixel as to whether the pixel is good or bad (although this is not
;              tested by the module).
;                Therefore, this function tests that the parameter "bpmdata" is a
;              two-dimensional array of size "xsize" by "ysize" pixels that is of BYTE,
;              INTEGER, or LONG type.
;
; Input Parameters:
;
;   bpmdata - ANY - The parameter to be tested whether or not it satisfies the properties
;                   that a two-dimensional binary bad pixel mask should have.
;   xsize - INTEGER/LONG - The size of the input parameter "bpmdata" along the x-axis
;                          should be equal to the value of "xsize". If this parameter is
;                          not of the correct number type, or if it is zero or negative,
;                          then the input parameter "bpmdata" is allowed to be of any size
;                          along the x-axis.
;   ysize - INTEGER/LONG - The size of the input parameter "bpmdata" along the y-axis
;                          should be equal to the value of "ysize". If this parameter is
;                          not of the correct number type, or if it is zero or negative,
;                          then the input parameter "bpmdata" is allowed to be of any size
;                          along the y-axis.
;
; Return Value:
;
;   The function returns an INTEGER value set to "1" if "bpmdata" satsifies the properties
;   that a two-dimensional binary bad pixel mask should have. Otherwise, the function
;   returns an INTEGER value set to "0".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Check that "bpmdata" is a two-dimensional array that contains numbers of the type BYTE,
;INTEGER, or LONG
test_bytintlon_2darr, bpmdata, bpmstat, bpmxsize, bpmysize, bpmtype
if (bpmstat EQ 0) then return, 0

;If required, check that "bpmdata" is of size "xsize" along the x-axis
if (test_intlon_scalar(xsize) EQ 1) then begin
  if (xsize GT 0) then begin
    if (bpmxsize NE xsize) then return, 0
  endif
endif

;If required, check that "bpmdata" is of size "ysize" along the y-axis
if (test_intlon_scalar(ysize) EQ 1) then begin
  if (ysize GT 0) then begin
    if (bpmysize NE ysize) then return, 0
  endif
endif

;If "bpmdata" satisfies the properties that a two-dimensional binary bad pixel mask should
;have, then return a value of "1"
return, 1

END
