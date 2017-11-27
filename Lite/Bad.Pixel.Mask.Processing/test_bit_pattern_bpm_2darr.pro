FUNCTION test_bit_pattern_bpm_2darr, bpmdata, xsize, ysize

; Description: This function tests that the parameter "bpmdata" contains a two-dimensional
;              bit-pattern bad pixel mask of size "xsize" by "ysize" pixels. A bit-pattern
;              bad pixel mask stores a non-negative integer value at each pixel that
;              represents the pattern of bits that are set (or the equivalent binary number).
;              If no bits are set, then the integer value is "0", and this is generally
;              considered to be a good pixel. If at least one bit is set, then the integer
;              value is positive, and this is generally considered to be a bad pixel with
;              the "bad pixel" properties indicated by which bits are set.
;                Therefore, this function tests that the parameter "bpmdata" is a
;              two-dimensional array of size "xsize" by "ysize" pixels that is of BYTE,
;              INTEGER, or LONG type, and that it contains only non-negative pixel values.
;
; Input Parameters:
;
;   bpmdata - ANY - The parameter to be tested whether or not it satisfies the properties
;                   that a two-dimensional bit-pattern bad pixel mask should have.
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
;   that a two-dimensional bit-pattern bad pixel mask should have. Otherwise, the function
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

;If "bpmdata" does not have any negative pixel values and therefore satisfies the properties
;that a two-dimensional bit-pattern bad pixel mask should have, then return a value of "1".
;Otherwise, return a value of "0".
return, fix(array_equal(bpmdata GE 0B, 1B))

END
