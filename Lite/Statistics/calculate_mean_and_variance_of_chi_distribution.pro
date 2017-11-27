PRO calculate_mean_and_variance_of_chi_distribution, ndof, mean, var, status, NO_PAR_CHECK = no_par_check

; Description: This module calculates the means "mean" and variances "var" for a set of chi distributions
;              with degrees of freedom "ndof". The input parameter "ndof" may be supplied as a scalar,
;              vector, or array.
;                Consider N random variables X_i each following a normal distribution with mean mu_i and
;              sigma sig_i. Then the random variable Y formed as:
;
;                  [  N                         ]^(1/2)
;              Y = [ Sum ((X_i - mu_i)/sig_i)^2 ]
;                  [ i=1                        ]
;
;              follows a chi distribution with N degrees of freedom. A chi distribution with one degree of
;              freedom is equivalent to a standard half-normal distribution. A chi distribution with two
;              degrees of freedom is equivalent to a standard Rayleigh distribution. A chi distribution
;              with three degrees of freedom is equivalent to a standard Maxwell distribution.
;
; Input Parameters:
;
;   ndof - BYTE/INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array containing the degrees of freedom
;                                                  of a set of chi distributions. All elements of this
;                                                  parameter must be positive.
;
; Output Parameters:
;
;   mean - DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of mean values for the set of chi
;                                       distributions with degrees of freedom "ndof". This output parameter
;                                       has the same dimensions as the input parameter "ndof".
;   var - DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of variances for the set of chi distributions
;                                      with degrees of freedom "ndof". This output parameter has the same
;                                      dimensions as the input parameter "ndof".
;   status - INTEGER - If the module successfully calculated the means and variances of the set of chi
;                      distributions, then "status" is returned with a value of "1", otherwise it is
;                      returned with a value of "0".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameter, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
mean = 0.0D
var = 0.0D
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "ndof" contains positive numbers of the correct number type
  if (test_bytintlon(ndof) NE 1) then return
  if (array_equal(ndof GT 0B, 1B) EQ 0B) then return
endif
ndof_use = double(ndof)

;If "ndof" has one element
if (ndof.length EQ 1L) then begin

  ;If the value of "ndof" is "1.0"
  if (ndof_use[0] EQ 1.0D) then begin

    ;Calculate the mean and variance of a chi distribution with one degree of freedom (i.e. a standard
    ;half-normal distribution)
    if (ndof.ndim EQ 0L) then begin
      mean = 2.0D/get_dbl_pi()
    endif else mean = [2.0D/get_dbl_pi()]
    var = 1.0D - mean
    mean = sqrt(mean)

    ;Set "status" to "1" and return
    status = 1
    return

  ;If the value of "ndof" is "2.0"
  endif else if (ndof_use[0] EQ 2.0D) then begin

    ;Calculate the mean and variance of a chi distribution with two degrees of freedom (i.e. a standard
    ;Rayleigh distribution)
    if (ndof.ndim EQ 0L) then begin
      mean = get_dbl_pi()/2.0D
    endif else mean = [get_dbl_pi()/2.0D]
    var = 2.0D - mean
    mean = sqrt(mean)

    ;Set "status" to "1" and return
    status = 1
    return

  ;If the value of "ndof" is "3.0"
  endif else if (ndof_use[0] EQ 3.0D) then begin

    ;Calculate the mean and variance of a chi distribution with three degrees of freedom (i.e. a standard
    ;Maxwell distribution)
    if (ndof.ndim EQ 0L) then begin
      mean = 8.0D/get_dbl_pi()
    endif else mean = [8.0D/get_dbl_pi()]
    var = 3.0D - mean
    mean = sqrt(mean)

    ;Set "status" to "1" and return
    status = 1
    return
  endif
endif

;The rest of the code deals with the non-special cases for "ndof". Calculate the means and variances for
;the set of chi distributions with degrees of freedom "ndof".
half_ndof = 0.5D*ndof_use
mean = sqrt(2.0D)*(gamma(half_ndof + 0.5D)/gamma(half_ndof))
var = ndof_use - (mean*mean)

;Set "status" to "1"
status = 1

END
