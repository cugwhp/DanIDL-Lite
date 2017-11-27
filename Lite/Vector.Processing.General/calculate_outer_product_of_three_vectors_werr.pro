FUNCTION calculate_outer_product_of_three_vectors_werr, vec1, vec1_var, vec1_bpm, vec2, vec2_var, vec2_bpm, vec3, vec3_var, vec3_bpm, outdata_var, $
                                                        outdata_bpm, status, INTEGER_OUTPUT = integer_output, ERROR_PROPAGATION = error_propagation, $
                                                        BIT_PATTERN_PROPAGATION = bit_pattern_propagation, NO_VAR_PROPAGATION = no_var_propagation, $
                                                        NO_BPM_PROPAGATION = no_bpm_propagation, NO_PAR_CHECK = no_par_check

; Description: This function calculates the outer product of three input vectors "vec1", "vec2" and "vec3" not
;              necessarily of the same length. The outer product of three vectors V1, V2 and V3, of length M, N
;              and P elements respectively, is the MxNxP array A defined by:
;
;              A_ijk = V1_i*V2_j*V3_k          1 <= i <= M, 1 <= j <= N, 1 <= k <= P
;
;              where the (i,j,k) indices refer to the x, y and z axes of A, and V1_i, V2_j and V3_k are the ith,
;              jth and kth elements of the vectors V1, V2 and V3, respectively.
;                The function provides the option of using LONG type integers for the calculation of the outer
;              product instead of DOUBLE type numbers via the use of the keyword INTEGER_OUTPUT.
;                The function also performs propagation of the variances "vec1_var", "vec2_var" and "vec3_var"
;              associated with the input vectors "vec1", "vec2" and "vec3", respectively. It is assumed that
;              the data are independent and the function employs the following equation (see the DanIDL function
;              "propagate_variance_for_product_of_independent_rvs.pro"):
;
;              Var(A_ijk) = (V2_j^2)*(V3_k^2)*Var(V1_i) + (V1_i^2)*(V3_k^2)*Var(V2_j) + (V1_i^2)*(V2_j^2)*Var(V3_k)
;                           + (V3_k^2)*Var(V1_i)*Var(V2_j) + (V2_j^2)*Var(V1_i)*Var(V3_k) + (V1_i^2)*Var(V2_j)*Var(V3_k)
;                           + Var(V1_i)*Var(V2_j)*Var(V3_k)
;
;              where Var(A_ijk), Var(V1_i), Var(V2_j) and Var(V3_k) are the variances of A_ijk, V1_i, V2_j and
;              V3_k, respectively. The variance propagation that is performed is exact. The variances
;              corresponding to the outer product are returned via the output parameter "outdata_var". The
;              function provides the option of performing error propagation instead of variance propagation via
;              the use of the keyword ERROR_PROPAGATION. The function also provides the option of not performing
;              variance propagation via the use of the keyword NO_VAR_PROPAGATION.
;                The function also performs propagation of the binary bad pixel masks "vec1_bpm", "vec2_bpm" and
;              "vec3_bpm" associated with the input vectors "vec1", "vec2" and "vec3", respectively. Good pixels
;              should be flagged with a value of "1" in the bad pixel masks, and bad pixels may be flagged with
;              any other value. The bad pixel mask corresponding to the outer product is returned via the output
;              parameter "outdata_bpm". The function provides the option of performing bit pattern bad pixel
;              mask propagation instead of binary bad pixel mask propagation via the use of the keyword
;              BIT_PATTERN_PROPAGATION. The function also provides the option of not performing bad pixel mask
;              propagation via the use of the keyword NO_BPM_PROPAGATION.
;
; Input Parameters:
;
;   vec1 - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR - A scalar number or a vector of numbers with M elements.
;   vec1_var - FLOAT/DOUBLE SCALAR/VECTOR - A non-negative scalar number or a vector of non-negative numbers,
;                                           with the same number of elements as "vec1", where the elements
;                                           represent the variances associated with "vec1". If this input
;                                           parameter does not satisfy the input requirements, then all of the
;                                           variances are assumed to be zero. If the keyword ERROR_PROPAGATION
;                                           is set, then the elements of this input parameter are assumed to
;                                           represent standard errors as opposed to variances. If the keyword
;                                           NO_VAR_PROPAGATION is set, then this input parameter is ignored.
;   vec1_bpm - BYTE/INTEGER/LONG SCALAR/VECTOR - A scalar number or a vector of numbers, with the same number of
;                                                elements as "vec1", where the elements represent the bad pixel
;                                                mask values associated with "vec1". A value of "1" flags a good
;                                                pixel, and any other value flags a bad pixel. If this input
;                                                parameter does not satisfy the input requirements, then all
;                                                pixels will be considered good. If the keyword
;                                                BIT_PATTERN_PROPAGATION is set, then the elements of this input
;                                                parameter must also be non-negative and are assumed to represent
;                                                the pattern of bits that are set (or the equivalent binary
;                                                number). In this case, if the input parameter does not satisfy
;                                                the input requirements, then all of the elements of this input
;                                                parameter are assumed to be zero. If the keyword
;                                                NO_BPM_PROPAGATION is set, then this input parameter is ignored.
;   vec2 - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR - A scalar number or a vector of numbers with N elements.
;   vec2_var - FLOAT/DOUBLE SCALAR/VECTOR - A non-negative scalar number or a vector of non-negative numbers,
;                                           with the same number of elements as "vec2", where the elements
;                                           represent the variances associated with "vec2". If this input
;                                           parameter does not satisfy the input requirements, then all of the
;                                           variances are assumed to be zero. If the keyword ERROR_PROPAGATION
;                                           is set, then the elements of this input parameter are assumed to
;                                           represent standard errors as opposed to variances. If the keyword
;                                           NO_VAR_PROPAGATION is set, then this input parameter is ignored.
;   vec2_bpm - BYTE/INTEGER/LONG SCALAR/VECTOR - A scalar number or a vector of numbers, with the same number of
;                                                elements as "vec2", where the elements represent the bad pixel
;                                                mask values associated with "vec2". A value of "1" flags a good
;                                                pixel, and any other value flags a bad pixel. If this input
;                                                parameter does not satisfy the input requirements, then all
;                                                pixels will be considered good. If the keyword
;                                                BIT_PATTERN_PROPAGATION is set, then the elements of this input
;                                                parameter must also be non-negative and are assumed to represent
;                                                the pattern of bits that are set (or the equivalent binary
;                                                number). In this case, if the input parameter does not satisfy
;                                                the input requirements, then all of the elements of this input
;                                                parameter are assumed to be zero. If the keyword
;                                                NO_BPM_PROPAGATION is set, then this input parameter is ignored.
;   vec3 - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR - A scalar number or a vector of numbers with P elements.
;   vec3_var - FLOAT/DOUBLE SCALAR/VECTOR - A non-negative scalar number or a vector of non-negative numbers,
;                                           with the same number of elements as "vec3", where the elements
;                                           represent the variances associated with "vec3". If this input
;                                           parameter does not satisfy the input requirements, then all of the
;                                           variances are assumed to be zero. If the keyword ERROR_PROPAGATION
;                                           is set, then the elements of this input parameter are assumed to
;                                           represent standard errors as opposed to variances. If the keyword
;                                           NO_VAR_PROPAGATION is set, then this input parameter is ignored.
;   vec3_bpm - BYTE/INTEGER/LONG SCALAR/VECTOR - A scalar number or a vector of numbers, with the same number of
;                                                elements as "vec3", where the elements represent the bad pixel
;                                                mask values associated with "vec3". A value of "1" flags a good
;                                                pixel, and any other value flags a bad pixel. If this input
;                                                parameter does not satisfy the input requirements, then all
;                                                pixels will be considered good. If the keyword
;                                                BIT_PATTERN_PROPAGATION is set, then the elements of this input
;                                                parameter must also be non-negative and are assumed to represent
;                                                the pattern of bits that are set (or the equivalent binary
;                                                number). In this case, if the input parameter does not satisfy
;                                                the input requirements, then all of the elements of this input
;                                                parameter are assumed to be zero. If the keyword
;                                                NO_BPM_PROPAGATION is set, then this input parameter is ignored.
;   outdata_var - ANY - A variable which will be used to contain the variances corresponding to the outer product
;                       on returning (see output parameters below).
;   outdata_bpm - ANY - A variable which will be used to contain the bad pixel mask corresponding to the outer
;                       product on returning (see output parameters below).
;   status - ANY - A variable which will be used to contain the output status of the function on returning (see
;                  output parameters below).
;
; Output Parameters:
;
;   outdata_var - DOUBLE ARRAY - An array of the same size as the return value where the elements represent the
;                                variances corresponding to the outer product. If the keyword ERROR_PROPAGATION
;                                is set, then the elements of this output parameter represent the standard errors
;                                corresponding to the outer product. If the keyword NO_VAR_PROPAGATION is set,
;                                then this output parameter is set to "0.0D".
;   outdata_bpm - INTEGER ARRAY - An array of the same size as the return value where the elements represent the
;                                 bad pixel mask values corresponding to the outer product. A value of "1" flags
;                                 a good pixel, and a value of "0" flags a bad pixel. If the keyword
;                                 BIT_PATTERN_PROPAGATION is set, then the elements of this output parameter are
;                                 LONG type integers and they represent the pattern of bits that are set (or the
;                                 equivalent binary number). If the keyword NO_BPM_PROPAGATION is set, then this
;                                 output parameter is set to "0".
;   status - INTEGER - If the function successfully calculated the outer product, then "status" is returned with
;                      a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a three-dimensional array of DOUBLE type numbers of size M by N by P elements that
;   represents the outer product of the three vectors "vec1", "vec2" and "vec3". Note that if "vec2" and "vec3"
;   are both scalar numbers or single-element one-dimensional vectors, then the function returns an M-element
;   vector of DOUBLE type numbers since IDL treats an Mx1x1 array as an M-element one-dimensional vector. Also,
;   if only "vec3" is a scalar number or a single-element one-dimensional vector, then the function returns an
;   M by N element two-dimensional array of DOUBLE type numbers since IDL treats an MxNx1 array as an MxN-element
;   two-dimensional array.
;
; Keywords:
;
;   If the keyword INTEGER_OUTPUT is set (as "/INTEGER_OUTPUT"), then the function will convert the elements of
;   the input parameters "vec1", "vec2" and "vec3" into LONG type integers, and it will use them to calculate
;   the outer product array as a three-dimensional array of LONG type integers instead of DOUBLE type numbers.
;
;   If the keyword ERROR_PROPAGATION is set (as "/ERROR_PROPAGATION"), then the function will perform error
;   propagation instead of variance propagation. In other words, the elements of the input parameters "vec1_var",
;   "vec2_var" and "vec3_var" are assumed to represent standard errors, and the output parameter "outdata_var"
;   is returned with elements representing standard errors. This keyword is ignored if the keyword
;   NO_VAR_PROPAGATION is set.
;
;   If the keyword BIT_PATTERN_PROPAGATION is set (as "/BIT_PATTERN_PROPAGATION"), then the function will
;   perform bit pattern bad pixel mask propagation instead of binary bad pixel mask propagation. In other words,
;   the elements of the input parameters "vec1_bpm", "vec2_bpm" and "vec3_bpm" are assumed to represent bit
;   patterns, the bad pixel mask propagation is performed using the bit-wise OR operator, and the output
;   parameter "outdata_bpm" is returned with elements as LONG type integers that represent the output bit
;   patterns. This keyword is ignored if the keyword NO_BPM_PROPAGATION is set.
;
;   If the keyword NO_VAR_PROPAGATION is set (as "/NO_VAR_PROPAGATION"), then the function will not perform
;   variance propagation. This allows the user to build more efficient code for the case that only bad pixel
;   mask propagation is required.
;
;   If the keyword NO_BPM_PROPAGATION is set (as "/NO_BPM_PROPAGATION"), then the function will not perform
;   bad pixel mask propagation. This allows the user to build more efficient code for the case that only
;   variance propagation is required.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
outdata_var = 0.0D
outdata_bpm = 0

;Calculate the outer product array
outdata = calculate_outer_product_of_three_vectors(vec1, vec2, vec3, status, INTEGER_OUTPUT = integer_output, NO_PAR_CHECK = no_par_check)
if (status EQ 0) then return, outdata

;Determine the number of elements in "vec1", "vec2" and "vec3"
nv1 = vec1.length
nv2 = vec2.length
nv3 = vec3.length

;If variance propagation is required
if ~keyword_set(no_var_propagation) then begin

  ;Check that "vec1_var" is a non-negative scalar number, or a vector of non-negative numbers, of the correct number
  ;type with the same number of elements as "vec1"
  vec1_var_tag = 0
  if (test_fltdbl(vec1_var) EQ 1) then begin
    if (vec1_var.ndim LT 2L) then begin
      if (vec1_var.length EQ nv1) then vec1_var_tag = fix(array_equal(vec1_var GE 0.0, 1B))
    endif
  endif
  if (vec1_var_tag EQ 1) then begin
    vec1_var_use = double(vec1_var)
  endif else vec1_var_use = dblarr(nv1)

  ;Check that "vec2_var" is a non-negative scalar number, or a vector of non-negative numbers, of the correct number
  ;type with the same number of elements as "vec2"
  vec2_var_tag = 0
  if (test_fltdbl(vec2_var) EQ 1) then begin
    if (vec2_var.ndim LT 2L) then begin
      if (vec2_var.length EQ nv2) then vec2_var_tag = fix(array_equal(vec2_var GE 0.0, 1B))
    endif
  endif
  if (vec2_var_tag EQ 1) then begin
    vec2_var_use = double(vec2_var)
  endif else vec2_var_use = dblarr(nv2)

  ;Check that "vec3_var" is a non-negative scalar number, or a vector of non-negative numbers, of the correct number
  ;type with the same number of elements as "vec3"
  vec3_var_tag = 0
  if (test_fltdbl(vec3_var) EQ 1) then begin
    if (vec3_var.ndim LT 2L) then begin
      if (vec3_var.length EQ nv3) then vec3_var_tag = fix(array_equal(vec3_var GE 0.0, 1B))
    endif
  endif
  if (vec3_var_tag EQ 1) then begin
    vec3_var_use = double(vec3_var)
  endif else vec3_var_use = dblarr(nv3)

  ;If the keyword ERROR_PROPAGATION is set, then square the input parameters "vec1_var", "vec2_var" and "vec3_var"
  if keyword_set(error_propagation) then begin
    if (vec1_var_tag EQ 1) then vec1_var_use = vec1_var_use*vec1_var_use
    if (vec2_var_tag EQ 1) then vec2_var_use = vec2_var_use*vec2_var_use
    if (vec3_var_tag EQ 1) then vec3_var_use = vec3_var_use*vec3_var_use
  endif

  ;Perform the variance propagation
  vec1_use = double(vec1)
  vec2_use = double(vec2)
  vec3_use = double(vec3)
  vec1_use = vec1_use*vec1_use
  vec2_use = vec2_use*vec2_use
  vec3_use = vec3_use*vec3_use + vec3_var_use
  outdata_var = calculate_outer_product_of_three_vectors(vec1_use, vec2_use, vec3_var_use, stat, /NO_PAR_CHECK)
  if (vec1_var_tag EQ 1) then outdata_var = temporary(outdata_var) + calculate_outer_product_of_three_vectors(vec1_var_use, vec2_use, vec3_use, stat, /NO_PAR_CHECK)
  if (vec2_var_tag EQ 1) then outdata_var = temporary(outdata_var) + calculate_outer_product_of_three_vectors(vec1_use + vec1_var_use, vec2_var_use, vec3_use, stat, /NO_PAR_CHECK)

  ;If the keyword ERROR_PROPAGATION is set, then convert the output variances to standard errors
  if keyword_set(error_propagation) then outdata_var = sqrt(temporary(outdata_var))
endif

;If bad pixel mask propagation is required
if ~keyword_set(no_bpm_propagation) then begin

  ;Check that "vec1_bpm" is a scalar number, or a vector of numbers, of the correct number type with the same number
  ;of elements as "vec1". If necessary, also check that all of the elements of this input parameter are non-negative.
  vec1_bpm_tag = 0
  if (test_bytintlon(vec1_bpm) EQ 1) then begin
    if (vec1_bpm.ndim LT 2L) then begin
      if (vec1_bpm.length EQ nv1) then begin
        if keyword_set(bit_pattern_propagation) then begin
          vec1_bpm_tag = fix(array_equal(vec1_bpm GE 0B, 1B))
        endif else vec1_bpm_tag = 1
      endif
    endif
  endif
  if keyword_set(bit_pattern_propagation) then begin
    if (vec1_bpm_tag EQ 1) then begin
      vec1_bpm_use = long(vec1_bpm)
    endif else vec1_bpm_use = lonarr(nv1)
  endif else begin
    if (vec1_bpm_tag EQ 1) then begin
      vec1_bpm_use = long(vec1_bpm)
      subs = where(vec1_bpm_use NE 1L, nsubs)
      if (nsubs GT 0L) then vec1_bpm_use[subs] = 0L
    endif else vec1_bpm_use = replicate(1L, nv1)
  endelse

  ;Check that "vec2_bpm" is a scalar number, or a vector of numbers, of the correct number type with the same number
  ;of elements as "vec2". If necessary, also check that all of the elements of this input parameter are non-negative.
  vec2_bpm_tag = 0
  if (test_bytintlon(vec2_bpm) EQ 1) then begin
    if (vec2_bpm.ndim LT 2L) then begin
      if (vec2_bpm.length EQ nv2) then begin
        if keyword_set(bit_pattern_propagation) then begin
          vec2_bpm_tag = fix(array_equal(vec2_bpm GE 0B, 1B))
        endif else vec2_bpm_tag = 1
      endif
    endif
  endif
  if keyword_set(bit_pattern_propagation) then begin
    if (vec2_bpm_tag EQ 1) then begin
      vec2_bpm_use = long(vec2_bpm)
    endif else vec2_bpm_use = lonarr(nv2)
  endif else begin
    if (vec2_bpm_tag EQ 1) then begin
      vec2_bpm_use = long(vec2_bpm)
      subs = where(vec2_bpm_use NE 1L, nsubs)
      if (nsubs GT 0L) then vec2_bpm_use[subs] = 0L
    endif else vec2_bpm_use = replicate(1L, nv2)
  endelse

  ;Check that "vec3_bpm" is a scalar number, or a vector of numbers, of the correct number type with the same number
  ;of elements as "vec3". If necessary, also check that all of the elements of this input parameter are non-negative.
  vec3_bpm_tag = 0
  if (test_bytintlon(vec3_bpm) EQ 1) then begin
    if (vec3_bpm.ndim LT 2L) then begin
      if (vec3_bpm.length EQ nv3) then begin
        if keyword_set(bit_pattern_propagation) then begin
          vec3_bpm_tag = fix(array_equal(vec3_bpm GE 0B, 1B))
        endif else vec3_bpm_tag = 1
      endif
    endif
  endif
  if keyword_set(bit_pattern_propagation) then begin
    if (vec3_bpm_tag EQ 1) then begin
      vec3_bpm_use = long(vec3_bpm)
    endif else vec3_bpm_use = lonarr(nv3)
  endif else begin
    if (vec3_bpm_tag EQ 1) then begin
      vec3_bpm_use = long(vec3_bpm)
      subs = where(vec3_bpm_use NE 1L, nsubs)
      if (nsubs GT 0L) then vec3_bpm_use[subs] = 0L
    endif else vec3_bpm_use = replicate(1L, nv3)
  endelse

  ;If the keyword BIT_PATTERN_PROPAGATION is set
  if keyword_set(bit_pattern_propagation) then begin

    ;Perform the bit pattern bad pixel mask propagation
    outdata_bpm = calculate_outer_bitwise_combination_of_three_vectors(vec1_bpm_use, vec2_bpm_use, vec3_bpm_use, stat, /NO_PAR_CHECK)

  ;If the keyword BIT_PATTERN_PROPAGATION is not set, then perform the binary bad pixel mask propagation
  endif else outdata_bpm = fix(calculate_outer_product_of_three_vectors(vec1_bpm_use, vec2_bpm_use, vec3_bpm_use, stat, /INTEGER_OUTPUT, /NO_PAR_CHECK))
endif

;Return the outer product
return, outdata

END
