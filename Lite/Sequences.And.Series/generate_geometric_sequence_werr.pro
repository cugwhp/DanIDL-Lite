PRO generate_geometric_sequence_werr, a1, a1_var, r, r_var, a1_r_covar, n, seq, seq_var, status, INTEGER_SEQUENCE = integer_sequence, $
                                      COVARIANCE_MATRIX = covariance_matrix, ERROR_PROPAGATION = error_propagation, NO_PAR_CHECK = no_par_check

; Description: This module generates a geometric sequence of "n" elements with first element "a1" and a
;              ratio "r" between consecutive elements. The sequence is returned as the one-dimensional
;              vector "seq". Mathematically, the geometric sequence is defined as:
;
;              seq[i] = a1 * r^(i - 1)                for i = 1,2,...,n
;
;                By setting the keyword INTEGER_SEQUENCE, the module will convert the input parameters
;              "a1" and "r" into LONG type integers, and it will use them to generate the output
;              geometric sequence "seq" as a sequence of numbers of LONG type.
;                The module also performs propagation of the variances "a1_var" and "r_var", and the
;              covariance "a1_r_covar", associated with the input parameters "a1" and "r", respectively.
;              The module employs the following equation:
;
;              Var(seq[i]) = (r^(2*(i - 1)))*Var(a1) + (a1^2)*((i - 1)^2)*(r^(2*(i - 2)))*Var(r)
;                            + 2*a1*(i - 1)*(r^(2*i - 3))*Cov(a1,r)                                 for i = 1,2,...,n
;
;              where Var(seq[i]), Var(a1) and Var(r) are the variances of seq[i], a1 and r, respectively,
;              and Cov(a1,r) is the covariance between a1 and r. The variance propagation that is
;              performed is approximate (the formula is derived via linearisation by first-order Taylor
;              series expansion). The variances corresponding to the geometric sequence "seq" are
;              returned via the output parameter "seq_var". The module provides the option of performing
;              error propagation instead of variance propagation via the use of the keyword
;              ERROR_PROPAGATION.
;                By setting the keyword COVARIANCE_MATRIX, the module will calculate the full covariance
;              matrix of size "n" by "n" elements for the geometric sequence by employing the following
;              equation:
;
;              Cov(seq[i],seq[j]) = (r^(i + j - 2))*Var(a1) + (a1^2)*(i - 1)*(j - 1)*(r^(i + j - 4))*Var(r)
;                                   + a1*(i + j - 2)*(r^(i + j - 3))*Cov(a1,r)                      for i = 1,2,...,n and j = 1,2,...,n
;
;              where Cov(seq[i],seq[j]) is the covariance between the ith and jth elements of the
;              sequence. Again, the variance propagation that is performed is approximate. The full
;              covariance matrix is returned via the output parameter "seq_var". In this case, the
;              keyword ERROR_PROPAGATION is ignored.
;                The module does not perform bad pixel mask propagation since it does not make sense
;              for a module with two relevant single-element input parameters "a1" and "r".
;
; Input Parameters:
;
;   a1 - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The first element of the geometric sequence.
;   a1_var - FLOAT/DOUBLE - The variance of the input parameter "a1". This parameter should be
;                           non-negative. If this input parameter does not satisfy the input requirements,
;                           then the variance is assumed to be zero. If the keyword ERROR_PROPAGATION is
;                           set, and the keyword COVARIANCE_MATRIX is not set, then this input parameter
;                           is assumed to represent the standard error as opposed to the variance.
;   r - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The ratio between consecutive elements of the sequence.
;   r_var - FLOAT/DOUBLE - The variance of the input parameter "r". This parameter should be non-negative.
;                          If this input parameter does not satisfy the input requirements, then the
;                          variance is assumed to be zero. If the keyword ERROR_PROPAGATION is set, and
;                          the keyword COVARIANCE_MATRIX is not set, then this input parameter is assumed
;                          to represent the standard error as opposed to the variance.
;   a1_r_covar - FLOAT/DOUBLE - The covariance between the input parameters "a1" and "r". If this input
;                               parameter does not satisfy the input requirements, then the covariance
;                               is assumed to be zero.
;   n - INTEGER/LONG - The number of elements in the geometric sequence. This parameter must be positive.
;
; Output Parameters:
;
;   seq - DOUBLE VECTOR - A one-dimensional vector of length "n" elements that contains the geometric
;                         sequence that has been generated.
;   seq_var - DOUBLE VECTOR - A one-dimensional vector of length "n" elements that contains the variances
;                             corresponding to the geometric sequence. If the keyword ERROR_PROPAGATION
;                             is set, and the keyword COVARIANCE_MATRIX is not set, then the elements of
;                             this output parameter represent the standard errors corresponding to the
;                             geometric sequence. If the keyword COVARIANCE_MATRIX is set, then this
;                             output parameter is returned as a two-dimensional array of size "n" by "n"
;                             elements which represents the full covariance matrix for the elements of
;                             the geometric sequence. In this case, when "n" is "1", this output
;                             parameter is returned as a single-element vector since IDL treats a 1x1
;                             array as a single-element one-dimensional vector.
;   status - INTEGER - If the module successfully generated the geometric sequence, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword INTEGER_SEQUENCE is set (as "/INTEGER_SEQUENCE"), then the module will convert the
;   input parameters "a1" and "r" into LONG type integers, and it will use them to generate the output
;   geometric sequence "seq" as a sequence of numbers of LONG type.
;
;   If the keyword COVARIANCE_MATRIX is set (as "/COVARIANCE_MATRIX"), then the module will calculate
;   the full covariance matrix of size "n" by "n" elements for the geometric sequence and it will
;   return this covariance matrix via the output parameter "seq_var". In this case, if "n" is "1",
;   then "seq_var" is returned as a single-element vector since IDL treats a 1x1 array as a
;   single-element one-dimensional vector.
;
;   If the keyword ERROR_PROPAGATION is set (as "/ERROR_PROPAGATION"), then the module will perform
;   error propagation instead of variance propagation. In other words, the input parameters "a1_var"
;   and "r_var" are assumed to represent standard errors, and the output parameter "seq_var" is
;   returned with elements representing standard errors. This keyword is ignored if the keyword
;   COVARIANCE_MATRIX is set.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform
;   parameter checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
seq_var = [0.0D]

;Generate the geometric sequence
generate_geometric_sequence, a1, r, n, seq, status, INTEGER_SEQUENCE = integer_sequence, NO_PAR_CHECK = no_par_check
if (status EQ 0) then return

;Check that "a1_var" is a non-negative scalar number of the correct number type
a1_var_use = 0.0D
if (test_fltdbl_scalar(a1_var) EQ 1) then begin
  if (a1_var GE 0.0) then a1_var_use = double(a1_var)
endif

;Check that "r_var" is a non-negative scalar number of the correct number type
r_var_use = 0.0D
if (test_fltdbl_scalar(r_var) EQ 1) then begin
  if (r_var GE 0.0) then r_var_use = double(r_var)
endif

;Check that "a1_r_covar" is a scalar number of the correct number type
if (test_fltdbl_scalar(a1_r_covar) EQ 1) then begin
  a1_r_covar_use = double(a1_r_covar)
endif else a1_r_covar_use = 0.0D

;If the keyword COVARIANCE_MATRIX is set
a1_use = double(a1)
r_use = double(r)
n_use = long(n)
if keyword_set(covariance_matrix) then begin

  ;Perform the variance and covariance propagation
  if (r_use EQ 0.0D) then begin
    coeff_matrix = dblarr(2L, n_use)
    coeff_matrix[0L, 0L] = 1.0D
    if (n_use GT 1L) then coeff_matrix[1L, 1L] = a1_use
  endif else begin
    coeff_matrix = dblarr(2L, n_use, /NOZERO)
    generate_geometric_sequence, 1.0D, r_use, n_use, tmp_vec, stat, /NO_PAR_CHECK
    tmp_vec = reform(tmp_vec, 1L, n_use, /OVERWRITE)
    coeff_matrix[0L, 0L] = tmp_vec
    coeff_matrix[1L, 0L] = (a1_use/r_use)*dindgen(1L, n_use)*tmp_vec
  endelse
  seq_var = propagate_variance_for_general_linear_transformation([[a1_var_use, a1_r_covar_use], [a1_r_covar_use, r_var_use]], coeff_matrix, stat, /NO_PAR_CHECK)

;If the keyword COVARIANCE_MATRIX is not set
endif else begin

  ;If the keyword ERROR_PROPAGATION is set, then square the input parameters "a1_var" and "r_var"
  if keyword_set(error_propagation) then begin
    a1_var_use = a1_var_use*a1_var_use
    r_var_use = r_var_use*r_var_use
  endif

  ;Perform the variance propagation
  if (r_use EQ 0.0D) then begin
    seq_var = dblarr(n_use)
    seq_var[0L] = a1_var_use
    if (n_use GT 1L) then seq_var[1L] = (a1_use*a1_use)*r_var_use
  endif else begin
    generate_geometric_sequence, 1.0D, r_use*r_use, n_use, seq_var, stat, /NO_PAR_CHECK
    tmp_vec1 = (a1_use/r_use)*dindgen(n_use)
    tmp_vec2 = 2.0D*a1_r_covar_use
    if (r_var_use NE 0.0D) then tmp_vec2 = tmp_vec2 + tmp_vec1*r_var_use
    tmp_vec2 = tmp_vec1*temporary(tmp_vec2)
    if (a1_var_use NE 0.0D) then tmp_vec2 = temporary(tmp_vec2) + a1_var_use
    seq_var = tmp_vec2*temporary(seq_var)
  endelse

  ;If the keyword ERROR_PROPAGATION is set, then convert the output variances to standard errors
  if keyword_set(error_propagation) then seq_var = sqrt(temporary(seq_var))
endelse

END
