FUNCTION sigma2fwhm, sigma, status, UNIT_CONVERSION = unit_conversion, NO_PAR_CHECK = no_par_check

; Description: This function calculates a set of equivalent Gaussian FWHM values from an input set of
;              Gaussian sigma values "sigma" with arbitrary units. Note that this function is not a unit
;              conversion module. The units of the output Gaussian FWHM values (e.g. pixels, metres, etc.)
;              are the same as the units of the input Gaussian sigma values. The input parameter "sigma"
;              may be a scalar, vector, or array.
;                The function provides the alternative option of performing unit conversion via the use of
;              the keyword UNIT_CONVERSION. In this case, the function converts input values "sigma" in
;              units of Gaussian sigmas to output values in units of Gaussian FWHMs.
;
; Input Parameters:
;
;   sigma - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of
;                                                                Gaussian sigma values in arbitrary units.
;                                                                If the keyword UNIT_CONVERSION is set,
;                                                                then the elements of this input parameter
;                                                                are assumed to be values in units of
;                                                                Gaussian sigmas.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input value(s), then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision variable, with the same units and dimensions as the input
;   parameter "sigma", where each element represents the Gaussian FWHM value equivalent to the
;   corresponding Gaussian sigma value in "sigma". If the keyword UNIT_CONVERSION is set, then the function
;   returns a DOUBLE precision variable, with the same dimensions as the input parameter "sigma", where
;   each element is the result of converting the corresponding element in "sigma" from units of Gaussian
;   sigmas to units of Gaussian FWHMs.
;
; Keywords:
;
;   If the keyword UNIT_CONVERSION is set (as "/UNIT_CONVERSION"), then the function assumes that the input
;   values "sigma" are in units of Gaussian sigmas and it converts them to values in units of Gaussian FWHMs.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameter, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "sigma" is of the correct number type
  if (test_bytintlonfltdbl(sigma) NE 1) then return, 0.0D
endif

;Set "status" to "1"
status = 1

;If the keyword UNIT_CONVERSION is set, then return the input values in units of Gaussian FWHMs
fac = sqrt(alog(256.0D))
if keyword_set(unit_conversion) then return, (1.0D/fac)*sigma

;If the keyword UNIT_CONVERSION is not set, then return the equivalent Gaussian FWHM values
return, fac*sigma

END
