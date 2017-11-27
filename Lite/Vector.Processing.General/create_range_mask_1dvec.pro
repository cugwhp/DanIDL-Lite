FUNCTION create_range_mask_1dvec, xsize, xlo, xhi, status, EXCLUDE_LOWER_LIMIT = exclude_lower_limit, EXCLUDE_UPPER_LIMIT = exclude_upper_limit, $
                                  NO_PAR_CHECK = no_par_check

; Description: This function creates and returns a one-dimensional mask vector of length "xsize" pixels.
;              In this mask vector, all of the pixels with centres that lie in the x coordinate range
;              "[xlo:xhi]" have the value "1", and all of the remaining pixels have the value "0". In
;              other words, this function creates a range mask vector.
;                In mathematical terms, these constraints are given by:
;
;              xlo <= x_i <= xhi                 (1)
;
;              where "x_i" is the x coordinate of a pixel with pixel index "i", and "xlo" and "xhi" are
;              the lower and upper limits of the x coordinate range. A pixel has a centre that lies on
;              one of the coordinate range limits when one of the two constraints is satisfied as an
;              equality. Note that the function does not require that the x coordinate range is fully
;              encompassed by the vector length in order to generate the mask vector.
;                The function provides the option of setting the pixel whose centre lies on the lower
;              limit of the coordinate range to "0". This is equivalent to changing the constraint
;              "xlo <=" to "xlo <" in equation (1). This behaviour may be achieved by setting the
;              keyword EXCLUDE_LOWER_LIMIT.
;                The function also provides the option of setting the pixel whose centre lies on the
;              upper limit of the coordinate range to "0". This is equivalent to changing the constraint
;              "<= xhi" to "< xhi" in equation (1). This behaviour may be achieved by setting the
;              keyword EXCLUDE_UPPER_LIMIT.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The mask vector length (pix). This parameter must be positive.
;   xlo - FLOAT/DOUBLE - The lower limit (pix) of the x coordinate range.
;   xhi - FLOAT/DOUBLE - The upper limit (pix) of the x coordinate range. Note that if "xlo > xhi", then
;                        the function will simply consider "xlo" as the upper limit of the coordinate
;                        range and "xhi" as the lower limit of the coordinate range.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully created the range mask vector, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a one-dimensional mask vector of INTEGER type numbers of length "xsize" pixels.
;   In this mask vector, all of the pixels with centres that lie in the x coordinate range "[xlo:xhi]"
;   have the value "1", and all of the remaining pixels have the value "0".
;
; Keywords:
;
;   If the keyword EXCLUDE_LOWER_LIMIT is set (as "/EXCLUDE_LOWER_LIMIT"), then the function will set the
;   pixel whose centre lies on the lower limit of the coordinate range to "0". This is equivalent to
;   changing the constraint "xlo <=" to "xlo <" in equation (1).
;
;   If the keyword EXCLUDE_UPPER_LIMIT is set (as "/EXCLUDE_UPPER_LIMIT"), then the function will set the
;   pixel whose centre lies on the upper limit of the coordinate range to "0". This is equivalent to
;   changing the constraint "<= xhi" to "< xhi" in equation (1).
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Generate a set of pixel indices for the coordinate range "[xlo:xhi]" in a mask vector of length "xsize"
;pixels
generate_pixel_indices_for_range_in_1dvec, xsize, xlo, xhi, xind, nind, status, EXCLUDE_LOWER_LIMIT = exclude_lower_limit, EXCLUDE_UPPER_LIMIT = exclude_upper_limit, $
                                           NO_PAR_CHECK = no_par_check
if (status EQ 0) then return, 0

;Create and return the one-dimensional range mask vector
range_mask = intarr(xsize)
if (nind GT 0L) then range_mask[xind] = 1
return, range_mask

END
