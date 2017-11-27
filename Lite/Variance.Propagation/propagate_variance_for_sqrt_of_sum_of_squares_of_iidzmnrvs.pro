FUNCTION propagate_variance_for_sqrt_of_sum_of_squares_of_iidzmnrvs, var_x, nx, status, CHI_MEAN = chi_mean, ERROR_IN = error_in, ERROR_OUT = error_out, $
                                                                     NO_PAR_CHECK = no_par_check

; Description: Given the variance "var_x" of each of "nx" independent identically distributed zero-mean
;              normal random variables X_i (iidzmnrvs), this function calculates and returns the variance
;              of the random variable Y defined as the square root of the sum of the squares of the X_i:
;
;                  [  N        ]^(1/2)
;              Y = [ Sum X_i^2 ]
;                  [ i=1       ]
;
;              where N is the number of random variables X_i. The variance of Y, denoted by Var(Y), is
;              calculated analytically using the following formula:
;
;              Var(Y) = (N - 2*(gamma((N + 1)/2)/gamma(N/2))^2)*Var(X_0)
;
;              where gamma() is the Gamma function, and Var(X_0) is the variance of each of the N random
;              variables X_i. Note that this formula for the propagation of the variance is an exact
;              formula as opposed to an approximation, and that the resulting distribution of the random
;              variable Y is a (scaled) chi distribution with N degrees of freedom. A scaled chi
;              distribution with one degree of freedom is equivalent to a general half-normal distribution.
;              A scaled chi distribution with two degrees of freedom is equivalent to a general Rayleigh
;              distribution. A scaled chi distribution with three degrees of freedom is equivalent to a
;              general Maxwell distribution.
;                This function also calculates the expected value of the random variable Y formed as the
;              square root of the sum of the squares of the N random variables X_i via:
;
;              E(Y) = (gamma((N + 1)/2)/gamma(N/2))*((2*Var(X_0))^(1/2))
;
;              Since this quantity may be useful, the function returns E(Y) via the keyword CHI_MEAN. Note
;              that this formula for the propagation of the expected value is an exact formula.
;                The function provides the option of treating the input parameter "var_x" as representing
;              the standard deviation of each of the N random variables X_i. The variance of each of the
;              X_i is then calculated as the square of "var_x" for the purposes of this function.
;                The function also provides the option of returning the standard deviation of the random
;              variable Y formed as the square root of the sum of the squares of the X_i. The standard
;              deviation is calculated as the square root of the variance of Y.
;                I have optimised the performance of this function for the special values of the input
;              parameters "var_x" and "nx" that are most commonly used. Specifically, this function is
;              optimised for performance in the following cases:
;
;              (a) Whenever the value of "var_x" is "1.0".
;              (b) Whenever the value of "nx" is "1", "2", or "3".
;              (c) Whenever either, or both, of the keywords ERROR_IN and ERROR_OUT are set.
;
;              Further optimisations would make the code unnecessarily complicated and so have not been
;              implemented.
;
; Input parameters:
;
;   var_x - FLOAT/DOUBLE - The variance of each of the "nx" independent identically distributed zero-mean
;                          normal random variables X_i. This parameter must be non-negative.
;   nx - BYTE/INTEGER/LONG - The number N of random variables X_i. This parameter must be positive.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully calculated the output variance, then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision SCALAR number that represents the variance of the random variable
;   Y formed as the square root of the sum of the squares of the N random variables X_i.
;
; Keywords:
;
;   If the keyword CHI_MEAN is set to a named variable, then, on return, this variable will contain a DOUBLE
;   precision SCALAR number that represents the expected value of the random variable Y formed as the square
;   root of the sum of the squares of the N random variables X_i.
;
;   If the keyword ERROR_IN is set (as "/ERROR_IN"), then the function will treat the input parameter "var_x"
;   as representing the standard deviation of each of the N random variables X_i. The variance of each of the
;   X_i is then calculated by the function as the square of "var_x".
;
;   If the keyword ERROR_OUT is set (as "/ERROR_OUT"), then the return value represents the standard deviation,
;   calculated as the square root of the variance, of the random variable Y formed as the square root of the
;   sum of the squares of the N random variables X_i.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "var_x" is a non-negative number of the correct type
  if (test_fltdbl_scalar(var_x) NE 1) then return, 0.0D
  if (var_x LT 0.0) then return, 0.0D

  ;Check that "nx" is a positive number of the correct type
  if (test_bytintlon_scalar(nx) NE 1) then return, 0.0D
  if (nx LT 1B) then return, 0.0D
endif
var_x_use = double(var_x)

;Calculate the expected value and variance of a chi distribution with "nx" degrees of freedom
calculate_mean_and_variance_of_chi_distribution, nx, chi_mean, var_out, status, /NO_PAR_CHECK

;If the value of "var_x" is "1.0"
if (var_x_use EQ 1.0D) then begin

  ;Calculate and return the output variance (or standard deviation)
  if keyword_set(error_out) then begin
    return, sqrt(var_out)
  endif else return, var_out

;If the value of "var_x" is any other value
endif else begin

  ;Calculate and return the output expected value and variance (or standard deviation)
  if keyword_set(error_in) then begin
    chi_mean = chi_mean*var_x_use
    if keyword_set(error_out) then begin
      return, sqrt(var_out)*var_x_use
    endif else return, var_out*(var_x_use*var_x_use)
  endif else begin
    chi_mean = chi_mean*sqrt(var_x_use)
    if keyword_set(error_out) then begin
      return, sqrt(var_out*var_x_use)
    endif else return, var_out*var_x_use
  endelse
endelse

END
