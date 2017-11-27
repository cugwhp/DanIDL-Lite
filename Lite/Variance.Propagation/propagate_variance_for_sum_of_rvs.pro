FUNCTION propagate_variance_for_sum_of_rvs, covar_matrix, sign_arr, status, ERROR_OUT = error_out, NO_PAR_CHECK = no_par_check

; Description: Given an NxN element covariance matrix "covar_matrix" for a set of N random variables X_i, and
;              given an associated set of N signs "sign_arr", this function calculates and returns the variance
;              of the random variable Y defined as the following sum of the X_i:
;
;                   N
;              Y = Sum s_i*X_i
;                  i=1
;
;              The coefficients s_i are the signs corresponding to the X_i, and each s_i can only have a value
;              of either "1" or "-1". The variance of Y, denoted by Var(Y), is calculated analytically using
;              the following formula:
;
;                       [  N           ]     [ N-1     [   N                    ]]
;              Var(Y) = [ Sum Var(X_i) ] + 2*[ Sum s_i*[  Sum  s_j*Cov(X_i,X_j) ]]
;                       [ i=1          ]     [ i=1     [ j=i+1                  ]]
;
;              where Var(X_i) is the variance of X_i, and Cov(X_i,X_j) is the covariance between X_i and X_j.
;              Note that this formula for the propagation of the variances is an exact formula whose result
;              applies regardless of the underlying probability density functions of the random variables that
;              are being transformed.
;                If the input covariance matrix "covar_matrix" is supplied as an N-element one-dimensional
;              vector, then the function assumes that the elements of this vector represent the diagonal
;              elements of the input covariance matrix and that the off-diagonal elements of the matrix are
;              zero. Furthermore, the input parameter "sign_arr" is ignored. This covers the case when the N
;              random variables X_i are independent.
;                This function does not make any checks as to whether the input matrix "covar_matrix" is a
;              valid covariance matrix. In other words, the function does not test whether or not
;              "covar_matrix" is symmetric positive-semidefinite.
;                The function provides the option of returning the standard deviation of the random variable
;              Y formed as the sum (as defined above) of the X_i. The standard deviation is calculated as the
;              square root of the variance of Y.
;
;              N.B: When processing data that include "bad values" that should be ignored, it is sufficient
;                   to set all of the entries in the covariance matrix corresponding to the "bad" random
;                   variable X_i (i.e. all of the entries in column i and row i) to zero.
;
; Input Parameters:
;
;   covar_matrix - FLOAT/DOUBLE VECTOR/ARRAY - A two-dimensional array of size N by N elements containing the
;                                              covariance matrix for the set of N random variables X_i. Note
;                                              that since IDL treats a 1 by 1 array as a single-element
;                                              one-dimensional vector, this function accepts such a
;                                              single-element one-dimensional vector to represent the case
;                                              when N is equal to "1". Alternatively, this parameter may be
;                                              supplied as an N-element one-dimensional vector, in which case
;                                              the function assumes that the elements of this vector represent
;                                              the diagonal elements of the covariance matrix for the set of N
;                                              random variables X_i and that the off-diagonal elements of the
;                                              covariance matrix are zero.
;   sign_arr - INTEGER/LONG/FLOAT/DOUBLE VECTOR/ARRAY - The signs s_i corresponding to the N random variables
;                                                       X_i in the formula for the random variable Y (as
;                                                       defined above). This parameter must have N elements,
;                                                       and each element must be equal to either "1" or "-1".
;                                                       If the input parameter "covar_matrix" is supplied as
;                                                       an N-element one-dimensional vector, then this input
;                                                       parameter is ignored.
;   status - ANY - A variable which will be used to contain the output status of the function on returning (see
;                  output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully calculated the output variance, then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision SCALAR number that represents the variance of the random variable Y
;   formed as the sum (as defined above) of the N random variables X_i.
;
; Keywords:
;
;   If the keyword ERROR_OUT is set (as "/ERROR_OUT"), then the return value represents the standard deviation,
;   calculated as the square root of the variance, of the random variable Y formed as the sum (as defined above)
;   of the X_i.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
size_covar = size(covar_matrix)
ndim_covar = size_covar[0]
if ~keyword_set(no_par_check) then begin

  ;Check that "covar_matrix" is of the correct number type, and that it is a one-dimensional vector, or a
  ;two-dimensional array
  if (test_fltdbl(covar_matrix) NE 1) then return, 0.0D
  if ((ndim_covar NE 1L) AND (ndim_covar NE 2L)) then return, 0.0D
endif

;If "covar_matrix" is a one-dimensional vector
if (ndim_covar EQ 1L) then begin

  ;Set "status" to "1"
  status = 1

  ;Calculate and return the output variance (or standard deviation)
  if keyword_set(error_out) then begin
    return, sqrt(total(double(covar_matrix), /DOUBLE))
  endif else return, total(double(covar_matrix), /DOUBLE)
endif

;If "covar_matrix" is a two-dimensional array, then check that it is a square array
n = size_covar[1]
if (size_covar[2] NE n) then return, 0.0D

;Check that "sign_arr" is of the correct number type
if (test_intlonfltdbl(sign_arr) NE 1) then return, 0.0D

;Check that the number of elements of "sign_arr" is equal to the size of the first dimension of "covar_matrix"
if (sign_arr.length NE n) then return, 0.0D

;Determine how many elements of "sign_arr" are equal to "1"
nsubs_pos = long(total(sign_arr EQ 1, /DOUBLE))

;If all of the elements of "sign_arr" are equal to "1"
if (nsubs_pos EQ n) then begin

  ;Set "status" to "1"
  status = 1

  ;Calculate and return the output variance (or standard deviation)
  if keyword_set(error_out) then begin
    return, sqrt(total(double(covar_matrix), /DOUBLE))
  endif else return, total(double(covar_matrix), /DOUBLE)
endif

;Determine how many elements of "sign_arr" are equal to "-1"
nsubs_neg = long(total(sign_arr EQ -1, /DOUBLE))

;If all of the elements of "sign_arr" are equal to "-1"
if (nsubs_neg EQ n) then begin

  ;Set "status" to "1"
  status = 1

  ;Calculate and return the output variance (or standard deviation)
  if keyword_set(error_out) then begin
    return, sqrt(total(double(covar_matrix), /DOUBLE))
  endif else return, total(double(covar_matrix), /DOUBLE)
endif

;Check that all of the elements of "sign_arr" are equal to either "1" or "-1"
if ((nsubs_pos + nsubs_neg) NE n) then return, 0.0D

;Calculate and return the output variance (or standard deviation). Note that although I could have employed
;the DanIDL module "calculate_matrix_product_at_b_a.pro" at this point in the code, I have decided not to
;do this in order to avoid redundant parameter testing and logic due to the optimisations already implemented
;above in this module for the specific problem that is tackled.
sign_arr_use = double(reform(sign_arr, n))
if keyword_set(error_out) then begin
  return, sqrt(calculate_dot_product_of_two_vectors(sign_arr_use ## double(covar_matrix), sign_arr_use, status, /NO_PAR_CHECK))
endif else return, calculate_dot_product_of_two_vectors(sign_arr_use ## double(covar_matrix), sign_arr_use, status, /NO_PAR_CHECK)

END
