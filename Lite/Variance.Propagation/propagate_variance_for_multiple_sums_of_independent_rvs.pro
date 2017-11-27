FUNCTION propagate_variance_for_multiple_sums_of_independent_rvs, var_arr, status, ERROR_IN = error_in, ERROR_OUT = error_out, NO_PAR_CHECK = no_par_check

; Description: For M sets of N independent random variables X_ij with variances "var_arr", this function
;              calculates and returns the variances of the random variables Y_j defined as the following
;              sums over i of the X_ij:
;
;                     N
;              Y_j = Sum s_i*X_ij
;                    i=1
;
;              The coefficients s_i are the signs corresponding to the X_ij, and each s_i can only have a
;              value of either "1" or "-1". The variance of Y_j, denoted by Var(Y_j), is calculated
;              analytically using the following formula:
;
;                          N
;              Var(Y_j) = Sum Var(X_ij)
;                         i=1
;
;              where Var(X_ij) is the variance of X_ij. Note that since the random variables X_ij for each
;              j are independent, the covariances have been ignored and the values of the signs s_i are
;              therefore irrelevant to the variance propagation. Also note that this formula for the
;              propagation of the variances is an exact formula whose result applies regardless of the
;              underlying probability density functions of the random variables that are being transformed.
;                The function provides the option of treating the input parameter "var_arr" as representing
;              the standard deviations of the random variables X_ij. The variances of the X_ij are then
;              calculated as the squares of the values in "var_arr" for the purposes of this function.
;                The function also provides the option of returning the standard deviations of the random
;              variables Y_j formed as the sums over i (as defined above) of the X_ij. The standard
;              deviations are calculated as the square roots of the variances of the Y_j.
;
;              N.B: When processing data that include "bad values" that should be ignored, it is sufficient
;                   to set the variance corresponding to the "bad" random variable X_ij to zero.
;
; Input Parameters:
;
;   var_arr - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array containing the M sets of variances
;                                                of N independent random variables. The first dimension
;                                                of "var_arr" should always be of size N. The remaining
;                                                dimensions of "var_arr" may be of any configuration such
;                                                that each sub-array "var_arr[i,*]" contains M elements.
;                                                If this parameter is supplied as a scalar number or a
;                                                single-element vector, then it is assumed that N = 1 and
;                                                M = 1. If this parameter is supplied as a vector with at
;                                                least two elements, then it is assumed that N is equal
;                                                to the length of the vector and that M = 1. All elements
;                                                of this parameter must be non-negative.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully calculated the output variances, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a SCALAR/VECTOR/ARRAY of DOUBLE precision numbers that represent the variances of
;   the M random variables Y_j formed as the sums over i (as defined above) of the N independent random
;   variables X_ij. More specifically, consider that the input parameter "var_arr" has dimensions NxPx...xZ
;   where each of the N arrays of dimensions Px...xZ has M elements. Then for each subscript j in the array
;   of dimensions Px...xZ, the function extracts the N variances of the random variables X_ij and calculates
;   the variance of the random variable Y_j formed as the sum over i (as defined above) of the X_ij.
;   Consequently, the return value of this function has dimensions Px...xZ matching the dimensions of "var_arr"
;   without the first dimension. In the special case that "var_arr" is a scalar number or a single-element
;   vector (i.e. N = 1 and M = 1), the return value of this function is also a scalar number or a
;   single-element vector, respectively. In the special case that "var_arr" is a vector with at least two
;   elements (i.e. N > 1 and M = 1), the return value of this function is a single-element vector.
;
; Keywords:
;
;   If the keyword ERROR_IN is set (as "/ERROR_IN"), then the function will treat the input parameter "var_arr"
;   as representing the standard deviations of the random variables X_ij. The variances of the X_ij are then
;   calculated by the function as the squares of the values in "var_arr".
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
if ~keyword_set(no_par_check) then begin

  ;Check that "var_arr" contains non-negative numbers of the correct number type
  if (test_fltdbl(var_arr) NE 1) then return, [0.0D]
  if (array_equal(var_arr GE 0.0, 1B) EQ 0B) then return, [0.0D]
endif
var_arr_use = double(var_arr)

;Set "status" to "1"
status = 1

;If "var_arr" has only one element
if (var_arr.length EQ 1L) then begin

  ;Calculate and return the output variance (or standard deviation)
  if keyword_set(error_in) then begin
    if keyword_set(error_out) then begin
      return, var_arr_use
    endif else return, var_arr_use*var_arr_use
  endif else begin
    if keyword_set(error_out) then begin
      return, sqrt(var_arr_use)
    endif else return, var_arr_use
  endelse
endif

;If the keyword ERROR_IN is set, then square the input parameter "var_arr"
if keyword_set(error_in) then var_arr_use = var_arr_use*var_arr_use

;If "var_arr" is a vector
if (var_arr.ndim EQ 1L) then begin

  ;Calculate and return the output variance (or standard deviation)
  if keyword_set(error_out) then begin
    return, [sqrt(total(var_arr_use, /DOUBLE))]
  endif else return, [total(var_arr_use, /DOUBLE)]
endif

;If "var_arr" is an array with at least two dimensions, then calculate and return the output variances (or
;standard deviations)
if keyword_set(error_out) then begin
  return, sqrt(total(var_arr_use, 1, /DOUBLE))
endif else return, total(var_arr_use, 1, /DOUBLE)

END
