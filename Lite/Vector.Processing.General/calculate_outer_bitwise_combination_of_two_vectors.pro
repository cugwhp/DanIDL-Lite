FUNCTION calculate_outer_bitwise_combination_of_two_vectors, vec1, vec2, status, BITWISE_AND = bitwise_and, NO_PAR_CHECK = no_par_check

; Description: This function calculates the outer bit-wise OR combination of two input vectors "vec1" and "vec2"
;              not necessarily of the same length. The outer bit-wise OR combination of two vectors V1 and V2,
;              of length M and N elements respectively, is the MxN matrix A defined by:
;
;              A_ij = V1_i OR V2_j          1 <= i <= M, 1 <= j <= N
;
;              where the (i,j) indices refer to the ith column and jth row of A (following IDL's convention of
;              treating arrays as images), and V1_i and V2_j are the ith and jth elements of the vectors V1 and
;              V2, respectively. To access the ith row and jth column of A, simply use A[j,i]. The operator OR
;              represents the bit-wise OR operator.
;                The function provides the option of using the bit-wise AND operator in place of the bit-wise
;              OR operator in the equation defined above. This may be achieved by setting the keyword BITWISE_AND.
;
;              N.B: The implementation of bad pixel mask propagation in an associated "_werr.pro" function is
;                   feasible, but it has not been done yet due to the lack of a clear use-case scenario.
;
; Input Parameters:
;
;   vec1 - BYTE/INTEGER/LONG SCALAR/VECTOR - A scalar number or a vector of numbers with M elements. All elements
;                                            in this input parameter must be non-negative.
;   vec2 - BYTE/INTEGER/LONG SCALAR/VECTOR - A scalar number or a vector of numbers with N elements. All elements
;                                            in this input parameter must be non-negative.
;   status - ANY - A variable which will be used to contain the output status of the function on returning (see
;                  output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully calculated the outer bit-wise OR combination, then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a two-dimensional array of LONG type integers of size M by N elements that represents
;   the outer bit-wise OR combination matrix of the two vectors "vec1" and "vec2". Note that if "vec2" is a
;   scalar number or a single-element one-dimensional vector, then the function returns an M-element vector of
;   LONG type integers since IDL treats an Mx1 array as an M-element one-dimensional vector.
;
; Keywords:
;
;   If the keyword BITWISE_AND is set (as "/BITWISE_AND"), then the function will employ the bit-wise AND
;   operator in place of the bit-wise OR operator in the equation defined above.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "vec1" contains non-negative numbers of the correct number type
  if (test_bytintlon(vec1) NE 1) then return, 0L
  if (array_equal(vec1 GE 0B, 1B) EQ 0B) then return, 0L

  ;Check that "vec1" is a scalar or a one-dimensional vector
  if (vec1.ndim GT 1L) then return, 0L

  ;Check that "vec2" contains non-negative numbers of the correct number type
  if (test_bytintlon(vec2) NE 1) then return, 0L
  if (array_equal(vec2 GE 0B, 1B) EQ 0B) then return, 0L

  ;Check that "vec2" is a scalar or a one-dimensional vector
  if (vec2.ndim GT 1L) then return, 0L
endif

;Set "status" to "1"
status = 1

;Calculate the outer bit-wise combination
nv2 = vec2.length
vec1_use = long(vec1)
vec2_use = long(vec2)
outer_bitwise = lonarr(vec1.length, nv2, /NOZERO)
if keyword_set(bitwise_and) then begin
  for i = 0L,(nv2 - 1L) do outer_bitwise[0L,i] = vec1_use AND vec2_use[i]
endif else for i = 0L,(nv2 - 1L) do outer_bitwise[0L,i] = vec1_use OR vec2_use[i]

;Return the outer bit-wise combination
return, outer_bitwise

END
