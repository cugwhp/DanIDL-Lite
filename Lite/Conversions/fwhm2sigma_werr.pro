FUNCTION fwhm2sigma_werr, fwhm, fwhm_var, sigma_var, status, UNIT_CONVERSION = unit_conversion, ERROR_PROPAGATION = error_propagation, $
                          NO_PAR_CHECK = no_par_check

; Description: This function calculates a set of equivalent Gaussian sigma values from an input set of
;              Gaussian FWHM values "fwhm" with arbitrary units. Note that this function is not a unit
;              conversion module. The units of the output Gaussian sigma values (e.g. pixels, metres, etc.)
;              are the same as the units of the input Gaussian FWHM values. The input parameter "fwhm" may
;              be a scalar, vector, or array.
;                The function provides the alternative option of performing unit conversion via the use of
;              the keyword UNIT_CONVERSION. In this case, the function converts input values "fwhm" in
;              units of Gaussian FWHMs to output values in units of Gaussian sigmas.
;                The function also performs propagation of the variances "fwhm_var" associated with the
;              input parameter "fwhm". The variance propagation that is performed is exact. The variances
;              corresponding to the output values are returned via the output parameter "sigma_var". The
;              function provides the option of performing error propagation instead of variance
;              propagation via the use of the keyword ERROR_PROPAGATION.
;                The function does not perform bad pixel mask propagation since the input bad pixel/data
;              mask is unchanged by the operations performed on the input data "fwhm".
;
; Input Parameters:
;
;   fwhm - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of
;                                                               Gaussian FWHM values in arbitrary units.
;                                                               If the keyword UNIT_CONVERSION is set,
;                                                               then the elements of this input parameter
;                                                               are assumed to be values in units of
;                                                               Gaussian FWHMs.
;   fwhm_var - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of non-negative numbers, with the
;                                                 same number of elements as "fwhm", where the elements
;                                                 represent the variances associated with "fwhm". If this
;                                                 input parameter does not satisfy the input requirements,
;                                                 then all of the variances are assumed to be zero. If the
;                                                 keyword ERROR_PROPAGATION is set, then the elements of
;                                                 this input parameter are assumed to represent standard
;                                                 errors as opposed to variances.
;   sigma_var - ANY - A variable which will be used to contain the variances corresponding to the output
;                     values on returning (see output parameters below).
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   sigma_var - DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array, with the same dimensions as the input
;                                            parameter "fwhm", where the elements represent the variances
;                                            corresponding to the Gaussian sigma values. If the keyword
;                                            UNIT_CONVERSION is set, then the elements of this output
;                                            parameter represent the variances corresponding to the
;                                            output values in units of Gaussian sigmas. If the keyword
;                                            ERROR_PROPAGATION is set, then the elements of this output
;                                            parameter represent standard errors as opposed to variances.
;   status - INTEGER - If the function successfully processed the input values(s), then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision variable, with the same units and dimensions as the input
;   parameter "fwhm", where each element represents the Gaussian sigma value equivalent to the
;   corresponding Gaussian FWHM value in "fwhm". If the keyword UNIT_CONVERSION is set, then the function
;   returns a DOUBLE precision variable, with the same dimensions as the input parameter "fwhm", where
;   each element is the result of converting the corresponding element in "fwhm" from units of Gaussian
;   FWHMs to units of Gaussian sigmas.
;
; Keywords:
;
;   If the keyword UNIT_CONVERSION is set (as "/UNIT_CONVERSION"), then the function assumes that the
;   input values "fwhm" are in units of Gaussian FWHMs and it converts them to values in units of
;   Gaussian sigmas.
;
;   If the keyword ERROR_PROPAGATION is set (as "/ERROR_PROPAGATION"), then the function will perform
;   error propagation instead of variance propagation. In other words, the elements of the input
;   parameter "fwhm_var" are assumed to represent standard errors, and the output parameter "sigma_var"
;   is returned with elements representing standard errors.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform
;   parameter checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
sigma_var = 0.0D

;Calculate the equivalent Gaussian sigma values from the input Gaussian FWHM values, or perform the unit
;conversion from units of Gaussian FWHMs to units of Gaussian sigmas
sigma = fwhm2sigma(fwhm, status, UNIT_CONVERSION = unit_conversion, NO_PAR_CHECK = no_par_check)
if (status EQ 0) then return, sigma

;Check that "fwhm_var" is a scalar/vector/array of non-negative numbers of the correct number type, and
;that it has the same number of elements as "fwhm"
fwhm_var_tag = 0
if (test_fltdbl(fwhm_var) EQ 1) then begin
  if (fwhm_var.length EQ fwhm.length) then fwhm_var_tag = fix(array_equal(fwhm_var GE 0.0, 1B))
endif

;Perform the variance propagation
if (fwhm_var_tag EQ 1) then begin
  fac = alog(256.0D)
  if keyword_set(error_propagation) then begin
    if keyword_set(unit_conversion) then begin
      sigma_var = sqrt(fac)*fwhm_var
    endif else sigma_var = (1.0D/sqrt(fac))*fwhm_var
  endif else begin
    if keyword_set(unit_conversion) then begin
      sigma_var = fac*fwhm_var
    endif else sigma_var = (1.0D/fac)*fwhm_var
  endelse
  if (fwhm.ndim EQ 0L) then begin
    sigma_var = sigma_var[0]
  endif else sigma_var = reform(sigma_var, fwhm.dim, /OVERWRITE)
endif else begin
  if (fwhm.ndim GT 0L) then sigma_var = dblarr(fwhm.dim)
endelse

;Return the output values
return, sigma

END
