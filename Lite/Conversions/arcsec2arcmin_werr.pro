FUNCTION arcsec2arcmin_werr, arcsec, arcsec_var, arcmin_var, status, ERROR_PROPAGATION = error_propagation, NO_PAR_CHECK = no_par_check

; Description: This function converts angles in arcseconds "arcsec" to angles in arcminutes. The input
;              parameter "arcsec" may be a scalar, vector, or array.
;                The function also performs propagation of the variances "arcsec_var" associated with the
;              input parameter "arcsec". The variance propagation that is performed is exact. The variances
;              corresponding to the angles in arcminutes are returned via the output parameter "arcmin_var".
;              The function provides the option of performing error propagation instead of variance
;              propagation via the use of the keyword ERROR_PROPAGATION.
;                The function does not perform bad pixel mask propagation since the input bad pixel/data
;              mask is unchanged by the operations performed on the input data "arcsec".
;
; Input Parameters:
;
;   arcsec - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set
;                                                                 of angles in arcseconds.
;   arcsec_var - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of non-negative numbers, with
;                                                   the same number of elements as "arcsec", where the
;                                                   elements represent the variances associated with
;                                                   "arcsec". If this input parameter does not satisfy
;                                                   the input requirements, then all of the variances are
;                                                   assumed to be zero. If the keyword ERROR_PROPAGATION
;                                                   is set, then the elements of this input parameter are
;                                                   assumed to represent standard errors as opposed to
;                                                   variances.
;   arcmin_var - ANY - A variable which will be used to contain the variances corresponding to the angles
;                      in units of arcminutes on returning (see output parameters below).
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   arcmin_var - DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array, with the same dimensions as the input
;                                             parameter "arcsec", where the elements represent the variances
;                                             corresponding to the angles in units of arcminutes. If the
;                                             keyword ERROR_PROPAGATION is set, then the elements of this
;                                             output parameter represent the standard errors corresponding
;                                             to the angles in units of arcminutes.
;   status - INTEGER - If the function successfully processed the input angle(s), then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision variable, with the same dimensions as the input parameter
;   "arcsec", where each element represents an angle in units of arcminutes.
;
; Keywords:
;
;   If the keyword ERROR_PROPAGATION is set (as "/ERROR_PROPAGATION"), then the function will perform error
;   propagation instead of variance propagation. In other words, the elements of the input parameter
;   "arcsec_var" are assumed to represent standard errors, and the output parameter "arcmin_var" is returned
;   with elements representing standard errors.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
arcmin_var = 0.0D

;Convert the input angles to angles in units of arcminutes
arcmin = arcsec2arcmin(arcsec, status, NO_PAR_CHECK = no_par_check)
if (status EQ 0) then return, arcmin

;Check that "arcsec_var" is a scalar/vector/array of non-negative numbers of the correct number type, and
;that it has the same number of elements as "arcsec"
arcsec_var_tag = 0
if (test_fltdbl(arcsec_var) EQ 1) then begin
  if (arcsec_var.length EQ arcsec.length) then arcsec_var_tag = fix(array_equal(arcsec_var GE 0.0, 1B))
endif

;Perform the variance propagation
if (arcsec_var_tag EQ 1) then begin
  if keyword_set(error_propagation) then begin
    arcmin_var = (1.0D/60.0D)*arcsec_var
  endif else arcmin_var = (1.0D/3600.0D)*arcsec_var
  if (arcsec.ndim EQ 0L) then begin
    arcmin_var = arcmin_var[0]
  endif else arcmin_var = reform(arcmin_var, arcsec.dim, /OVERWRITE)
endif else begin
  if (arcsec.ndim GT 0L) then arcmin_var = dblarr(arcsec.dim)
endelse

;Return the input angles in units of arcminutes
return, arcmin

END
