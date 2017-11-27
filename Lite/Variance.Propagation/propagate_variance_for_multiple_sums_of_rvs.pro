FUNCTION propagate_variance_for_multiple_sums_of_rvs, covar_matrix_arr, sign_arr, status, ERROR_OUT = error_out, NO_PAR_CHECK = no_par_check

; Description: For M sets of N random variables X_ij with covariance matrices "covar_matrix_arr", and given an
;              associated set of N signs "sign_arr", this function calculates and returns the variances of the
;              random variables Y_j defined as the following sums over i of the X_ij:
;
;                     N
;              Y_j = Sum s_i*X_ij
;                    i=1
;
;              The coefficients s_i are the signs corresponding to the X_ij, and each s_i can only have a value
;              of either "1" or "-1". The variance of Y_j, denoted by Var(Y_j), is calculated analytically using
;              the following formula:
;
;                         [  N            ]     [ N-1     [   N                      ]]
;              Var(Y_j) = [ Sum Var(X_ij) ] + 2*[ Sum s_i*[  Sum  s_k*Cov(X_ij,X_kj) ]]
;                         [ i=1           ]     [ i=1     [ k=i+1                    ]]
;
;              where Var(X_ij) is the variance of X_ij, and Cov(X_ij,X_kj) is the covariance between X_ij and
;              X_kj. Note that this formula for the propagation of the variances is an exact formula whose
;              result applies regardless of the underlying probability density functions of the random variables
;              that are being transformed.
;                This function does not make any checks as to whether the input matrices in "covar_matrix_arr"
;              are valid covariance matrices. In other words, the function does not test whether or not the
;              matrices in "covar_matrix_arr" are symmetric positive-semidefinite.
;                The function provides the option of returning the standard deviations of the random variables
;              Y_j formed as the sums over i (as defined above) of the X_ij. The standard deviations are
;              calculated as the square roots of the variances of the Y_j.
;
;              N.B: When processing data that include "bad values" that should be ignored, it is sufficient to
;                   set all of the entries in the jth covariance matrix corresponding to the "bad" random
;                   variable X_ij (i.e. all of the entries in column i and row i) to zero.
;
; Input Parameters:
;
;   covar_matrix_arr - FLOAT/DOUBLE VECTOR/ARRAY - An array containing the M covariance matrices of N random
;                                                  variables X_ij. The first two dimensions of "covar_matrix_arr"
;                                                  should always be of size NxN. The remaining dimensions of
;                                                  "covar_matrix_arr" may be of any configuration such that each
;                                                  sub-array "covar_matrix_arr[i,k,*]" contains M elements. If
;                                                  this parameter is supplied as a single-element vector, then
;                                                  it is assumed that N = 1 and M = 1. If this parameter is
;                                                  supplied as a two-dimensional array of size N by N elements
;                                                  (with N > 1), then it is assumed that M = 1.
;   sign_arr - INTEGER/LONG/FLOAT/DOUBLE VECTOR/ARRAY - The signs s_i corresponding to the N random variables
;                                                       X_ij in the formula for the random variable Y_j (as
;                                                       defined above). This parameter must have N elements, and
;                                                       each element must be equal to either "1" or "-1". Note
;                                                       that this input parameter is ignored in the case that N
;                                                       is equal to "1".
;   status - ANY - A variable which will be used to contain the output status of the function on returning (see
;                  output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully calculated the output variances, then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a VECTOR/ARRAY of DOUBLE precision numbers that represent the variances of the M random
;   variables Y_j formed as the sums over i (as defined above) of the N random variables X_ij. More specifically,
;   consider that the input parameter "covar_matrix_arr" has dimensions NxNxPx...xZ where each of the N^2 arrays
;   of dimensions Px...xZ has M elements. Then for each subscript j in the array of dimensions Px...xZ, the
;   function extracts the NxN covariance matrix of the random variables X_ij and calculates the variance of the
;   random variable Y_j formed as the sum over i (as defined above) of the X_ij. Consequently, the return value
;   of this function has dimensions Px...xZ matching the dimensions of "covar_matrix_arr" without the first two
;   dimensions. In the special case that "covar_matrix_arr" is a single-element vector (i.e. N = 1 and M = 1)
;   or a two-dimensional array of size N by N elements (i.e. N > 1 and M = 1), the return value of this function
;   is a single-element vector.
;
; Keywords:
;
;   If the keyword ERROR_OUT is set (as "/ERROR_OUT"), then the return value represents the standard deviations,
;   calculated as the square roots of the variances, of the random variables Y_j formed as the sums over i (as
;   defined above) of the X_ij.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
size_covar = size(covar_matrix_arr)
ndim_covar = size_covar[0]
if ~keyword_set(no_par_check) then begin

  ;Check that "covar_matrix_arr" is of the correct number type
  if (test_fltdbl(covar_matrix_arr) NE 1) then return, [0.0D]

  ;Check that "covar_matrix_arr" is not a scalar number
  if (ndim_covar EQ 0L) then return, [0.0D]
endif

;If "covar_matrix_arr" is a one-dimensional vector
if (ndim_covar EQ 1L) then begin

  ;Check that "covar_matrix_arr" has a single element
  if (size_covar[1] NE 1L) then return, [0.0D]

  ;Set "status" to "1"
  status = 1

  ;Calculate and return the output variance (or standard deviation)
  if keyword_set(error_out) then begin
    return, sqrt(double(covar_matrix_arr))
  endif else return, double(covar_matrix_arr)
endif

;If "covar_matrix_arr" is a two-dimensional array, then calculate and return the output variance (or standard
;deviation)
if (ndim_covar EQ 2L) then return, [propagate_variance_for_sum_of_rvs(covar_matrix_arr, sign_arr, status, ERROR_OUT = error_out, /NO_PAR_CHECK)]

;Check that the first two dimensions of "covar_matrix_arr" constitute a square array
n = size_covar[1]
if (size_covar[2] NE n) then return, [0.0D]

;Extract the value of M from "covar_matrix_arr", and determine the dimensions of "covar_matrix_arr" without the
;first two dimensions
n2 = n*n
m = covar_matrix_arr.length/n2
dim_out = size_covar[3L:ndim_covar]

;If the first two dimensions of "covar_matrix_arr" are both of size "1"
if (n EQ 1L) then begin

  ;Set "status" to "1"
  status = 1

  ;Calculate and return the output variances (or standard deviations)
  if keyword_set(error_out) then begin
    return, sqrt(double(reform(covar_matrix_arr, dim_out)))
  endif else return, double(reform(covar_matrix_arr, dim_out))
endif

;Check that "sign_arr" is of the correct number type
if (test_intlonfltdbl(sign_arr) NE 1) then return, [0.0D]

;Check that the number of elements of "sign_arr" is equal to the size of the first dimension of "covar_matrix_arr"
if (sign_arr.length NE n) then return, [0.0D]

;Determine how many elements of "sign_arr" are equal to "1"
nsubs_pos = long(total(sign_arr EQ 1, /DOUBLE))

;If all of the elements of "sign_arr" are equal to "1"
if (nsubs_pos EQ n) then begin

  ;Set "status" to "1"
  status = 1

  ;Calculate and return the output variances (or standard deviations)
  if keyword_set(error_out) then begin
    return, sqrt(total(double(reform(covar_matrix_arr, [n2, dim_out])), 1, /DOUBLE))
  endif else return, total(double(reform(covar_matrix_arr, [n2, dim_out])), 1, /DOUBLE)
endif

;Determine how many elements of "sign_arr" are equal to "-1"
nsubs_neg = long(total(sign_arr EQ -1, /DOUBLE))

;If all of the elements of "sign_arr" are equal to "-1"
if (nsubs_neg EQ n) then begin

  ;Set "status" to "1"
  status = 1

  ;Calculate and return the output variance (or standard deviation)
  if keyword_set(error_out) then begin
    return, sqrt(total(double(reform(covar_matrix_arr, [n2, dim_out])), 1, /DOUBLE))
  endif else return, total(double(reform(covar_matrix_arr, [n2, dim_out])), 1, /DOUBLE)
endif

;Check that all of the elements of "sign_arr" are equal to either "1" or "-1"
if ((nsubs_pos + nsubs_neg) NE n) then return, [0.0D]

;Convert the input parameters, adjusting their dimensions as necessary
covar_matrix_arr_use = double(reform(covar_matrix_arr, n, n, m))
sign_arr_use = double(reform(sign_arr, n))

;Calculate the variances of the random variables Y_j formed as the sums over i (as defined above) of the random
;variables X_ij. Note that although I could have employed the DanIDL module "calculate_matrix_product_at_b_a.pro"
;at this point in the code, I have decided not to do this in order to avoid redundant parameter testing and logic
;due to the optimisations already implemented above in this module for the specific problem that is tackled.
var_out = dblarr(m, /NOZERO)
for j = 0L,(m - 1L) do var_out[j] = calculate_dot_product_of_two_vectors(sign_arr_use ## covar_matrix_arr_use[*,*,j], sign_arr_use, stat, /NO_PAR_CHECK)

;Set "status" to "1"
status = 1

;Return the output variances (or standard deviations)
if keyword_set(error_out) then begin
  return, reform(sqrt(var_out), dim_out, /OVERWRITE)
endif else return, reform(var_out, dim_out, /OVERWRITE)

END
