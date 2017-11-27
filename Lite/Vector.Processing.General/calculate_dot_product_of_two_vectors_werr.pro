FUNCTION calculate_dot_product_of_two_vectors_werr, vec1, vec1_var, vec1_bpm, vec2, vec2_var, vec2_bpm, dot_product_var, dot_product_bpm, status, $
                                                    danidl_cppcode, INTEGER_OUTPUT = integer_output, ERROR_PROPAGATION = error_propagation, $
                                                    BIT_PATTERN_PROPAGATION = bit_pattern_propagation, NO_VAR_PROPAGATION = no_var_propagation, $
                                                    NO_BPM_PROPAGATION = no_bpm_propagation, NO_PAR_CHECK = no_par_check

; Description: This function calculates the dot product (or scalar product, or inner product) of two input
;              vectors "vec1" and "vec2" of the same length. The dot product of two vectors V1 and V2 is a
;              scalar (single number) defined as:
;
;                       N
;              V1.V2 = SUM V1_i*V2_i
;                      i=1
;
;              where V1_i and V2_i are the ith elements of the vectors V1 and V2, respectively, and N is the
;              number of elements in each vector.
;                The function provides the option of using LONG type integers for the calculation of the dot
;              product instead of DOUBLE type numbers via the use of the keyword INTEGER_OUTPUT.
;                The function also performs propagation of the variances "vec1_var" and "vec2_var" associated
;              with the input vectors "vec1" and "vec2", respectively. It is assumed that the data are
;              independent and the function employs the following equation (see the DanIDL functions
;              "propagate_variance_for_product_pairs.pro" and "propagate_variance_for_sum_of_rvs.pro"):
;
;                            N  [                                                               ]
;              Var(V1.V2) = SUM [ (V2_i^2)*Var(V1_i) + (V1_i^2)*Var(V2_i) + Var(V1_i)*Var(V2_i) ]
;                           i=1 [                                                               ]
;
;              where Var(V1.V2), Var(V1_i) and Var(V2_i) are the variances of V1.V2, V1_i and V2_i,
;              respectively. The variance propagation that is performed is exact. The variance corresponding
;              to the dot product is returned via the output parameter "dot_product_var". The function
;              provides the option of performing error propagation instead of variance propagation via the
;              use of the keyword ERROR_PROPAGATION. The function also provides the option of not performing
;              variance propagation via the use of the keyword NO_VAR_PROPAGATION.
;                The function also performs propagation of the binary bad pixel masks "vec1_bpm" and
;              "vec2_bpm" associated with the input vectors "vec1" and "vec2", respectively. Good pixels
;              should be flagged with a value of "1" in the bad pixel masks, and bad pixels may be flagged
;              with any other value. The bad pixel mask value corresponding to the dot product is returned
;              via the output parameter "dot_product_bpm". The function provides the option of performing
;              bit pattern bad pixel mask propagation instead of binary bad pixel mask propagation via the
;              use of the keyword BIT_PATTERN_PROPAGATION. The function also provides the option of not
;              performing bad pixel mask propagation via the use of the keyword NO_BPM_PROPAGATION.
;                If the keyword BIT_PATTERN_PROPAGATION is set, then this function will use C++ code if
;              possible to achieve a faster execution than the default IDL code. The C++ code can speed up
;              the bit-wise OR operations that are performed in this case by up to ~14.5 times.
;
; Input Parameters:
;
;   vec1 - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR - A scalar number or a vector of numbers.
;   vec1_var - FLOAT/DOUBLE SCALAR/VECTOR - A non-negative scalar number or a vector of non-negative numbers,
;                                           with the same number of elements as "vec1", where the elements
;                                           represent the variances associated with "vec1". If this input
;                                           parameter does not satisfy the input requirements, then all of
;                                           the variances are assumed to be zero. If the keyword
;                                           ERROR_PROPAGATION is set, then the elements of this input
;                                           parameter are assumed to represent standard errors as opposed
;                                           to variances. If the keyword NO_VAR_PROPAGATION is set, then
;                                           this input parameter is ignored.
;   vec1_bpm - BYTE/INTEGER/LONG SCALAR/VECTOR - A scalar number or a vector of numbers, with the same number
;                                                of elements as "vec1", where the elements represent the bad
;                                                pixel mask values associated with "vec1". A value of "1"
;                                                flags a good pixel, and any other value flags a bad pixel.
;                                                If this input parameter does not satisfy the input
;                                                requirements, then all pixels will be considered good. If
;                                                the keyword BIT_PATTERN_PROPAGATION is set, then the
;                                                elements of this input parameter must also be non-negative
;                                                and are assumed to represent the pattern of bits that are
;                                                set (or the equivalent binary number). In this case, if
;                                                the input parameter does not satisfy the input requirements,
;                                                then all of the elements of this input parameter are
;                                                assumed to be zero. If the keyword NO_BPM_PROPAGATION is
;                                                set, then this input parameter is ignored.
;   vec2 - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR - A scalar number or a vector of numbers. This
;                                                         parameter must have the same number of elements
;                                                         as "vec1".
;   vec2_var - FLOAT/DOUBLE SCALAR/VECTOR - A non-negative scalar number or a vector of non-negative numbers,
;                                           with the same number of elements as "vec2", where the elements
;                                           represent the variances associated with "vec2". If this input
;                                           parameter does not satisfy the input requirements, then all of
;                                           the variances are assumed to be zero. If the keyword
;                                           ERROR_PROPAGATION is set, then the elements of this input
;                                           parameter are assumed to represent standard errors as opposed
;                                           to variances. If the keyword NO_VAR_PROPAGATION is set, then
;                                           this input parameter is ignored.
;   vec2_bpm - BYTE/INTEGER/LONG SCALAR/VECTOR - A scalar number or a vector of numbers, with the same number
;                                                of elements as "vec2", where the elements represent the bad
;                                                pixel mask values associated with "vec2". A value of "1"
;                                                flags a good pixel, and any other value flags a bad pixel.
;                                                If this input parameter does not satisfy the input
;                                                requirements, then all pixels will be considered good. If
;                                                the keyword BIT_PATTERN_PROPAGATION is set, then the
;                                                elements of this input parameter must also be non-negative
;                                                and are assumed to represent the pattern of bits that are
;                                                set (or the equivalent binary number). In this case, if
;                                                the input parameter does not satisfy the input requirements,
;                                                then all of the elements of this input parameter are
;                                                assumed to be zero. If the keyword NO_BPM_PROPAGATION is
;                                                set, then this input parameter is ignored.
;   dot_product_var - ANY - A variable which will be used to contain the variance corresponding to the dot
;                           product on returning (see output parameters below).
;   dot_product_bpm - ANY - A variable which will be used to contain the bad pixel mask value corresponding
;                           to the dot product on returning (see output parameters below).
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;   danidl_cppcode - STRING - The full directory path indicating where the DanIDL C++ code is installed.
;                             The shared library of DanIDL C++ routines should exist as
;                             "<danidl_cppcode>/dist/libDanIDL.so" within the installation. If this input
;                             parameter is not specified correctly, then the default IDL code will be used
;                             instead. This input parameter is only used if the keyword
;                             BIT_PATTERN_PROPAGATION is set.
;
; Output Parameters:
;
;   dot_product_var - DOUBLE - The variance corresponding to the dot product. If the keyword
;                              ERROR_PROPAGATION is set, then this output parameter represents the standard
;                              error corresponding to the dot product. If the keyword NO_VAR_PROPAGATION is
;                              set, then this output parameter is set to "0.0D".
;   dot_product_bpm - INTEGER - The bad pixel mask value corresponding to the dot product. A value of "1"
;                               flags a good pixel, and a value of "0" flags a bad pixel. If the keyword
;                               BIT_PATTERN_PROPAGATION is set, then this output parameter is a LONG type
;                               integer that represents the pattern of bits that are set (or the equivalent
;                               binary number). If the keyword NO_BPM_PROPAGATION is set, then this output
;                               parameter is set to "0".
;   status - INTEGER - If the function successfully calculated the dot product, then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision SCALAR number that represents the dot product of the two
;   vectors "vec1" and "vec2".
;
; Keywords:
;
;   If the keyword INTEGER_OUTPUT is set (as "/INTEGER_OUTPUT"), then the module will convert the elements
;   of the input parameters "vec1" and "vec2" into LONG type integers, and it will use them to calculate
;   the dot product as a LONG type integer instead of as a DOUBLE type number.
;
;   If the keyword ERROR_PROPAGATION is set (as "/ERROR_PROPAGATION"), then the function will perform error
;   propagation instead of variance propagation. In other words, the elements of the input parameters
;   "vec1_var" and "vec2_var" are assumed to represent standard errors, and the output parameter
;   "dot_product_var" is returned representing a standard error. This keyword is ignored if the keyword
;   NO_VAR_PROPAGATION is set.
;
;   If the keyword BIT_PATTERN_PROPAGATION is set (as "/BIT_PATTERN_PROPAGATION"), then the function will
;   perform bit pattern bad pixel mask propagation instead of binary bad pixel mask propagation. In other
;   words, the elements of the input parameters "vec1_bpm" and "vec2_bpm" are assumed to represent bit
;   patterns, the bad pixel mask propagation is performed using the bit-wise OR operator, and the output
;   parameter "dot_product_bpm" is returned as a LONG type integer that represents the output bit pattern.
;   This keyword is ignored if the keyword NO_BPM_PROPAGATION is set.
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
dot_product_var = 0.0D
dot_product_bpm = 0

;Calculate the dot product
dot_product = calculate_dot_product_of_two_vectors(vec1, vec2, status, INTEGER_OUTPUT = integer_output, NO_PAR_CHECK = no_par_check)
if (status EQ 0) then return, dot_product

;Determine the number of elements in "vec1"
nv1 = vec1.length

;If variance propagation is required
if ~keyword_set(no_var_propagation) then begin

  ;Check that "vec1_var" is a non-negative scalar number, or a vector of non-negative numbers, of the correct
  ;number type with the same number of elements as "vec1"
  vec1_var_tag = 0
  if (test_fltdbl(vec1_var) EQ 1) then begin
    if (vec1_var.ndim LT 2L) then begin
      if (vec1_var.length EQ nv1) then vec1_var_tag = fix(array_equal(vec1_var GE 0.0, 1B))
    endif
  endif

  ;Check that "vec2_var" is a non-negative scalar number, or a vector of non-negative numbers, of the correct
  ;number type with the same number of elements as "vec2"
  vec2_var_tag = 0
  if (test_fltdbl(vec2_var) EQ 1) then begin
    if (vec2_var.ndim LT 2L) then begin
      if (vec2_var.length EQ nv1) then vec2_var_tag = fix(array_equal(vec2_var GE 0.0, 1B))
    endif
  endif

  ;Perform the variance propagation
  if (vec1_var_tag EQ 1) then begin
    if (vec2_var_tag EQ 1) then begin
      tmp_vec = propagate_variance_for_product_pairs(vec1_var, vec2_var, double(vec1), double(vec2), 0.0D, 0.0D, stat, ERROR_IN = error_propagation, /NO_PAR_CHECK)
    endif else tmp_vec = propagate_variance_for_linear_combination_pairs(vec1_var, 0.0D, 0.0D, double(vec2), 0.0D, stat, ERROR_IN = error_propagation, /NO_PAR_CHECK)
    dot_product_var = propagate_variance_for_sum_of_rvs([tmp_vec], sign_arr, stat, ERROR_OUT = error_propagation, /NO_PAR_CHECK)
  endif else begin
    if (vec2_var_tag EQ 1) then begin
      tmp_vec = propagate_variance_for_linear_combination_pairs(vec2_var, 0.0D, 0.0D, double(vec1), 0.0D, stat, ERROR_IN = error_propagation, /NO_PAR_CHECK)
      dot_product_var = propagate_variance_for_sum_of_rvs([tmp_vec], sign_arr, stat, ERROR_OUT = error_propagation, /NO_PAR_CHECK)
    endif
  endelse
endif

;If bad pixel mask propagation is required
if ~keyword_set(no_bpm_propagation) then begin

  ;Check that "vec1_bpm" is a scalar number, or a vector of numbers, of the correct number type with the same
  ;number of elements as "vec1". If necessary, also check that all of the elements of this input parameter
  ;are non-negative.
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

  ;Check that "vec2_bpm" is a scalar number, or a vector of numbers, of the correct number type with the same
  ;number of elements as "vec2". If necessary, also check that all of the elements of this input parameter
  ;are non-negative.
  vec2_bpm_tag = 0
  if (test_bytintlon(vec2_bpm) EQ 1) then begin
    if (vec2_bpm.ndim LT 2L) then begin
      if (vec2_bpm.length EQ nv1) then begin
        if keyword_set(bit_pattern_propagation) then begin
          vec2_bpm_tag = fix(array_equal(vec2_bpm GE 0B, 1B))
        endif else vec2_bpm_tag = 1
      endif
    endif
  endif

  ;If the keyword BIT_PATTERN_PROPAGATION is set
  if keyword_set(bit_pattern_propagation) then begin

    ;Perform the bit pattern bad pixel mask propagation
    if (vec1_bpm_tag EQ 1) then begin
      if (vec2_bpm_tag EQ 1) then begin
        dot_product_bpm = bitwise_or(long(vec1_bpm) OR long(vec2_bpm), stat, danidl_cppcode)
      endif else dot_product_bpm = bitwise_or(long(vec1_bpm), stat, danidl_cppcode)
    endif else begin
      if (vec2_bpm_tag EQ 1) then begin
        dot_product_bpm = bitwise_or(long(vec2_bpm), stat, danidl_cppcode)
      endif else dot_product_bpm = 0L
    endelse

  ;If the keyword BIT_PATTERN_PROPAGATION is not set
  endif else begin

    ;Perform the binary bad pixel mask propagation
    if (vec1_bpm_tag EQ 1) then begin
      dot_product_bpm = fix(array_equal(long(vec1_bpm), 1L))
    endif else dot_product_bpm = 1
    if (dot_product_bpm EQ 1) then begin
      if (vec2_bpm_tag EQ 1) then dot_product_bpm = fix(array_equal(long(vec2_bpm), 1L))
    endif
  endelse
endif

;Return the dot product
return, dot_product

END
