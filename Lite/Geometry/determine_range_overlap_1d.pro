PRO determine_range_overlap_1d, r1xlo, r1xhi, r2xlo, r2xhi, oxlo, oxhi, etag, status

; Description: This module determines the overlap range between two ranges in one dimension. The first
;              range is defined by "[r1xlo:r1xhi]" and the second range is defined by "[r2xlo:r2xhi]".
;              The overlap range is defined by "[oxlo:oxhi]". If the overlap range is non-empty then
;              "etag" is returned with a value of "1", otherwise "etag" is returned with a value of "0".
;
; Input Parameters:
;
;   r1xlo - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The x coordinate of the lower limit of the first range.
;   r1xhi - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The x coordinate of the upper limit of the first range. This
;                                            parameter must have a value that is greater than or equal to
;                                            the value of the parameter "r1xlo".
;   r2xlo - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The x coordinate of the lower limit of the second range.
;   r2xhi - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The x coordinate of the upper limit of the second range. This
;                                            parameter must have a value that is greater than or equal to
;                                            the value of the parameter "r2xlo".
;
; Output Parameters:
;
;   oxlo - LONG/DOUBLE - The x coordinate of the lower limit of the overlap range. If all of the input
;                        parameters are supplied as BYTE, INTEGER, or LONG type numbers, then this
;                        parameter is returned as a LONG type number, otherwise it is returned as a DOUBLE
;                        type number. This parameter is returned with a value of "0.0D" if the overlap
;                        range is empty.
;   oxhi - LONG/DOUBLE - The x coordinate of the upper limit of the overlap range. If all of the input
;                        parameters are supplied as BYTE, INTEGER, or LONG type numbers, then this
;                        parameter is returned as a LONG type number, otherwise it is returned as a DOUBLE
;                        type number. This parameter is returned with a value of "0.0D" if the overlap
;                        range is empty.
;   etag - INTEGER - This parameter is returned with a value of "1" if the overlap range is non-empty,
;                    and it is returned with a value of "0" if the overlap range is empty.
;   status - INTEGER - If the module successfully determined the overlap range, then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
oxlo = 0.0D
oxhi = 0.0D
etag = 0
status = 0

;Check that the input parameters are numbers of the correct type
type_r1xlo = test_bytintlonfltdbl_scalar(r1xlo) + test_fltdbl_scalar(r1xlo)
type_r1xhi = test_bytintlonfltdbl_scalar(r1xhi) + test_fltdbl_scalar(r1xhi)
type_r2xlo = test_bytintlonfltdbl_scalar(r2xlo) + test_fltdbl_scalar(r2xlo)
type_r2xhi = test_bytintlonfltdbl_scalar(r2xhi) + test_fltdbl_scalar(r2xhi)
type_vec = [type_r1xlo, type_r1xhi, type_r2xlo, type_r2xhi]
if (test_set_membership(0, type_vec, /NO_PAR_CHECK) EQ 1) then return

;If the limits of the overlap range are to be returned as LONG type numbers
if (array_equal(type_vec, 1) EQ 1B) then begin

  ;Convert the input parameters appropriately
  r1xlo_use = long(r1xlo)
  r1xhi_use = long(r1xhi)
  r2xlo_use = long(r2xlo)
  r2xhi_use = long(r2xhi)

;If the limits of the overlap range are to be returned as DOUBLE type numbers
endif else begin

  ;Convert the input parameters appropriately
  r1xlo_use = double(r1xlo)
  r1xhi_use = double(r1xhi)
  r2xlo_use = double(r2xlo)
  r2xhi_use = double(r2xhi)
endelse

;Check that "r1xhi" is greater than or equal to "r1xlo"
if (r1xhi_use LT r1xlo_use) then return

;Check that "r2xhi" is greater than or equal to "r2xlo"
if (r2xhi_use LT r2xlo_use) then return

;Set "status" to "1"
status = 1

;If there is no overlap range, then return an empty overlap range
if (r1xlo_use GT r2xhi_use) then return
if (r1xhi_use LT r2xlo_use) then return

;Determine the overlap range
oxlo = r1xlo_use > r2xlo_use
oxhi = r1xhi_use < r2xhi_use

;Set "etag" to "1"
etag = 1

END
