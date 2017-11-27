PRO test_iteration_parameters, iteration_par, status, method, sigma, maxrej, maxrej_flag, permanent, tol, maxiter

; Description: This module tests that the parameter "iteration_par" is a single IDL structure containing the
;              tags required for the DanIDL iteration schema (see the DanIDL module "scale_pattern.pro"), and
;              that the tags have acceptable values. If the iteration parameter "iteration_par" passes all of
;              the tests in this module, then the iteration schema is valid and "status" is returned with a
;              value of "1". Furthermore, the values of the tags in "iteration_par" are interpreted by the
;              module and returned to the user via the remaining module output parameters. If the iteration
;              parameter "iteration_par" does not pass the tests in this module, then the iteration schema
;              is not valid, "status" is returned with a value of "0", and the remaining output parameters
;              are left undefined.
;
; Input Parameters:
;
;   iteration_par - ANY - The parameter to be tested whether or not it satisfies the properties required by
;                         the DanIDL iteration schema (see the DanIDL module "scale_pattern.pro").
;
; Output Parameters:
;
;   status - INTEGER - If the iteration parameter "iteration_par" successfully passed all of the tests in
;                      this module, then "status" is returned with a value of "1", otherwise "status" is
;                      returned with a value of "0".
;   method - STRING - The iteration method (see "scale_pattern.pro"). This parameter is only defined if
;                     "status" is set to "1".
;   sigma - DOUBLE - The sigma-clip rejection threshold (see "scale_pattern.pro"). This parameter is only
;                    defined if "status" is set to "1".
;   maxrej - LONG/DOUBLE - The maximum number ("maxrej_flag" set to "1") or fraction ("maxrej_flag" set to
;                          "2") of data values that can be rejected in any one iteration. This parameter is
;                          only defined if "maxrej_flag" is set to "1" or "2" and "status" is set to "1".
;   maxrej_flag - INTEGER - If the output parameter "maxrej" is a LONG type number that represents the
;                           maximum number of data values that can be rejected in any one iteration, then
;                           this parameter is set to "1". If the output parameter "maxrej" is a DOUBLE type
;                           number that represents the maximum fraction of data values that can be rejected
;                           in any one iteration, then this parameter is set to "2". Otherwise this parameter
;                           is set to "0". This parameter is only defined if "status" is set to "1".
;   permanent - INTEGER - If data values that are rejected in an iteration should remain rejected for all
;                         subsequent iterations, then this parameter is set to "1". However, if data values
;                         that are rejected in an iteration should be considered in subsequent iterations,
;                         then this parameter is set to "0". This parameter is only defined if "status" is
;                         set to "1".
;   tol - DOUBLE - The tolerance of the iterative fitting process (see "scale_pattern.pro"). This parameter
;                  is only defined if "status" is set to "1".
;   maxiter - LONG - The maximum number of iterations to be performed (see "scale_pattern.pro"). This
;                    parameter is only defined if "status" is set to "1".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Check that "iteration_par" is a single IDL structure that contains the required tags
if (test_structure_contains_tags(iteration_par, ['METHOD', 'SIGMA', 'MAXREJ', 'PERMANENT', 'TOL', 'MAXITER']) NE 1) then return
if (iteration_par.length NE 1L) then return

;Check that the "iteration_par" tag "method" is a scalar string with an acceptable value
if (test_str_scalar(iteration_par.method) NE 1) then return
if ((iteration_par.method NE 'abs_resid') AND (iteration_par.method NE 'norm_abs_resid')) then return

;Check that the "iteration_par" tags "sigma", "permanent", "tol" and "maxiter" are numbers of the correct type
if (test_fltdbl_scalar(iteration_par.sigma) NE 1) then return
if (test_intlon_scalar(iteration_par.permanent) NE 1) then return
if (test_fltdbl_scalar(iteration_par.tol) NE 1) then return
if (test_intlon_scalar(iteration_par.maxiter) NE 1) then return

;Check that the "iteration_par" tag "tol" has a value greater than or equal to "0.0", but less than "1.0"
if ((iteration_par.tol LT 0.0) OR (iteration_par.tol GE 1.0)) then return

;Extract the output parameter "method" from "iteration_par"
method = iteration_par.method

;Extract the output parameter "sigma" from "iteration_par"
sigma = double(iteration_par.sigma)

;Extract the output parameters "maxrej" and "maxrej_flag" from "iteration_par"
maxrej_flag = 0
if (test_intlon_scalar(iteration_par.maxrej) EQ 1) then begin
  if (iteration_par.maxrej GT 0) then begin
    maxrej = long(iteration_par.maxrej)
    maxrej_flag = 1
  endif
endif else if (test_fltdbl_scalar(iteration_par.maxrej) EQ 1) then begin
  if ((iteration_par.maxrej GT 0.0) AND (iteration_par.maxrej LE 1.0)) then begin
    maxrej = double(iteration_par.maxrej)
    maxrej_flag = 2
  endif
endif

;Extract the output parameter "permanent" from "iteration_par"
permanent = fix(iteration_par.permanent)
if (permanent NE 1) then permanent = 0

;Extract the output parameter "tol" from "iteration_par"
tol = double(iteration_par.tol)

;Extract the output parameter "maxiter" from "iteration_par"
if (iteration_par.maxiter GT 0) then begin
  maxiter = long(iteration_par.maxiter)
endif else maxiter = -1L

;Set "status" to "1"
status = 1

END
