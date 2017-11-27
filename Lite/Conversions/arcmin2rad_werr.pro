FUNCTION arcmin2rad_werr, arcmin, arcmin_var, rad_var, status, ERROR_PROPAGATION = error_propagation, NO_PAR_CHECK = no_par_check

; Description: This function converts angles in arcminutes "arcmin" to angles in radians. The input parameter
;              "arcmin" may be a scalar, vector, or array.
;                The function also performs propagation of the variances "arcmin_var" associated with the
;              input parameter "arcmin". The variance propagation that is performed is exact. The variances
;              corresponding to the angles in radians are returned via the output parameter "rad_var". The
;              function provides the option of performing error propagation instead of variance propagation
;              via the use of the keyword ERROR_PROPAGATION.
;                The function does not perform bad pixel mask propagation since the input bad pixel/data
;              mask is unchanged by the operations performed on the input data "arcmin".
;
; Input Parameters:
;
;   arcmin - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set
;                                                                 of angles in arcminutes.
;   arcmin_var - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array of non-negative numbers, with
;                                                   the same number of elements as "arcmin", where the
;                                                   elements represent the variances associated with
;                                                   "arcmin". If this input parameter does not satisfy
;                                                   the input requirements, then all of the variances are
;                                                   assumed to be zero. If the keyword ERROR_PROPAGATION
;                                                   is set, then the elements of this input parameter are
;                                                   assumed to represent standard errors as opposed to
;                                                   variances.
;   rad_var - ANY - A variable which will be used to contain the variances corresponding to the angles in
;                   units of radians on returning (see output parameters below).
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   rad_var - DOUBLE SCALAR/VECTOR/ARRAY - A scalar/vector/array, with the same dimensions as the input
;                                          parameter "arcmin", where the elements represent the variances
;                                          corresponding to the angles in units of radians. If the keyword
;                                          ERROR_PROPAGATION is set, then the elements of this output
;                                          parameter represent the standard errors corresponding to the
;                                          angles in units of radians.
;   status - INTEGER - If the function successfully processed the input angle(s), then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision variable, with the same dimensions as the input parameter
;   "arcmin", where each element represents an angle in units of radians.
;
; Keywords:
;
;   If the keyword ERROR_PROPAGATION is set (as "/ERROR_PROPAGATION"), then the function will perform error
;   propagation instead of variance propagation. In other words, the elements of the input parameter
;   "arcmin_var" are assumed to represent standard errors, and the output parameter "rad_var" is returned
;   with elements representing standard errors.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
rad_var = 0.0D

;Convert the input angles to angles in units of radians
rad = arcmin2rad(arcmin, status, NO_PAR_CHECK = no_par_check)
if (status EQ 0) then return, rad

;Check that "arcmin_var" is a scalar/vector/array of non-negative numbers of the correct number type, and
;that it has the same number of elements as "arcmin"
arcmin_var_tag = 0
if (test_fltdbl(arcmin_var) EQ 1) then begin
  if (arcmin_var.length EQ arcmin.length) then arcmin_var_tag = fix(array_equal(arcmin_var GE 0.0, 1B))
endif

;Perform the variance propagation
if (arcmin_var_tag EQ 1) then begin
  if keyword_set(error_propagation) then begin
    rad_var = (get_dbl_pi()/10800.0D)*arcmin_var
  endif else rad_var = (get_dbl_pi2()/116640000.0D)*arcmin_var
  if (arcmin.ndim EQ 0L) then begin
    rad_var = rad_var[0]
  endif else rad_var = reform(rad_var, arcmin.dim, /OVERWRITE)
endif else begin
  if (arcmin.ndim GT 0L) then rad_var = dblarr(arcmin.dim)
endelse

;Return the input angles in units of radians
return, rad

END
