PRO determine_rectangular_cuboid_overlap_3d, r1xlo, r1xhi, r1ylo, r1yhi, r1zlo, r1zhi, r2xlo, r2xhi, r2ylo, r2yhi, r2zlo, r2zhi, oxlo, oxhi, oylo, oyhi, ozlo, ozhi, $
                                             etag, status

; Description: This module determines the overlap region between two rectangular cuboidal regions in three dimensions.
;              The first rectangular cuboidal region is defined by "[r1xlo:r1xhi,r1ylo:r1yhi,r1zlo:r1zhi]" and the
;              second rectangular cuboidal region is defined by "[r2xlo:r2xhi,r2ylo:r2yhi,r2zlo:r2zhi]". The overlap
;              region, which is also a rectangular cuboid, is defined by "[oxlo:oxhi,oylo:oyhi,ozlo:ozhi]". If the
;              overlap region is non-empty then "etag" is returned with a value of "1", otherwise "etag" is returned
;              with a value of "0".
;
; Input Parameters:
;
;   r1xlo - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The x coordinate of the low x coordinate side of the first rectangular
;                                            cuboidal region.
;   r1xhi - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The x coordinate of the high x coordinate side of the first rectangular
;                                            cuboidal region. This parameter must have a value that is greater than
;                                            or equal to the value of the parameter "r1xlo".
;   r1ylo - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The y coordinate of the low y coordinate side of the first rectangular
;                                            cuboidal region.
;   r1yhi - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The y coordinate of the high y coordinate side of the first rectangular
;                                            cuboidal region. This parameter must have a value that is greater than
;                                            or equal to the value of the parameter "r1ylo".
;   r1zlo - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The z coordinate of the low z coordinate side of the first rectangular
;                                            cuboidal region.
;   r1zhi - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The z coordinate of the high z coordinate side of the first rectangular
;                                            cuboidal region. This parameter must have a value that is greater than
;                                            or equal to the value of the parameter "r1zlo".
;   r2xlo - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The x coordinate of the low x coordinate side of the second rectangular
;                                            cuboidal region.
;   r2xhi - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The x coordinate of the high x coordinate side of the second rectangular
;                                            cuboidal region. This parameter must have a value that is greater than
;                                            or equal to the value of the parameter "r2xlo".
;   r2ylo - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The y coordinate of the low y coordinate side of the second rectangular
;                                            cuboidal region.
;   r2yhi - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The y coordinate of the high y coordinate side of the second rectangular
;                                            cuboidal region. This parameter must have a value that is greater than
;                                            or equal to the value of the parameter "r2ylo".
;   r2zlo - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The z coordinate of the low z coordinate side of the second rectangular
;                                            cuboidal region.
;   r2zhi - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The z coordinate of the high z coordinate side of the second rectangular
;                                            cuboidal region. This parameter must have a value that is greater than
;                                            or equal to the value of the parameter "r2zlo".
;
; Output Parameters:
;
;   oxlo - LONG/DOUBLE - The x coordinate of the low x coordinate side of the rectangular cuboidal overlap region.
;                        If all of the input parameters are supplied as BYTE, INTEGER, or LONG type numbers, then
;                        this parameter is returned as a LONG type number, otherwise it is returned as a DOUBLE type
;                        number. This parameter is returned with a value of "0.0D" if the overlap region is empty.
;   oxhi - LONG/DOUBLE - The x coordinate of the high x coordinate side of the rectangular cuboidal overlap region.
;                        If all of the input parameters are supplied as BYTE, INTEGER, or LONG type numbers, then
;                        this parameter is returned as a LONG type number, otherwise it is returned as a DOUBLE type
;                        number. This parameter is returned with a value of "0.0D" if the overlap region is empty.
;   oylo - LONG/DOUBLE - The y coordinate of the low y coordinate side of the rectangular cuboidal overlap region.
;                        If all of the input parameters are supplied as BYTE, INTEGER, or LONG type numbers, then
;                        this parameter is returned as a LONG type number, otherwise it is returned as a DOUBLE type
;                        number. This parameter is returned with a value of "0.0D" if the overlap region is empty.
;   oyhi - LONG/DOUBLE - The y coordinate of the high y coordinate side of the rectangular cuboidal overlap region.
;                        If all of the input parameters are supplied as BYTE, INTEGER, or LONG type numbers, then
;                        this parameter is returned as a LONG type number, otherwise it is returned as a DOUBLE type
;                        number. This parameter is returned with a value of "0.0D" if the overlap region is empty.
;   ozlo - LONG/DOUBLE - The z coordinate of the low z coordinate side of the rectangular cuboidal overlap region.
;                        If all of the input parameters are supplied as BYTE, INTEGER, or LONG type numbers, then
;                        this parameter is returned as a LONG type number, otherwise it is returned as a DOUBLE type
;                        number. This parameter is returned with a value of "0.0D" if the overlap region is empty.
;   ozhi - LONG/DOUBLE - The z coordinate of the high z coordinate side of the rectangular cuboidal overlap region.
;                        If all of the input parameters are supplied as BYTE, INTEGER, or LONG type numbers, then
;                        this parameter is returned as a LONG type number, otherwise it is returned as a DOUBLE type
;                        number. This parameter is returned with a value of "0.0D" if the overlap region is empty.
;   etag - INTEGER - This parameter is returned with a value of "1" if the overlap region is non-empty, and it is
;                    returned with a value of "0" if the overlap region is empty.
;   status - INTEGER - If the module successfully determined the overlap region, then "status" is returned with a
;                      value of "1", otherwise it is returned with a value of "0".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
oxlo = 0.0D
oxhi = 0.0D
oylo = 0.0D
oyhi = 0.0D
ozlo = 0.0D
ozhi = 0.0D
etag = 0
status = 0

;Check that the input parameters are numbers of the correct type
type_r1xlo = test_bytintlonfltdbl_scalar(r1xlo) + test_fltdbl_scalar(r1xlo)
type_r1xhi = test_bytintlonfltdbl_scalar(r1xhi) + test_fltdbl_scalar(r1xhi)
type_r1ylo = test_bytintlonfltdbl_scalar(r1ylo) + test_fltdbl_scalar(r1ylo)
type_r1yhi = test_bytintlonfltdbl_scalar(r1yhi) + test_fltdbl_scalar(r1yhi)
type_r1zlo = test_bytintlonfltdbl_scalar(r1zlo) + test_fltdbl_scalar(r1zlo)
type_r1zhi = test_bytintlonfltdbl_scalar(r1zhi) + test_fltdbl_scalar(r1zhi)
type_r2xlo = test_bytintlonfltdbl_scalar(r2xlo) + test_fltdbl_scalar(r2xlo)
type_r2xhi = test_bytintlonfltdbl_scalar(r2xhi) + test_fltdbl_scalar(r2xhi)
type_r2ylo = test_bytintlonfltdbl_scalar(r2ylo) + test_fltdbl_scalar(r2ylo)
type_r2yhi = test_bytintlonfltdbl_scalar(r2yhi) + test_fltdbl_scalar(r2yhi)
type_r2zlo = test_bytintlonfltdbl_scalar(r2zlo) + test_fltdbl_scalar(r2zlo)
type_r2zhi = test_bytintlonfltdbl_scalar(r2zhi) + test_fltdbl_scalar(r2zhi)
type_vec = [type_r1xlo, type_r1xhi, type_r1ylo, type_r1yhi, type_r1zlo, type_r1zhi, type_r2xlo, type_r2xhi, type_r2ylo, type_r2yhi, type_r2zlo, type_r2zhi]
if (test_set_membership(0, type_vec, /NO_PAR_CHECK) EQ 1) then return

;If the limits of the overlap region are to be returned as LONG type numbers
if (array_equal(type_vec, 1) EQ 1B) then begin

  ;Convert the input parameters appropriately
  r1xlo_use = long(r1xlo)
  r1xhi_use = long(r1xhi)
  r1ylo_use = long(r1ylo)
  r1yhi_use = long(r1yhi)
  r1zlo_use = long(r1zlo)
  r1zhi_use = long(r1zhi)
  r2xlo_use = long(r2xlo)
  r2xhi_use = long(r2xhi)
  r2ylo_use = long(r2ylo)
  r2yhi_use = long(r2yhi)
  r2zlo_use = long(r2zlo)
  r2zhi_use = long(r2zhi)

;If the limits of the overlap region are to be returned as DOUBLE type numbers
endif else begin

  ;Convert the input parameters appropriately
  r1xlo_use = double(r1xlo)
  r1xhi_use = double(r1xhi)
  r1ylo_use = double(r1ylo)
  r1yhi_use = double(r1yhi)
  r1zlo_use = double(r1zlo)
  r1zhi_use = double(r1zhi)
  r2xlo_use = double(r2xlo)
  r2xhi_use = double(r2xhi)
  r2ylo_use = double(r2ylo)
  r2yhi_use = double(r2yhi)
  r2zlo_use = double(r2zlo)
  r2zhi_use = double(r2zhi)
endelse

;Check that "r1xhi" is greater than or equal to "r1xlo", that "r1yhi" is greater than or equal to "r1ylo", and that
;"r1zhi" is greater than or equal to "r1zlo"
if (r1xhi_use LT r1xlo_use) then return
if (r1yhi_use LT r1ylo_use) then return
if (r1zhi_use LT r1zlo_use) then return

;Check that "r2xhi" is greater than or equal to "r2xlo", that "r2yhi" is greater than or equal to "r2ylo", and that
;"r2zhi" is greater than or equal to "r2zlo"
if (r2xhi_use LT r2xlo_use) then return
if (r2yhi_use LT r2ylo_use) then return
if (r2zhi_use LT r2zlo_use) then return

;Set "status" to "1"
status = 1

;If there is no overlap region, then return an empty overlap region
if (r1xlo_use GT r2xhi_use) then return
if (r1xhi_use LT r2xlo_use) then return
if (r1ylo_use GT r2yhi_use) then return
if (r1yhi_use LT r2ylo_use) then return
if (r1zlo_use GT r2zhi_use) then return
if (r1zhi_use LT r2zlo_use) then return

;Determine the overlap region
oxlo = r1xlo_use > r2xlo_use
oxhi = r1xhi_use < r2xhi_use
oylo = r1ylo_use > r2ylo_use
oyhi = r1yhi_use < r2yhi_use
ozlo = r1zlo_use > r2zlo_use
ozhi = r1zhi_use < r2zhi_use

;Set "etag" to "1"
etag = 1

END
