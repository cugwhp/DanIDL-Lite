PRO generate_pixel_indices_for_range_in_1dvec, xsize, xlo, xhi, xind, nind, status, EXCLUDE_LOWER_LIMIT = exclude_lower_limit, EXCLUDE_UPPER_LIMIT = exclude_upper_limit, $
                                               NO_PAR_CHECK = no_par_check

; Description: This module generates a set of x pixel indices "xind" for an x coordinate range "[xlo:xhi]"
;              in a vector of length "xsize" pixels. In mathematical terms, these constraints are given
;              by:
;
;              xlo <= x_i <= xhi                 (1)
;
;              where "x_i" is the x coordinate of a pixel with pixel index "i", and "xlo" and "xhi" are the
;              lower and upper limits of the x coordinate range. A pixel has a centre that lies on one of
;              the coordinate range limits when one of the two constraints is satisfied as an equality. Note
;              that the module does not require that the x coordinate range is fully encompassed by the
;              vector length in order to generate the pixel indices "xind".
;                The module provides the option of excluding the pixel whose centre lies on the lower limit
;              of the coordinate range from the set of pixel indices "xind". This is equivalent to changing
;              the constraint "xlo <=" to "xlo <" in equation (1). This behaviour may be achieved by setting
;              the keyword EXCLUDE_LOWER_LIMIT.
;                The module also provides the option of excluding the pixel whose centre lies on the upper
;              limit of the coordinate range from the set of pixel indices "xind". This is equivalent to
;              changing the constraint "<= xhi" to "< xhi" in equation (1). This behaviour may be achieved
;              by setting the keyword EXCLUDE_UPPER_LIMIT.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The vector length (pix). This parameter must be positive.
;   xlo - FLOAT/DOUBLE - The lower limit (pix) of the x coordinate range.
;   xhi - FLOAT/DOUBLE - The upper limit (pix) of the x coordinate range. Note that if "xlo > xhi", then
;                        the module will simply consider "xlo" as the upper limit of the coordinate range
;                        and "xhi" as the lower limit of the coordinate range.
;
; Output Parameters:
;
;   xind - LONG VECTOR - A one-dimensional vector with "nind" elements representing the pixel indices along
;                        the x-axis for the required coordinate range in a vector of length "xsize" pixels.
;                        All elements in this parameter are non-negative and less than "xsize". If the
;                        overlap range between the coordinate range and the vector length is empty, then
;                        this parameter is set to the single-element vector "[-1L]".
;   nind - LONG - The number of elements in the output parameter "xind". If the overlap range between the
;                 coordinate range and the vector length is empty, then this parameter is set to "0L".
;   status - INTEGER - If the module successfully generated the set of x pixel indices, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword EXCLUDE_LOWER_LIMIT is set (as "/EXCLUDE_LOWER_LIMIT"), then the module will exclude the
;   pixel whose centre lies on the lower limit of the coordinate range from the set of x pixel indices "xind".
;   This is equivalent to changing the constraint "xlo <=" to "xlo <" in equation (1).
;
;   If the keyword EXCLUDE_UPPER_LIMIT is set (as "/EXCLUDE_UPPER_LIMIT"), then the module will exclude the
;   pixel whose centre lies on the upper limit of the coordinate range from the set of x pixel indices "xind".
;   This is equivalent to changing the constraint "<= xhi" to "< xhi" in equation (1).
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
xind = [-1L]
nind = 0L
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "xsize" is a positive number of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return
  if (xsize LT 1) then return

  ;Check that "xlo" and "xhi" are numbers of the correct type
  if (test_fltdbl_scalar(xlo) NE 1) then return
  if (test_fltdbl_scalar(xhi) NE 1) then return
endif
xsize_use = long(xsize)
xlo_use = double(xlo)
xhi_use = double(xhi)

;Set "status" to "1"
status = 1

;If "xlo > xhi", then swap "xlo" and "xhi"
if (xlo_use GT xhi_use) then swap_variables, xlo_use, xhi_use, stat, /NO_PAR_CHECK

;Determine the overlap range between bounds on the coordinate range and the vector length
determine_range_overlap_1d, floor(xlo_use), floor(xhi_use), 0L, xsize_use - 1L, oxlo, oxhi, etag, stat

;If the overlap range between the bounds on the coordinate range and the vector length is empty, then return
;an empty set of pixel indices
if (etag NE 1) then return

;Determine the pixel indices corresponding to the ends of the overlap range between the coordinate range and
;the vector length
oxlo_coord = double(oxlo) + 0.5D
oxhi_coord = double(oxhi) + 0.5D
if keyword_set(exclude_lower_limit) then begin
  if (oxlo_coord LE xlo_use) then oxlo = oxlo + 1L
endif else begin
  if (oxlo_coord LT xlo_use) then oxlo = oxlo + 1L
endelse
if keyword_set(exclude_upper_limit) then begin
  if (oxhi_coord GE xhi_use) then oxhi = oxhi - 1L
endif else begin
  if (oxhi_coord GT xhi_use) then oxhi = oxhi - 1L
endelse

;If there are no pixels with their centres in the coordinate range, then return an empty set of pixel indices
if (oxlo GT oxhi) then return

;Generate the x pixel indices for the coordinate range in the vector
nind = oxhi - oxlo + 1L
if (oxlo EQ 0L) then begin
  xind = lindgen(nind)
endif else xind = oxlo + lindgen(nind)

END
