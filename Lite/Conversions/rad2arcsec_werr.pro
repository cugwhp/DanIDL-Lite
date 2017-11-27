FUNCTION rad2arcsec_werr, rad, rad_var, arcsec_var, status, ERROR_PROPAGATION = error_propagation, NO_PAR_CHECK = no_par_check

; Description: This function converts angles in radians "rad" to angles in arcseconds. The input parameter
;              "rad" may be a scalar, vector, or array.
;                The function also performs propagation of the variances "rad_var" associated with the
;              input parameter "rad". The variance propagation that is performed is exact. The variances
;              corresponding to the angles in arcseconds are returned via the output parameter "arcsec_var".
;              The function provides the option of performing error propagation instead of variance
;              propagation via the use of the keyword ERROR_PROPAGATION.
;                The function does not perform bad pixel mask propagation since the input bad pixel/data
;              mask is unchanged by the operations performed on the input data "rad".
;
; Input Parameters:
;
;   rad - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of
;                                                              angles in radians.
;   rad_var - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of non-negative numbers, with the
;                                                same number of elements as "rad", where the elements
;                                                represent the variances associated with "rad". If this
;                                                input parameter does not satisfy the input requirements,
;                                                then all of the variances are assumed to be zero. If the
;                                                keyword ERROR_PROPAGATION is set, then the elements of
;                                                this input parameter are assumed to represent standard
;                                                errors as opposed to variances.
;   arcsec_var - ANY - A variable which will be used to contain the variances corresponding to the angles
;                      in units of arcseconds on returning (see output parameters below).
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   arcsec_var - DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array, with the same dimensions as the input
;                                             parameter "rad", where the elements represent the variances
;                                             corresponding to the angles in units of arcseconds. If the
;                                             keyword ERROR_PROPAGATION is set, then the elements of this
;                                             output parameter represent the standard errors corresponding
;                                             to the angles in units of arcseconds.
;   status - INTEGER - If the function successfully processed the input angle(s), then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision variable, with the same dimensions as the input parameter "rad",
;   where each element represents an angle in units of arcseconds.
;
; Keywords:
;
;   If the keyword ERROR_PROPAGATION is set (as "/ERROR_PROPAGATION"), then the function will perform error
;   propagation instead of variance propagation. In other words, the elements of the input parameter
;   "rad_var" are assumed to represent standard errors, and the output parameter "arcsec_var" is returned
;   with elements representing standard errors.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
arcsec_var = 0.0D

;Convert the input angles to angles in units of arcseconds
arcsec = rad2arcsec(rad, status, NO_PAR_CHECK = no_par_check)
if (status EQ 0) then return, arcsec

;Check that "rad_var" is a scalar/vector/array of non-negative numbers of the correct number type, and
;that it has the same number of elements as "rad"
rad_var_tag = 0
if (test_fltdbl(rad_var) EQ 1) then begin
  if (rad_var.length EQ rad.length) then rad_var_tag = fix(array_equal(rad_var GE 0.0, 1B))
endif

;Perform the variance propagation
if (rad_var_tag EQ 1) then begin
  if keyword_set(error_propagation) then begin
    arcsec_var = (648000.0D/get_dbl_pi())*rad_var
  endif else arcsec_var = (419904000000.0D/get_dbl_pi2())*rad_var
  if (rad.ndim EQ 0L) then begin
    arcsec_var = arcsec_var[0]
  endif else arcsec_var = reform(arcsec_var, rad.dim, /OVERWRITE)
endif else begin
  if (rad.ndim GT 0L) then arcsec_var = dblarr(rad.dim)
endelse

;Return the input angles in units of arcseconds
return, arcsec

END
