PRO generate_arithmetic_sequence, a1, d, n, seq, status, INTEGER_SEQUENCE = integer_sequence, NO_PAR_CHECK = no_par_check

; Description: This module generates an arithmetic sequence of "n" elements with first element "a1" and a
;              difference "d" between consecutive elements. The sequence is returned as the one-dimensional
;              vector "seq". Mathematically, the arithmetic sequence is defined as:
;
;              seq[i] = a1 + (i - 1)*d                  for i = 1,2,...,n
;
;                By setting the keyword INTEGER_SEQUENCE, the module will convert the input parameters "a1"
;              and "d" into LONG type integers, and it will use them to generate the output arithmetic
;              sequence "seq" as a sequence of numbers of LONG type.
;
; Input Parameters:
;
;   a1 - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The first element of the arithmetic sequence.
;   d - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The difference between consecutive elements of the sequence.
;   n - INTEGER/LONG - The number of elements in the arithmetic sequence. This parameter must be positive.
;
; Output Parameters:
;
;   seq - DOUBLE VECTOR - A one-dimensional vector of length "n" elements that contains the arithmetic
;                         sequence that has been generated.
;   status - INTEGER - If the module successfully generated the arithmetic sequence, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword INTEGER_SEQUENCE is set (as "/INTEGER_SEQUENCE"), then the module will convert the
;   input parameters "a1" and "d" into LONG type integers, and it will use them to generate the output
;   arithmetic sequence "seq" as a sequence of numbers of LONG type.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
seq = [0.0D]
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "a1" and "d" are numbers of the correct type
  if (test_bytintlonfltdbl_scalar(a1) NE 1) then return
  if (test_bytintlonfltdbl_scalar(d) NE 1) then return

  ;Check that "n" is a positive number of the correct type
  if (test_intlon_scalar(n) NE 1) then return
  if (n LT 1) then return
endif

;If the keyword INTEGER_SEQUENCE is set
if keyword_set(integer_sequence) then begin

  ;Generate the arithmetic sequence as a sequence of numbers of LONG type
  a1_use = long(a1)
  d_use = long(d)
  if (a1_use EQ 0L) then begin
    if (d_use EQ 0L) then begin
      seq = lonarr(n)
    endif else if (d_use EQ 1L) then begin
      seq = lindgen(n)
    endif else if (d_use EQ -1L) then begin
      seq = -lindgen(n)
    endif else seq = lindgen(n)*d_use
  endif else begin
    if (d_use EQ 0L) then begin
      seq = replicate(a1_use, n)
    endif else if (d_use EQ 1L) then begin
      seq = a1_use + lindgen(n)
    endif else if (d_use EQ -1L) then begin
      seq = a1_use - lindgen(n)
    endif else seq = a1_use + (lindgen(n)*d_use)
  endelse

;If the keyword INTEGER_SEQUENCE is not set
endif else begin

  ;Generate the arithmetic sequence as a sequence of numbers of DOUBLE type
  a1_use = double(a1)
  d_use = double(d)
  if (a1_use EQ 0.0D) then begin
    if (d_use EQ 0.0D) then begin
      seq = dblarr(n)
    endif else if (d_use EQ 1.0D) then begin
      seq = dindgen(n)
    endif else if (d_use EQ -1.0D) then begin
      seq = -dindgen(n)
    endif else seq = dindgen(n)*d_use
  endif else begin
    if (d_use EQ 0.0D) then begin
      seq = replicate(a1_use, n)
    endif else if (d_use EQ 1.0D) then begin
      seq = a1_use + dindgen(n)
    endif else if (d_use EQ -1.0D) then begin
      seq = a1_use - dindgen(n)
    endif else seq = a1_use + (dindgen(n)*d_use)
  endelse
endelse

;Set "status" to "1"
status = 1

END
