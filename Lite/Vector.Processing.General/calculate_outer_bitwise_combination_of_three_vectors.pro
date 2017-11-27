FUNCTION calculate_outer_bitwise_combination_of_three_vectors, vec1, vec2, vec3, status, BITWISE_AND = bitwise_and, NO_PAR_CHECK = no_par_check

; Description: This function calculates the outer bit-wise OR combination of three input vectors "vec1", "vec2"
;              and "vec3" not necessarily of the same length. The outer bit-wise OR combination of three vectors
;              V1, V2 and V3, of length M, N and P elements respectively, is the MxNxP array A defined by:
;
;              A_ijk = V1_i OR V2_j OR V3_k            1 <= i <= M, 1 <= j <= N, 1 <= k <= P
;
;              where the (i,j,k) indices refer to the x, y and z axes of A, and V1_i, V2_j and V3_k are the ith,
;              jth and kth elements of the vectors V1, V2 and V3, respectively. The operator OR represents the
;              bit-wise OR operator.
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
;   vec3 - BYTE/INTEGER/LONG SCALAR/VECTOR - A scalar number or a vector of numbers with P elements. All elements
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
;   The function returns a three-dimensional array of LONG type integers of size M by N by P elements that
;   represents the outer bit-wise OR combination of the three vectors "vec1", "vec2" and "vec3". Note that if
;   "vec2" and "vec3" are both scalar numbers or single-element one-dimensional vectors, then the function returns
;   an M-element vector of LONG type integers since IDL treats an Mx1x1 array as an M-element one-dimensional
;   vector. Also, if only "vec3" is a scalar number or a single-element one-dimensional vector, then the function
;   returns an M by N element two-dimensional array of LONG type integers since IDL treats an MxNx1 array as an
;   MxN-element two-dimensional array.
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

  ;Check that "vec3" contains non-negative numbers of the correct number type
  if (test_bytintlon(vec3) NE 1) then return, 0L
  if (array_equal(vec3 GE 0B, 1B) EQ 0B) then return, 0L

  ;Check that "vec3" is a scalar or a one-dimensional vector
  if (vec3.ndim GT 1L) then return, 0L
endif

;Set "status" to "1"
status = 1

;If "vec2" and "vec3" both have only a single element
nv2 = vec2.length
nv3 = vec3.length
if ((nv2 EQ 1L) AND (nv3 EQ 1L)) then begin

  ;Calculate and return the outer bit-wise combination
  if keyword_set(bitwise_and) then begin
    return, long([vec1]) AND (long(vec2[0]) AND long(vec3[0]))
  endif else return, long([vec1]) OR (long(vec2[0]) OR long(vec3[0]))
endif

;If "vec1" and "vec3" both have only a single element
nv1 = vec1.length
if ((nv1 EQ 1L) AND (nv3 EQ 1L)) then begin

  ;Calculate and return the outer bit-wise combination
  if keyword_set(bitwise_and) then begin
    return, reform((long(vec1[0]) AND long(vec3[0])) AND long(vec2), 1L, nv2)
  endif else return, reform((long(vec1[0]) OR long(vec3[0])) OR long(vec2), 1L, nv2)
endif

;If "vec1" and "vec2" both have only a single element
if ((nv1 EQ 1L) AND (nv2 EQ 1L)) then begin

  ;Calculate and return the outer bit-wise combination
  if keyword_set(bitwise_and) then begin
    return, reform((long(vec1[0]) AND long(vec2[0])) AND long(vec3), 1L, 1L, nv3)
  endif else return, reform((long(vec1[0]) OR long(vec2[0])) OR long(vec3), 1L, 1L, nv3)
endif

;If "vec1" has only a single element
if (nv1 EQ 1L) then begin

  ;Calculate and return the outer bit-wise combination
  if keyword_set(bitwise_and) then begin
    return, reform(calculate_outer_bitwise_combination_of_two_vectors(vec2, long(vec1[0]) AND long(vec3), stat, /BITWISE_AND, /NO_PAR_CHECK), 1L, nv2, nv3)
  endif else return, reform(calculate_outer_bitwise_combination_of_two_vectors(vec2, long(vec1[0]) OR long(vec3), stat, /NO_PAR_CHECK), 1L, nv2, nv3)
endif

;If "vec2" has only a single element
if (nv2 EQ 1L) then begin

  ;Calculate and return the outer bit-wise combination
  if keyword_set(bitwise_and) then begin
    return, reform(calculate_outer_bitwise_combination_of_two_vectors(vec1, long(vec2[0]) AND long(vec3), stat, /BITWISE_AND, /NO_PAR_CHECK), nv1, 1L, nv3)
  endif else return, reform(calculate_outer_bitwise_combination_of_two_vectors(vec1, long(vec2[0]) OR long(vec3), stat, /NO_PAR_CHECK), nv1, 1L, nv3)
endif

;If "vec3" has only a single element
if (nv3 EQ 1L) then begin

  ;Calculate and return the outer bit-wise combination
  if keyword_set(bitwise_and) then begin
    return, calculate_outer_bitwise_combination_of_two_vectors(vec1, long(vec3[0]) AND long(vec2), stat, /BITWISE_AND, /NO_PAR_CHECK)
  endif else return, calculate_outer_bitwise_combination_of_two_vectors(vec1, long(vec3[0]) OR long(vec2), stat, /NO_PAR_CHECK)
endif

;The remainder of the code deals with the case where all three vectors each have at least two elements. Calculate
;and return the outer bit-wise combination.
tmp_vec = reform(calculate_outer_bitwise_combination_of_two_vectors(vec1, vec2, stat, BITWISE_AND = bitwise_and, /NO_PAR_CHECK), nv1*nv2)
return, reform(calculate_outer_bitwise_combination_of_two_vectors(tmp_vec, vec3, stat, BITWISE_AND = bitwise_and, /NO_PAR_CHECK), nv1, nv2, nv3)

END
