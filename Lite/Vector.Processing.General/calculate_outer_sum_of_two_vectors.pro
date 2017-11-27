FUNCTION calculate_outer_sum_of_two_vectors, vec1, vec2, status, INTEGER_OUTPUT = integer_output, NO_PAR_CHECK = no_par_check

; Description: This function calculates the outer sum of two input vectors "vec1" and "vec2" not necessarily of
;              the same length. The outer sum of two vectors V1 and V2, of length M and N elements respectively,
;              is the MxN matrix A defined by:
;
;              A_ij = V1_i + V2_j          1 <= i <= M, 1 <= j <= N
;
;              where the (i,j) indices refer to the ith column and jth row of A (following IDL's convention of
;              treating arrays as images), and V1_i and V2_j are the ith and jth elements of the vectors V1 and
;              V2, respectively. To access the ith row and jth column of A, simply use A[j,i].
;                The function provides the option of using LONG type integers for the calculation of the outer
;              sum instead of DOUBLE type numbers via the use of the keyword INTEGER_OUTPUT.
;
; Input Parameters:
;
;   vec1 - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR - A scalar number or a vector of numbers with M elements.
;   vec2 - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR - A scalar number or a vector of numbers with N elements.
;   status - ANY - A variable which will be used to contain the output status of the function on returning (see
;                  output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully calculated the outer sum, then "status" is returned with a
;                      value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a two-dimensional array of DOUBLE type numbers of size M by N elements that represents
;   the outer sum matrix of the two vectors "vec1" and "vec2". Note that if "vec2" is a scalar number or a
;   single-element one-dimensional vector, then the function returns an M-element vector of DOUBLE type numbers
;   since IDL treats an Mx1 array as an M-element one-dimensional vector.
;
; Keywords:
;
;   If the keyword INTEGER_OUTPUT is set (as "/INTEGER_OUTPUT"), then the function will convert the elements of
;   the input parameters "vec1" and "vec2" into LONG type integers, and it will use them to calculate the outer
;   sum matrix as a two-dimensional array of LONG type integers instead of DOUBLE type numbers.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "vec1" contains numbers of the correct type
  if (test_bytintlonfltdbl(vec1) NE 1) then return, 0.0D

  ;Check that "vec1" is a scalar or a one-dimensional vector
  if (vec1.ndim GT 1L) then return, 0.0D

  ;Check that "vec2" contains numbers of the correct type
  if (test_bytintlonfltdbl(vec2) NE 1) then return, 0.0D

  ;Check that "vec2" is a scalar or a one-dimensional vector
  if (vec2.ndim GT 1L) then return, 0.0D
endif

;Set "status" to "1"
status = 1

;Calculate the outer sum
nv2 = vec2.length
if keyword_set(integer_output) then begin
  vec1_use = long(vec1)
  vec2_use = long(vec2)
  outer_sum = lonarr(vec1.length, nv2, /NOZERO)
endif else begin
  vec1_use = double(vec1)
  vec2_use = double(vec2)
  outer_sum = dblarr(vec1.length, nv2, /NOZERO)
endelse
for i = 0L,(nv2 - 1L) do outer_sum[0L,i] = vec1_use + vec2_use[i]

;Return the outer sum
return, outer_sum

END
