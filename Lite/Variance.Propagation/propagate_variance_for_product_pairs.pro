FUNCTION propagate_variance_for_product_pairs, var_a, var_b, mean_a, mean_b, covar_ab, covar_a2b2, status, PRODUCT_MEAN = product_mean, ERROR_IN = error_in, $
                                               ERROR_OUT = error_out, BIVARIATE_NORMAL = bivariate_normal, NO_PAR_CHECK = no_par_check

; Description: Given the variances "var_a" and "var_b", and the expected values "mean_a" and "mean_b",
;              of two random variables A and B, respectively, and given the covariance "covar_ab" between
;              A and B, and the covariance "covar_a2b2" between A^2 and B^2, this function calculates and
;              returns the variance of the random variable X defined as the product of A and B:
;
;              X = A*B
;
;              The variance of X, denoted by Var(X), is calculated analytically via:
;
;              Var(X) = (E(B)^2)*Var(A) + (E(A)^2)*Var(B) + Var(A)*Var(B) - Cov(A,B)^2 - 2*E(A)*E(B)*Cov(A,B) + Cov(A^2,B^2)
;
;              where Var(A) and Var(B) are the variances of A and B, respectively, E(A) and E(B) are the
;              expected values of A and B, respectively, Cov(A,B) is the covariance between A and B, and
;              Cov(A^2,B^2) is the covariance between A^2 and B^2. Note that this formula for the
;              propagation of the variances is an exact formula whose result applies regardless of the
;              underlying probability density functions of the random variables that are being
;              transformed.
;                For the case that A and B are independent random variables, the variance of X reduces
;              to:
;
;              Var(X) = (E(B)^2)*Var(A) + (E(A)^2)*Var(B) + Var(A)*Var(B)
;
;              It is trivial to use this function for this case. Simply set the input parameters "covar_ab"
;              and "covar_a2b2" to "0.0". Again, this is an exact formula, as opposed to an approximation.
;                For the case that A and B are jointly distributed as a bivariate normal distribution,
;              the variance of X reduces to:
;
;              Var(X) = (E(B)^2)*Var(A) + (E(A)^2)*Var(B) + Var(A)*Var(B) + Cov(A,B)^2 + 2*E(A)*E(B)*Cov(A,B)
;
;              By setting the keyword BIVARIATE_NORMAL, the function will calculate Var(X) using this
;              formula instead, and it will ignore the input parameter "covar_a2b2". Again, this is an
;              exact formula, as opposed to an approximation. Note that in this case the distribution
;              of the random variable X is not a normal distribution and hence this formula cannot be
;              applied iteratively to calculate the variance of a product of three or more random
;              variables jointly distributed as a multivariate normal distribution.
;                This function also calculates the expected value of the random variable X formed as the
;              product of the random variables A and B via:
;
;              E(X) = E(A)*E(B) + Cov(A,B)
;
;              Since this quantity may be useful, the function returns E(X) via the keyword PRODUCT_MEAN.
;              Note that this formula for the propagation of the expected values is an exact formula
;              whose result applies regardless of the underlying probability density functions of the
;              random variables that are being transformed.
;                The parameter "var_a" may be supplied as a scalar, vector, or array with N elements.
;              The remaining parameters "var_b", "mean_a", "mean_b", "covar_ab", and "covar_a2b2" can
;              then be supplied as either scalars, vectors, or arrays each with 1 or N elements. The
;              function will calculate N output variances for N products of pairs of random variables.
;                The function provides the option of treating the input parameters "var_a" and "var_b"
;              as representing the standard deviations of the random variables A and B, respectively.
;              The variances of A and B are then calculated as the squares of "var_a" and "var_b" for
;              the purposes of this function.
;                The function also provides the option of returning the standard deviation of the
;              random variable X formed as the product of A and B. The standard deviation is calculated
;              as the square root of the variance of X.
;                I have optimised the performance of this function for the special values of the input
;              parameters "var_b", "mean_a", "mean_b", "covar_ab", and "covar_a2b2" that are most
;              commonly used. Specifically, this function is optimised for performance in the following
;              cases:
;
;              (a) Whenever "var_b" has a single element whose value is "0.0".
;              (b) Whenever "mean_a" has a single element whose value is "1.0", "0.0", or "-1.0".
;              (c) Whenever "mean_b" has a single element whose value is "0.0".
;              (d) Whenever "covar_ab" has a single element whose value is "0.0".
;              (e) Whenever "covar_a2b2" has a single element whose value is "0.0".
;              (f) Whenever both "var_b" and "mean_b" have single elements that satisfy
;                  "mean_b^2 + var_b = 1.0".
;
;              Further optimisations would make the code unnecessarily complicated and so have not been
;              implemented.
;
; Mathematical Derivations:
;
;     The derivation of the main formula for the calculation of the variance of a random variable X
;   formed as the product of two random variables A and B is provided here for convenience. The main
;   formula was originally derived by Goodman (1960, "On The Exact Variance Of Products", Journal of the
;   American Statistical Association, 55, 708). The formula for the special case that A and B are
;   jointly distributed as a bivariate normal distribution was derived by Bohrnstedt & Goldberger (1969,
;   "On The Exact Covariance Of Products Of Random Variables", Journal of the American Statistical
;   Association, 64, 1439).
;
;   Firstly, note the following definitions for the variance Var(A) of the random variable A, and for the
;   covariance Cov(A,B) of the random variables A and B:
;
;   Var(A) = E(A^2) - E(A)^2                                                                            (1)
;
;   Cov(A,B) = E(A*B) - E(A)*E(B)                                                                       (2)
;
;   where E(A) and E(B) are the expected values of A and B.
;
;   From equation (1):
;
;   Var(A*B) = E((A^2)*(B^2)) - E(A*B)^2                                                                (3)
;
;   Rearrange equation (2):
;
;   E(A*B) = E(A)*E(B) + Cov(A,B)                                                                       (4)
;
;   Therefore, we may also write:
;
;   E((A^2)*(B^2)) = E(A^2)*E(B^2) + Cov(A^2,B^2)                                                       (5)
;
;   Substitute equations (4) and (5) into equation (3):
;
;   Var(A*B) = E(A^2)*E(B^2) + Cov(A^2,B^2) - (E(A)*E(B) + Cov(A,B))^2
;            = E(A^2)*E(B^2) - (E(A)^2)*(E(B)^2) - Cov(A,B)^2 - 2*E(A)*E(B)*Cov(A,B) + Cov(A^2,B^2)     (6)
;
;   Note that from equation (1), we may derive the following:
;
;   (E(B)^2)*Var(A) = E(A^2)*(E(B)^2) - (E(A)^2)*(E(B)^2)                                               (7)
;   (E(A)^2)*Var(B) = (E(A)^2)*E(B^2) - (E(A)^2)*(E(B)^2)                                               (8)
;   Var(A)*Var(B) = (E(A^2) - E(A)^2)*(E(B^2) - E(B)^2)
;                 = E(A^2)*E(B^2) - E(A^2)*(E(B)^2) - (E(A)^2)*E(B^2) + (E(A)^2)*(E(B)^2)               (9)
;
;   Therefore, adding equations (7), (8), and (9):
;
;   (E(B)^2)*Var(A) + (E(A)^2)*Var(B) + Var(A)*Var(B) = E(A^2)*E(B^2) - (E(A)^2)*(E(B)^2)              (10)
;
;   Substitute equation (10) into equation (6) to get the main result:
;
;   Var(A*B) = (E(B)^2)*Var(A) + (E(A)^2)*Var(B) + Var(A)*Var(B) - Cov(A,B)^2 - 2*E(A)*E(B)*Cov(A,B) + Cov(A^2,B^2)
;
; Input Parameters:
;
;   var_a - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of variances of the first random
;                                              variable A. All elements of this parameter must be
;                                              non-negative.
;   var_b - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of variances of the second random
;                                              variable B. This parameter must have either a single
;                                              element or the same number of elements as "var_a". If
;                                              this parameter has a single element, then the parameter
;                                              value is adopted as the variance of the second random
;                                              variable B for all of the input elements in "var_a".
;                                              However, if this parameter has the same number of
;                                              elements as "var_a", then the parameter values are
;                                              paired up with the corresponding elements of "var_a".
;                                              All elements of this parameter must be non-negative.
;   mean_a - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of expected values of the first
;                                               random variable A. This parameter must have either a
;                                               single element or the same number of elements as
;                                               "var_a". If this parameter has a single element, then
;                                               the parameter value is adopted as the expected value
;                                               of the first random variable A for all of the input
;                                               elements in "var_a". However, if this parameter has
;                                               the same number of elements as "var_a", then the
;                                               parameter values are paired up with the corresponding
;                                               elements of "var_a".
;   mean_b - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of expected values of the second
;                                               random variable B. This parameter must have either a
;                                               single element or the same number of elements as
;                                               "var_a". If this parameter has a single element, then
;                                               the parameter value is adopted as the expected value
;                                               of the second random variable B for all of the input
;                                               elements in "var_a". However, if this parameter has
;                                               the same number of elements as "var_a", then the
;                                               parameter values are paired up with the corresponding
;                                               elements of "var_a".
;   covar_ab - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of covariances between the
;                                                 two random variables. This parameter must have
;                                                 either a single element or the same number of
;                                                 elements as "var_a". If this parameter has a single
;                                                 element, then the parameter value is adopted as the
;                                                 covariance between the two random variables for all
;                                                 of the input elements in "var_a". However, if this
;                                                 parameter has the same number of elements as
;                                                 "var_a", then the parameter values are paired up
;                                                 with the corresponding elements of "var_a".
;   covar_a2b2 - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of covariances between the
;                                                   squares of the two random variables. This
;                                                   parameter must have either a single element or
;                                                   the same number of elements as "var_a". If this
;                                                   parameter has a single element, then the parameter
;                                                   value is adopted as the covariance between the
;                                                   squares of the two random variables for all of
;                                                   the input elements in "var_a". However, if this
;                                                   parameter has the same number of elements as
;                                                   "var_a", then the parameter values are paired up
;                                                   with the corresponding elements of "var_a". If
;                                                   the keyword BIVARIATE_NORMAL is set, then this
;                                                   input parameter is ignored.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully calculated the output variances, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision variable, with the same dimensions as the input parameter
;   "var_a", where each element represents the variance of the random variable X formed as the product
;   of the random variables A and B.
;
; Keywords:
;
;   If the keyword PRODUCT_MEAN is set to a named variable, then, on return, this variable will contain
;   a SCALAR/VECTOR/ARRAY of DOUBLE precision numbers, with the same dimensions as the input parameter
;   "var_a", where each element represents the expected value of the random variable X formed as the
;   product of the random variables A and B.
;
;   If the keyword ERROR_IN is set (as "/ERROR_IN"), then the function will treat the input parameters
;   "var_a" and "var_b" as representing the standard deviations of the random variables A and B,
;   respectively. The variances of A and B are then calculated by the function as the squares of
;   "var_a" and "var_b".
;
;   If the keyword ERROR_OUT is set (as "/ERROR_OUT"), then each element of the return variable
;   represents the standard deviation, calculated as the square root of the variance, of the random
;   variable X formed as the product of the random variables A and B.
;
;   If the keyword BIVARIATE_NORMAL is set (as "/BIVARIATE_NORMAL"), then the function uses an
;   alternative formula to calculate the variance of X (see above). The alternative formula does not
;   require knowledge of the value of Cov(A^2,B^2) and consequently the input parameter "covar_a2b2"
;   is ignored.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform
;   parameter checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
product_mean = 0.0D
status = 0

;If parameter checking is not required
if keyword_set(no_par_check) then begin

  ;Determine the number of elements in each input parameter
  nvar_a = var_a.length
  nvar_b = var_b.length
  nmean_a = mean_a.length
  nmean_b = mean_b.length
  ncovar_ab = covar_ab.length

;If parameter checking is required
endif else begin

  ;Check that "var_a" contains non-negative numbers of the correct number type
  if (test_fltdbl(var_a) NE 1) then return, 0.0D
  if (array_equal(var_a GE 0.0, 1B) EQ 0B) then return, 0.0D
  nvar_a = var_a.length

  ;Check that "var_b" contains non-negative numbers of the correct number type, and check that it has
  ;either one element or the same number of elements as "var_a"
  if (test_fltdbl(var_b) NE 1) then return, 0.0D
  if (array_equal(var_b GE 0.0, 1B) EQ 0B) then return, 0.0D
  nvar_b = var_b.length
  if ((nvar_b NE 1L) AND (nvar_b NE nvar_a)) then return, 0.0D

  ;Check that "mean_a", "mean_b", and "covar_ab" are all of the correct number type, and check that
  ;they all have either one element or the same number of elements as "var_a"
  if (test_fltdbl(mean_a) NE 1) then return, 0.0D
  if (test_fltdbl(mean_b) NE 1) then return, 0.0D
  if (test_fltdbl(covar_ab) NE 1) then return, 0.0D
  nmean_a = mean_a.length
  nmean_b = mean_b.length
  ncovar_ab = covar_ab.length
  if ((nmean_a NE 1L) AND (nmean_a NE nvar_a)) then return, 0.0D
  if ((nmean_b NE 1L) AND (nmean_b NE nvar_a)) then return, 0.0D
  if ((ncovar_ab NE 1L) AND (ncovar_ab NE nvar_a)) then return, 0.0D
endelse

;If the keyword BIVARIATE_NORMAL is not set, then check that "covar_a2b2" is of the correct number
;type, and check that it has either one element or the same number of elements as "var_a"
if ~keyword_set(bivariate_normal) then begin
  if (test_fltdbl(covar_a2b2) NE 1) then return, 0.0D
  ncovar_a2b2 = covar_a2b2.length
  if (ncovar_a2b2 NE 1L) then begin
    if (ncovar_a2b2 NE nvar_a) then return, 0.0D
    covar_a2b2_use = double(reform(covar_a2b2, var_a.dim))
  endif else covar_a2b2_use = double(covar_a2b2[0])
endif

;Convert the input parameters
var_a_use = double(var_a)
if (nvar_b EQ 1L) then begin
  var_b_use = double(var_b[0])
endif else var_b_use = double(reform(var_b, var_a.dim))
if (nmean_a EQ 1L) then begin
  mean_a_use = double(mean_a[0])
endif else mean_a_use = double(reform(mean_a, var_a.dim))
if (nmean_b EQ 1L) then begin
  mean_b_use = double(mean_b[0])
endif else mean_b_use = double(reform(mean_b, var_a.dim))
if (ncovar_ab EQ 1L) then begin
  covar_ab_use = double(covar_ab[0])
endif else covar_ab_use = double(reform(covar_ab, var_a.dim))

;If the keyword ERROR_IN is set, then square the input parameters "var_a" and "var_b"
if keyword_set(error_in) then begin
  var_a_use = var_a_use*var_a_use
  var_b_use = var_b_use*var_b_use
endif

;Set "status" to "1"
status = 1

;If "var_a" has one element
if (nvar_a EQ 1L) then begin

  ;Set up the output parameter "product_mean"
  if (var_a.ndim EQ 0L) then begin
    product_mean = covar_ab_use
  endif else product_mean = [covar_ab_use]

  ;Calculate the expected value and variance of the random variable X formed as the product of the
  ;random variables A and B
  if (mean_a_use EQ 0.0D) then begin
    if (mean_b_use EQ 0.0D) then begin
      var_out = var_a_use*var_b_use
    endif else var_out = ((mean_b_use*mean_b_use) + var_b_use)*var_a_use
  endif else begin
    if (mean_b_use EQ 0.0D) then begin
      var_out =	((mean_a_use*mean_a_use) + var_a_use)*var_b_use
    endif else begin
      product_mean = product_mean + (mean_a_use*mean_b_use)
      var_out = (((mean_b_use*mean_b_use) + var_b_use)*var_a_use) + ((mean_a_use*mean_a_use)*var_b_use)
    endelse
  endelse
  if keyword_set(bivariate_normal) then begin
    if (covar_ab_use NE 0.0D) then begin
      if ((mean_a_use NE 0.0D) AND (mean_b_use NE 0.0D)) then begin
        var_out = var_out + (covar_ab_use*(covar_ab_use + (2.0D*mean_a_use*mean_b_use)))
      endif else var_out = var_out + (covar_ab_use*covar_ab_use)
    endif
  endif else begin
    if (covar_ab_use NE 0.0D) then begin
      if ((mean_a_use NE 0.0D) AND (mean_b_use NE 0.0D)) then begin
        var_out = var_out - (covar_ab_use*(covar_ab_use + (2.0D*mean_a_use*mean_b_use)))
      endif else var_out = var_out - (covar_ab_use*covar_ab_use)
    endif
    if (covar_a2b2_use NE 0.0D) then var_out = var_out + covar_a2b2_use
  endelse

  ;Return the output variance (or standard deviation)
  if keyword_set(error_out) then begin
    return, sqrt(var_out)
  endif else return, var_out
endif

;The rest of the code deals with the case when "var_a" has more than one element. Calculate the expected
;value of the random variable X formed as the product of the random variables A and B.
if (ncovar_ab EQ 1L) then begin
  if ((nmean_a EQ 1L) AND (nmean_b EQ 1L)) then begin
    if (covar_ab_use EQ 0.0D) then begin
      product_mean = replicate(mean_a_use*mean_b_use, var_a.dim)
    endif else product_mean = replicate((mean_a_use*mean_b_use) + covar_ab_use, var_a.dim)
  endif else begin
    if (covar_ab_use EQ 0.0D) then begin
      product_mean = mean_a_use*mean_b_use
    endif else product_mean = (mean_a_use*mean_b_use) + covar_ab_use
  endelse
endif else begin
  if (nmean_a EQ 1L) then begin
    if (mean_a_use EQ 0.0D) then begin
      product_mean = covar_ab_use
    endif else if (mean_a_use EQ 1.0D) then begin
      product_mean = covar_ab_use + mean_b_use
    endif else if (mean_a_use EQ -1.0D) then begin
      product_mean = covar_ab_use - mean_b_use
    endif else product_mean = (mean_a_use*mean_b_use) + covar_ab_use
  endif else product_mean = (mean_a_use*mean_b_use) + covar_ab_use
endelse

;Calculate the first and third terms for the variance of the random variable X formed as the product of
;the random variables A and B
if (nmean_b EQ 1L) then begin
  if (nvar_b EQ 1L) then begin
    tmp_fac = (mean_b_use*mean_b_use) + var_b_use
    if (tmp_fac NE 1.0D) then var_a_use = tmp_fac*temporary(var_a_use)
  endif else begin
    if (mean_b_use EQ 0.0D) then begin
      var_a_use = var_b_use*temporary(var_a_use)
    endif else var_a_use = ((mean_b_use*mean_b_use) + var_b_use)*temporary(var_a_use)
  endelse
endif else begin
  if (nvar_b EQ 1L) then begin
    if (var_b_use EQ 0.0D) then begin
      var_a_use = (mean_b_use*mean_b_use)*temporary(var_a_use)
    endif else var_a_use = ((mean_b_use*mean_b_use) + var_b_use)*temporary(var_a_use)
  endif else var_a_use = ((mean_b_use*mean_b_use) + var_b_use)*temporary(var_a_use)
endelse

;Calculate the second term for the variance of the random variable X formed as the product of the random
;variables A and B
if (nmean_a EQ 1L) then begin
  if ((mean_a_use NE 1.0D) AND (mean_a_use NE -1.0D)) then var_b_use = (mean_a_use*mean_a_use)*temporary(var_b_use)
endif else var_b_use = (mean_a_use*mean_a_use)*temporary(var_b_use)

;If the keyword BIVARIATE_NORMAL is not set
if ~keyword_set(bivariate_normal) then begin

  ;Add in the sixth term for the variance of the random variable X formed as the product of the random
  ;variables A and B
  if (ncovar_a2b2 EQ 1L) then begin
    if (covar_a2b2_use NE 0.0D) then var_a_use = temporary(var_a_use) + covar_a2b2_use
  endif else var_a_use = temporary(var_a_use) + covar_a2b2_use
endif

;If "covar_ab" has one element
if (ncovar_ab EQ 1L) then begin

  ;If the value of "covar_ab" is "0.0", then no more calculations are needed
  if (covar_ab_use EQ 0.0D) then begin

    ;Return the output variances (or standard deviations)
    if keyword_set(error_out) then begin
      return, sqrt(var_a_use + var_b_use)
    endif else return, var_a_use + var_b_use
  endif

  ;If the value of "covar_ab" is not "0.0", then calculate the fourth and fifth terms for the variance
  ;of the random variable X formed as the product of the random variables A and B
  if (nmean_a EQ 1L) then begin
    if (mean_a_use EQ 0.0D) then begin
      covar_ab_use = covar_ab_use*covar_ab_use
    endif else begin
      if (nmean_b EQ 1L) then begin
        if (mean_b_use EQ 0.0D) then begin
          covar_ab_use = covar_ab_use*covar_ab_use
        endif else covar_ab_use = covar_ab_use*(covar_ab_use + (2.0D*mean_a_use*mean_b_use))
      endif else covar_ab_use = (covar_ab_use*covar_ab_use) + ((2.0D*mean_a_use*covar_ab_use)*mean_b_use)
    endelse
  endif else begin
    if (nmean_b EQ 1L) then begin
      if (mean_b_use EQ 0.0D) then begin
        covar_ab_use = covar_ab_use*covar_ab_use
      endif else covar_ab_use = (covar_ab_use*covar_ab_use) + ((2.0D*mean_b_use*covar_ab_use)*mean_a_use)
    endif else covar_ab_use = (covar_ab_use*covar_ab_use) + (((2.0D*covar_ab_use)*mean_a_use)*mean_b_use)
  endelse

;If "covar_ab" has more than one element
endif else begin

  ;Calculate the fourth and fifth terms for the variance of the random variable X formed as the product
  ;of the random variables A and B
  if (nmean_a EQ 1L) then begin
    if (mean_a_use EQ 0.0D) then begin
      covar_ab_use = covar_ab_use*covar_ab_use
    endif else begin
      if (nmean_b EQ 1L) then begin
        if (mean_b_use EQ 0.0D) then begin
          covar_ab_use = covar_ab_use*covar_ab_use
        endif else covar_ab_use = covar_ab_use*(covar_ab_use + (2.0D*mean_a_use*mean_b_use))
      endif else covar_ab_use = covar_ab_use*(covar_ab_use + ((2.0D*mean_a_use)*mean_b_use))
    endelse
  endif else begin
    if (nmean_b EQ 1L) then begin
      if (mean_b_use EQ 0.0D) then begin
        covar_ab_use = covar_ab_use*covar_ab_use
      endif else covar_ab_use = covar_ab_use*(covar_ab_use + ((2.0D*mean_b_use)*mean_a_use))
    endif else covar_ab_use = covar_ab_use*(covar_ab_use + (2.0D*mean_a_use*mean_b_use))
  endelse
endelse

;Return the output variances (or standard deviations) with the correct dimensions
if keyword_set(bivariate_normal) then begin
  if keyword_set(error_out) then begin
    return, sqrt(var_a_use + (var_b_use + covar_ab_use))
  endif else return, var_a_use + (var_b_use + covar_ab_use)
endif else begin
  if keyword_set(error_out) then begin
    return, sqrt(var_a_use + (var_b_use - covar_ab_use))
  endif else return, var_a_use + (var_b_use - covar_ab_use)
endelse

END
