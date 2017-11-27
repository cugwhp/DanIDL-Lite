PRO generate_geometric_sequence, a1, r, n, seq, status, INTEGER_SEQUENCE = integer_sequence, NO_PAR_CHECK = no_par_check

; Description: This module generates a geometric sequence of "n" elements with first element "a1" and a
;              ratio "r" between consecutive elements. The sequence is returned as the one-dimensional
;              vector "seq". Mathematically, the geometric sequence is defined as:
;
;              seq[i] = a1 * r^(i - 1)                for i = 1,2,...,n
;
;                By setting the keyword INTEGER_SEQUENCE, the module will convert the input parameters
;              "a1" and "r" into LONG type integers, and it will use them to generate the output
;              geometric sequence "seq" as a sequence of numbers of LONG type.
;
; Input Parameters:
;
;   a1 - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The first element of the geometric sequence.
;   r - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The ratio between consecutive elements of the sequence.
;   n - INTEGER/LONG - The number of elements in the geometric sequence. This parameter must be
;                      positive.
;
; Output Parameters:
;
;   seq - DOUBLE VECTOR - A one-dimensional vector of length "n" elements that contains the
;                         geometric sequence that has been generated.
;   status - INTEGER - If the module successfully generated the geometric sequence, then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of
;                      "0".
;
; Keywords:
;
;   If the keyword INTEGER_SEQUENCE is set (as "/INTEGER_SEQUENCE"), then the module will convert
;   the input parameters "a1" and "r" into LONG type integers, and it will use them to generate
;   the output geometric sequence "seq" as a sequence of numbers of LONG type.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform
;   parameter checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
seq = [0.0D]
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "a1" and "r" are numbers of the correct type
  if (test_bytintlonfltdbl_scalar(a1) NE 1) then return
  if (test_bytintlonfltdbl_scalar(r) NE 1) then return

  ;Check that "n" is a positive number of the correct type
  if (test_intlon_scalar(n) NE 1) then return
  if (n LT 1) then return
endif

;If the keyword INTEGER_SEQUENCE is set
if keyword_set(integer_sequence) then begin

  ;Generate the geometric sequence as a sequence of numbers of LONG type
  a1_use = long(a1)
  if (a1_use EQ 0L) then begin
    seq = lonarr(n)
  endif else begin
    r_use = long(r)
    if (r_use EQ 0L) then begin
      seq = lonarr(n)
      seq[0L] = a1_use
    endif else if (r_use EQ 1L) then begin
      seq = replicate(a1_use, n)
    endif else begin
      if (a1_use EQ 1L) then begin
        seq = r_use^lindgen(n)
      endif else seq = a1_use*(r_use^lindgen(n))
    endelse
  endelse

;If the keyword INTEGER_SEQUENCE is not set
endif else begin

  ;Generate the geometric sequence as a sequence of numbers of DOUBLE type
  a1_use = double(a1)
  if (a1_use EQ 0.0D) then begin
    seq = dblarr(n)
  endif else begin
    r_use = double(r)
    if (r_use EQ 0.0D) then begin
      seq = dblarr(n)
      seq[0L] = a1_use
    endif else if (r_use EQ 1.0D) then begin
      seq = replicate(a1_use, n)
    endif else begin
      if (a1_use EQ 1.0D) then begin
        seq = r_use^dindgen(n)
      endif else seq = a1_use*(r_use^dindgen(n))
    endelse
  endelse
endelse

;Set "status" to "1"
status = 1

END
