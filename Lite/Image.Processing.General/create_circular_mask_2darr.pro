FUNCTION create_circular_mask_2darr, xsize, ysize, x0, y0, r, status, EXCLUDE_BORDER = exclude_border, NO_PAR_CHECK = no_par_check

; Description: This function creates and returns a two-dimensional mask array of size "xsize" by "ysize"
;              pixels. In this mask array, all of the pixels for which the distance between their centre
;              and the coordinates "(x0,y0)" is less than or equal to "r" pixels have the value "1", and
;              all of the remaining pixels have the value "0". In other words, this function creates a
;              circular mask array.
;                In mathematical terms, this constraint is given by:
;
;              (x_i - x0)^2 + (y_j - y0)^2 <= r^2                (1)
;
;              where "(x_i,y_j)" are the coordinates of a pixel with pixel index coordinates "(i,j)". A
;              pixel has a centre that lies on the border of the circular region when the constraint is
;              satisfied as an equality. Note that the function does not require that the circular region
;              is fully encompassed by the mask area in order to generate the mask array.
;                The function provides the option of setting those pixels whose centres lie on the border
;              of the circular region to "0". This is equivalent to changing the constraint "<= r^2" to
;              "< r^2" in equation (1). This behaviour may be achieved by setting the keyword
;              EXCLUDE_BORDER.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The mask array size (pix) along the x-axis. This parameter must be positive.
;   ysize - INTEGER/LONG - The mask array size (pix) along the y-axis. This parameter must be positive.
;   x0 - FLOAT/DOUBLE - The x coordinate (pix) of the centre of the circle defining the circular mask.
;   y0 - FLOAT/DOUBLE - The y coordinate (pix) of the centre of the circle defining the circular mask.
;   r - FLOAT/DOUBLE - The radius (pix) of the circle defining the circular mask. This parameter must
;                      be non-negative.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully created the circular mask array, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a two-dimensional mask array of INTEGER type numbers of size "xsize" by "ysize"
;   pixels. In this mask array, all of the pixels for which the distance between their centre and the
;   coordinates "(x0,y0)" is less than or equal to "r" pixels have the value "1", and all of the
;   remaining pixels have the value "0". Note that if "ysize" is set to "1", then the return value will
;   be a one-dimensional vector of length "xsize" pixels since IDL treats an Nx1 array as an N-element
;   one-dimensional vector.
;
; Keywords:
;
;   If the keyword EXCLUDE_BORDER is set (as "/EXCLUDE_BORDER"), then the function will set those pixels
;   whose centres lie on the border of the circular region to "0". This is equivalent to changing the
;   constraint "<= r^2" to "< r^2" in equation (1).
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Generate a set of image subscripts for the circular mask in a mask array of size "xsize" by "ysize" pixels
generate_pixel_indices_for_circle_in_2darr, xsize, ysize, x0, y0, r, xind, yind, subs, nind, status, EXCLUDE_BORDER = exclude_border, NO_PAR_CHECK = no_par_check
if (status EQ 0) then return, 0

;Create and return the two-dimensional circular mask array
circular_mask = intarr(xsize, ysize)
if (nind GT 0L) then circular_mask[subs] = 1
return, circular_mask

END
