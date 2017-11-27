FUNCTION create_spherical_mask_3darr, xsize, ysize, zsize, x0, y0, z0, r, status, EXCLUDE_BORDER = exclude_border, NO_PAR_CHECK = no_par_check

; Description: This function creates and returns a three-dimensional mask array of size "xsize" by "ysize"
;              by "zsize" pixels. In this mask array, all of the pixels for which the distance between their
;              centre and the coordinates "(x0,y0,z0)" is less than or equal to "r" pixels have the value
;              "1", and all of the remaining pixels have the value "0". In other words, this function
;              creates a spherical mask array.
;                In mathematical terms, this constraint is given by:
;
;              (x_i - x0)^2 + (y_j - y0)^2 + (z_k - z0)^2 <= r^2                (1)
;
;              where "(x_i,y_j,z_k)" are the coordinates of a pixel with pixel index coordinates "(i,j,k)".
;              A pixel has a centre that lies on the border of the spherical region when the constraint is
;              satisfied as an equality. Note that the function does not require that the spherical region
;              is fully encompassed by the mask volume in order to generate the mask array.
;                The function provides the option of setting those pixels whose centres lie on the border
;              of the spherical region to "0". This is equivalent to changing the constraint "<= r^2" to
;              "< r^2" in equation (1). This behaviour may be achieved by setting the keyword
;              EXCLUDE_BORDER.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The mask array size (pix) along the x-axis. This parameter must be positive.
;   ysize - INTEGER/LONG - The mask array size (pix) along the y-axis. This parameter must be positive.
;   zsize - INTEGER/LONG - The mask array size (pix) along the z-axis. This parameter must be positive.
;   x0 - FLOAT/DOUBLE - The x coordinate (pix) of the centre of the sphere defining the spherical mask.
;   y0 - FLOAT/DOUBLE - The y coordinate (pix) of the centre of the sphere defining the spherical mask.
;   z0 - FLOAT/DOUBLE - The z coordinate (pix) of the centre of the sphere defining the spherical mask.
;   r - FLOAT/DOUBLE - The radius (pix) of the sphere defining the spherical mask. This parameter must
;                      be non-negative.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully created the spherical mask array, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a three-dimensional mask array of INTEGER type numbers of size "xsize" by "ysize"
;   by "zsize" pixels. In this mask array, all of the pixels for which the distance between their centre
;   and the coordinates "(x0,y0,z0)" is less than or equal to "r" pixels have the value "1", and all of
;   the remaining pixels have the value "0". Note that if "ysize" and "zsize" are both set to "1", then
;   the return value will be a one-dimensional vector of length "xsize" pixels since IDL treats an Nx1x1
;   array as an N-element one-dimensional vector. Also, if only "zsize" is set to "1", then the return
;   value will be a two-dimensional array of size "xsize" by "ysize" pixels since IDL treats an MxNx1
;   array as an MxN-element two-dimensional array.
;
; Keywords:
;
;   If the keyword EXCLUDE_BORDER is set (as "/EXCLUDE_BORDER"), then the function will set those pixels
;   whose centres lie on the border of the spherical region to "0". This is equivalent to changing the
;   constraint "<= r^2" to "< r^2" in equation (1).
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Generate a set of data cube subscripts for the spherical mask in a mask array of size "xsize" by "ysize"
;by "zsize" pixels
generate_pixel_indices_for_sphere_in_3darr, xsize, ysize, zsize, x0, y0, z0, r, xind, yind, zind, subs, nind, status, EXCLUDE_BORDER = exclude_border, $
                                            NO_PAR_CHECK = no_par_check
if (status EQ 0) then return, 0

;Create and return the three-dimensional spherical mask array
spherical_mask = intarr(xsize, ysize, zsize)
if (nind GT 0L) then spherical_mask[subs] = 1
return, spherical_mask

END
