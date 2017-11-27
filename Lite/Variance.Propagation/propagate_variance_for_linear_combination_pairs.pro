FUNCTION propagate_variance_for_linear_combination_pairs, var_a, var_b, covar_ab, fa, fb, status, ERROR_IN = error_in, ERROR_OUT = error_out, $
                                                          NO_PAR_CHECK = no_par_check

; Description: Given the variances "var_a" and "var_b" of two random variables A and B, respectively,
;              and given the covariance "covar_ab" between them, this function calculates and returns
;              the variance of the random variable X formed as a linear combination of A and B that is
;              parameterised by the scale factors "fa" and "fb". Mathematically, the function does the
;              following. For the random variable X defined by:
;
;              X = fa*A + fb*B
;
;              the variance of X, denoted by Var(X), is calculated analytically via:
;
;              Var(X) = (fa^2)*Var(A) + (fb^2)*Var(B) + 2*fa*fb*Cov(A,B)
;
;              where fa and fb are the scale factors, Var(A) and Var(B) are the variances of A and B,
;              respectively, and Cov(A,B) is the covariance between A and B. Note that this formula
;              for the propagation of the variances is an exact formula whose result applies regardless
;              of the underlying probability density functions of the random variables that are being
;              transformed.
;                For the case that A and B are independent random variables, the variance of X reduces
;              to:
;
;              Var(X) = (fa^2)*Var(A) + (fb^2)*Var(B)
;
;              It is trivial to use this function for this case. Simply set the input parameter "covar_ab"
;              to "0.0". Again, this is an exact formula, as opposed to an approximation.
;                The parameter "var_a" may be supplied as a scalar, vector, or array with N elements.
;              The remaining parameters "var_b", "covar_ab", "fa" and "fb" can then be supplied as
;              either scalars, vectors, or arrays each with 1 or N elements. The function will
;              calculate N output variances for N linear combinations of pairs of random variables.
;                The function provides the option of treating the input parameters "var_a" and "var_b"
;              as representing the standard deviations of the random variables A and B, respectively.
;              The variances of A and B are then calculated as the squares of "var_a" and "var_b" for
;              the purposes of this function.
;                The function also provides the option of returning the standard deviation of the
;              random variable X formed as a linear combination of A and B. The standard deviation is
;              calculated as the square root of the variance of X.
;                I have optimised the performance of this function for the special values of the input
;              parameters "covar_ab", "fa" and "fb" that are most commonly used. Specifically, this
;              function is optimised for performance in the following cases:
;
;              (a) Whenever "covar_ab" has a single element whose value is "0.0".
;              (b) Whenever "fb" has a single element whose value is "0.0", which corresponds to the
;                  linear combination X = fa*A. This includes an optimisation for when both of the
;                  keywords ERROR_IN and ERROR_OUT are set at the same time, which avoids squaring
;                  the input standard deviations to get the variances and then applying the square
;                  root to the modified variances to get the output standard deviations.
;              (c) Whenever "fa" has a single element whose value is "1.0" and "fb" has a single element
;                  whose value is "1.0", which corresponds to the linear combination X = A + B.
;              (d) Whenever "fa" has a single element whose value is "1.0" and "fb" has a single element
;                  whose value is "-1.0", which corresponds to the linear combination X = A - B.
;              (e) Whenever "fa" has any set of value(s) and "fb" has a single element whose value is
;                  "1.0", which corresponds to the linear combination X = fa*A + B.
;              (f) Whenever "fa" has any set of value(s) and "fb" has a single element whose value is
;                  "-1.0", which corresponds to the linear combination X = fa*A - B.
;
;              Further optimisations would make the code unnecessarily complicated and so have not been
;              implemented.
;
; Input Parameters:
;
;   var_a - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of variances of the first random
;                                              variable A. All elements of this parameter must be
;                                              non-negative.
;   var_b - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of	variances of the second random
;                                              variable B. This parameter must have either a single
;                                              element or the same number of elements as "var_a". If
;                                              this parameter has a single element, then the parameter
;                                              value is adopted as the variance of the second random
;                                              variable B for all of the input elements in "var_a".
;                                              However, if this parameter has the same number of
;                                              elements as "var_a", then the parameter values are
;                                              paired up with the corresponding elements of "var_a".
;                                              All elements of this parameter must be non-negative.
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
;   fa - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of scale factors applied to the
;                                           first random variable A during the linear combination of
;                                           the two random variables. This parameter must have either
;                                           a single element or the same number of elements as "var_a".
;                                           If this parameter has a single element, then the parameter
;                                           value is adopted as the scale factor applied to the first
;                                           random variable A for all of the input elements in "var_a".
;                                           However, if this parameter has the same number of elements
;                                           as "var_a", then the parameter values are paired up with
;                                           the corresponding elements of "var_a".
;   fb - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of scale factors applied to the
;                                           second random variable B during the linear combination of
;                                           the two random variables. This parameter must have either
;                                           a single element or the same number of elements as "var_a".
;                                           If this parameter has a single element, then the parameter
;                                           value is adopted as the scale factor applied to the	second
;                                           random variable B for all of the input elements in "var_a".
;                                           However, if this parameter has the same number of elements
;                                           as "var_a", then the parameter values are paired up	with
;                                           the corresponding elements of "var_a".
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
;   "var_a", where each element represents the variance of the random variable X formed as a linear
;   combination of the random variables A and B.
;
; Keywords:
;
;   If the keyword ERROR_IN is set (as "/ERROR_IN"), then the function will treat the input parameters
;   "var_a" and "var_b" as representing the standard deviations of the random variables A and B,
;   respectively. The variances of A and B are then calculated by the function as the squares of
;   "var_a" and "var_b".
;
;   If the keyword ERROR_OUT is set (as "/ERROR_OUT"), then each element of the return variable
;   represents the standard deviation, calculated as the square root of the variance, of the random
;   variable X formed as a linear combination of the random variables A and B.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform
;   parameter checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;If parameter checking is not required
if keyword_set(no_par_check) then begin

  ;Determine the number of elements in each input parameter
  nvar_a = var_a.length
  nvar_b = var_b.length
  ncovar_ab = covar_ab.length
  nfa = fa.length
  nfb = fb.length

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

  ;Check that "covar_ab", "fa" and "fb" are all of the correct number type, and check that they all have
  ;either one element or the same number of elements as "var_a"
  if (test_fltdbl(covar_ab) NE 1) then return, 0.0D
  if (test_fltdbl(fa) NE 1) then return, 0.0D
  if (test_fltdbl(fb) NE 1) then return, 0.0D
  ncovar_ab = covar_ab.length
  nfa = fa.length
  nfb = fb.length
  if ((ncovar_ab NE 1L) AND (ncovar_ab NE nvar_a)) then return, 0.0D
  if ((nfa NE 1L) AND (nfa NE nvar_a)) then return, 0.0D
  if ((nfb NE 1L) AND (nfb NE nvar_a)) then return, 0.0D
endelse

;Convert the input parameters
var_a_use = double(var_a)
if (nvar_b EQ 1L) then begin
  var_b_use = double(var_b[0])
endif else var_b_use = double(reform(var_b, var_a.dim))
if (ncovar_ab EQ 1L) then begin
  covar_ab_use = double(covar_ab[0])
endif else covar_ab_use = double(reform(covar_ab, var_a.dim))
if (nfa EQ 1L) then begin
  fa_use = double(fa[0])
endif else fa_use = double(reform(fa, var_a.dim))
if (nfb	EQ 1L) then begin
  fb_use = double(fb[0])
endif else fb_use = double(reform(fb, var_a.dim))

;Set "status" to "1"
status = 1

;If the keyword ERROR_IN is set
if keyword_set(error_in) then begin

  ;If the keyword ERROR_OUT is set, and "fb" has one element
  if (keyword_set(error_out) AND (nfb EQ 1L)) then begin

    ;If the value of "fb" is "0.0", then calculate and return the output standard deviation(s)
    if (fb_use EQ 0.0D) then return, abs(fa_use)*var_a_use
  endif

  ;Square the input parameters "var_a" and "var_b"
  var_a_use = var_a_use*var_a_use
  var_b_use = var_b_use*var_b_use
endif

;If "var_a" has one element
if (nvar_a EQ 1L) then begin

  ;Calculate the variance of the random variable X formed as a linear combination of the random variables
  ;A and B
  if (fb_use EQ 0.0D) then begin
    var_out = (fa_use*fa_use)*var_a_use
  endif else begin
    if (covar_ab_use EQ 0.0D) then begin
      if (fa_use EQ 1.0D) then begin
        if ((fb_use EQ 1.0D) OR (fb_use EQ -1.0D)) then begin
          var_out = var_a_use + var_b_use
        endif else var_out = var_a_use + ((fb_use*fb_use)*var_b_use)
      endif else begin
        if ((fb_use EQ 1.0D) OR (fb_use EQ -1.0D)) then begin
          var_out = ((fa_use*fa_use)*var_a_use) + var_b_use
        endif else var_out = ((fa_use*fa_use)*var_a_use) + ((fb_use*fb_use)*var_b_use)
      endelse
    endif else begin
      if (fa_use EQ 1.0D) then begin
        if (fb_use EQ 1.0D) then begin
          var_out = var_a_use + var_b_use + (2.0D*covar_ab_use)
        endif else if (fb_use EQ -1.0D) then begin
          var_out = var_a_use + var_b_use - (2.0D*covar_ab_use)
        endif else var_out = var_a_use + ((fb_use*fb_use)*var_b_use) + (2.0D*fb_use*covar_ab_use)
      endif else begin
        if (fb_use EQ 1.0D) then begin
          var_out = ((fa_use*fa_use)*var_a_use) + var_b_use + (2.0D*fa_use*covar_ab_use)
        endif else if (fb_use EQ -1.0D) then begin
          var_out = ((fa_use*fa_use)*var_a_use) + var_b_use - (2.0D*fa_use*covar_ab_use)
        endif else var_out = ((fa_use*fa_use)*var_a_use) + ((fb_use*fb_use)*var_b_use) + (2.0D*fa_use*fb_use*covar_ab_use)
      endelse
    endelse
  endelse

  ;Return the output variance (or standard deviation)
  if keyword_set(error_out) then begin
    return, sqrt(var_out)
  endif else return, var_out
endif

;The rest of the code deals with the case when "var_a" has more than one element. Calculate the first
;term for the variance of the random variable X formed as a linear combination of the random variables
;A and B.
if (nfa EQ 1L) then begin
  if ((fa_use NE 1.0D) AND (fa_use NE -1.0D)) then var_a_use = (fa_use*fa_use)*temporary(var_a_use)
endif else var_a_use = (fa_use*fa_use)*temporary(var_a_use)

;If "fb" has one element
if (nfb EQ 1L) then begin

  ;If the value of "fb" is "0.0", then no more calculations are needed
  if (fb_use EQ 0.0D) then begin

    ;Return the output variances (or standard deviations)
    if keyword_set(error_out) then begin
      return, sqrt(var_a_use)
    endif else return, var_a_use
  endif

  ;If the value of "fb" is not "0.0", then calculate the second term for the variance of the random
  ;variable X formed as a linear combination of the random variables A and B
  if ((fb_use NE 1.0D) AND (fb_use NE -1.0D)) then var_b_use = (fb_use*fb_use)*temporary(var_b_use)

;If "fb" has more than one element
endif else begin

  ;Calculate the second term for the variance of the random variable X formed as a linear combination
  ;of the random variables A and B
  var_b_use = (fb_use*fb_use)*temporary(var_b_use)
endelse

;If "covar_ab" has one element
if (ncovar_ab EQ 1L) then begin

  ;If the value of "covar_ab" is "0.0", then no more calculations are needed
  if (covar_ab_use EQ 0.0D) then begin

    ;Return the output variances (or standard deviations)
    if keyword_set(error_out) then begin
      return, sqrt(var_a_use + var_b_use)
    endif else return, var_a_use + var_b_use
  endif

  ;If the value of "covar_ab" is not "0.0", then calculate the third term for the variance of the random
  ;variable X formed as a linear combination of the random variables A and B
  if (nfa EQ 1L) then begin
    covar_ab_use = (2.0D*fa_use*covar_ab_use)*fb_use
  endif else covar_ab_use = ((2.0D*covar_ab_use)*fb_use)*fa_use

;If "covar_ab" has more than one element
endif else begin

  ;Calculate the third term for the variance of the random variable X formed as a linear combination
  ;of the random variables A and B
  if (nfa EQ 1L) then begin
    covar_ab_use = ((2.0D*fa_use)*fb_use)*temporary(covar_ab_use)
  endif else covar_ab_use = ((2.0D*fb_use)*fa_use)*temporary(covar_ab_use)
endelse

;Return the output variances (or standard deviations)
if keyword_set(error_out) then begin
  return, sqrt(var_a_use + (var_b_use + covar_ab_use))
endif else return, var_a_use + (var_b_use + covar_ab_use)

END
