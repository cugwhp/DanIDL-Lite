PRO generate_arithmetic_sequence_werr, a1, a1_var, d, d_var, a1_d_covar, n, seq, seq_var, status, INTEGER_SEQUENCE = integer_sequence, $
                                       COVARIANCE_MATRIX = covariance_matrix, ERROR_PROPAGATION = error_propagation, NO_PAR_CHECK = no_par_check

; Description: This module generates an arithmetic sequence of "n" elements with first element "a1" and a
;              difference "d" between consecutive elements. The sequence is returned as the one-dimensional
;              vector "seq". Mathematically, the arithmetic sequence is defined as:
;
;              seq[i] = a1 + (i - 1)*d                  for i = 1,2,...,n
;
;                By setting the keyword INTEGER_SEQUENCE, the module will convert the input parameters "a1"
;              and "d" into LONG type integers, and it will use them to generate the output arithmetic
;              sequence "seq" as a sequence of numbers of LONG type.
;                The module also performs propagation of the variances "a1_var" and "d_var", and the
;              covariance "a1_d_covar", associated with the input parameters "a1" and "d", respectively.
;              The module employs the following equation (see the DanIDL function
;              "propagate_variance_for_linear_combination_pairs.pro"):
;
;              Var(seq[i]) = Var(a1) + ((i - 1)^2)*Var(d) + 2*(i - 1)*Cov(a1,d)          for i = 1,2,...,n
;
;              where Var(seq[i]), Var(a1) and Var(d) are the variances of seq[i], a1 and d, respectively,
;              and Cov(a1,d) is the covariance between a1 and d. The variance propagation that is performed
;              is exact. The variances corresponding to the arithmetic sequence "seq" are returned via the
;              output parameter "seq_var". The module provides the option of performing error propagation
;              instead of variance propagation via the use of the keyword ERROR_PROPAGATION.
;                By setting the keyword COVARIANCE_MATRIX, the module will calculate the full covariance
;              matrix of size "n" by "n" elements for the arithmetic sequence by employing the following
;              equation (see the DanIDL function "propagate_variance_for_general_linear_transformation.pro"):
;
;              Cov(seq[i],seq[j]) = Var(a1) + (i - 1)*(j - 1)*Var(d) + (i + j - 2)*Cov(a1,d)     for i = 1,2,...,n and j = 1,2,...,n
;
;              where Cov(seq[i],seq[j]) is the covariance between the ith and jth elements of the sequence.
;              Again, the variance propagation that is performed is exact. The full covariance matrix is
;              returned via the output parameter "seq_var". In this case, the keyword ERROR_PROPAGATION
;              is ignored.
;                The module does not perform bad pixel mask propagation since it does not make sense for
;              a module with two relevant single-element input parameters "a1" and "d".
;
; Input Parameters:
;
;   a1 - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The first element of the arithmetic sequence.
;   a1_var - FLOAT/DOUBLE - The variance of the input parameter "a1". This parameter should be non-negative.
;                           If this input parameter does not satisfy the input requirements, then the
;                           variance is assumed to be zero. If the keyword ERROR_PROPAGATION is set, and
;                           the keyword COVARIANCE_MATRIX is not set, then this input parameter is assumed
;                           to represent the standard error as opposed to the variance.
;   d - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The difference between consecutive elements of the sequence.
;   d_var - FLOAT/DOUBLE - The variance of the input parameter "d". This parameter should be non-negative.
;                          If this input parameter does not satisfy the input requirements, then the
;                          variance is assumed to be zero. If the keyword ERROR_PROPAGATION is set, and
;                          the keyword COVARIANCE_MATRIX is not set, then this input parameter is assumed
;                          to represent the standard error as opposed to the variance.
;   a1_d_covar - FLOAT/DOUBLE - The covariance between the input parameters "a1" and "d". If this input
;                               parameter does not satisfy the input requirements, then the covariance is
;                               assumed to be zero.
;   n - INTEGER/LONG - The number of elements in the arithmetic sequence. This parameter must be positive.
;
; Output Parameters:
;
;   seq - DOUBLE VECTOR - A one-dimensional vector of length "n" elements that contains the arithmetic
;                         sequence that has been generated.
;   seq_var - DOUBLE VECTOR - A one-dimensional vector of length "n" elements that contains the variances
;                             corresponding to the arithmetic sequence. If the keyword ERROR_PROPAGATION
;                             is set, and the keyword COVARIANCE_MATRIX is not set, then the elements of
;                             this output parameter represent the standard errors corresponding to the
;                             arithmetic sequence. If the keyword COVARIANCE_MATRIX is set, then this
;                             output parameter is returned as a two-dimensional array of size "n" by "n"
;                             elements which represents the full covariance matrix for the elements of
;                             the arithmetic sequence. In this case, when "n" is "1", this output
;                             parameter is returned as a single-element vector since IDL treats a 1x1
;                             array as a single-element one-dimensional vector.
;   status - INTEGER - If the module successfully generated the arithmetic sequence, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword INTEGER_SEQUENCE is set (as "/INTEGER_SEQUENCE"), then the module will convert the
;   input parameters "a1" and "d" into LONG type integers, and it will use them to generate the output
;   arithmetic sequence "seq" as a sequence of numbers of LONG type.
;
;   If the keyword COVARIANCE_MATRIX is set (as "/COVARIANCE_MATRIX"), then the module will calculate
;   the full covariance matrix of size "n" by "n" elements for the arithmetic sequence and it will
;   return this covariance matrix via the output parameter "seq_var". In this case, if "n" is "1",
;   then "seq_var" is returned as a single-element vector since IDL treats a 1x1 array as a
;   single-element one-dimensional vector.
;
;   If the keyword ERROR_PROPAGATION is set (as "/ERROR_PROPAGATION"), then the module will perform
;   error propagation instead of variance propagation. In other words, the input parameters "a1_var"
;   and "d_var" are assumed to represent standard errors, and the output parameter "seq_var" is
;   returned with elements representing standard errors. This keyword is ignored if the keyword
;   COVARIANCE_MATRIX is set.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
seq_var = [0.0D]

;Generate the arithmetic sequence
generate_arithmetic_sequence, a1, d, n, seq, status, INTEGER_SEQUENCE = integer_sequence, NO_PAR_CHECK = no_par_check
if (status EQ 0) then return

;Check that "a1_var" is a non-negative scalar number of the correct number type
a1_var_use = 0.0D
if (test_fltdbl_scalar(a1_var) EQ 1) then begin
  if (a1_var GE 0.0) then a1_var_use = double(a1_var)
endif

;Check that "d_var" is a non-negative scalar number of the correct number type
d_var_use = 0.0D
if (test_fltdbl_scalar(d_var) EQ 1) then begin
  if (d_var GE 0.0) then d_var_use = double(d_var)
endif

;Check that "a1_d_covar" is a scalar number of the correct number type
if (test_fltdbl_scalar(a1_d_covar) EQ 1) then begin
  a1_d_covar_use = double(a1_d_covar)
endif else a1_d_covar_use = 0.0D

;If the keyword COVARIANCE_MATRIX is set
n_use = long(n)
if keyword_set(covariance_matrix) then begin

  ;Perform the variance and covariance propagation
  coeff_matrix = replicate(1.0D, 2L, n_use)
  coeff_matrix[1L, 0L] = dindgen(1L, n_use)
  seq_var = propagate_variance_for_general_linear_transformation([[a1_var_use, a1_d_covar_use], [a1_d_covar_use, d_var_use]], coeff_matrix, stat, /NO_PAR_CHECK)

;If the keyword COVARIANCE_MATRIX is not set
endif else begin

  ;Perform the variance propagation
  seq_var = propagate_variance_for_linear_combination_pairs(replicate(d_var_use, n_use), a1_var_use, a1_d_covar_use, dindgen(n_use), 1.0D, stat, $
                                                            ERROR_IN = error_propagation, ERROR_OUT = error_propagation, /NO_PAR_CHECK)
endelse

END
