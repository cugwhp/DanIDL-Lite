FUNCTION create_rectangular_mask_2darr, xsize, ysize, x0, y0, A, B, theta, status, EXCLUDE_BORDER = exclude_border, NO_PAR_CHECK = no_par_check

; Description: This function creates and returns a two-dimensional mask array of size "xsize" by "ysize"
;              pixels. In this mask array, all of the pixels whose centres lie within a rectangular region
;              have the value "1", and all of the remaining pixels have the value "0". The rectangular
;              region is defined as a rectangle with sides of length "A" and "B" pixels which has its
;              centroid at the coordinates "(x0,y0)" and that is inclined such that the side of length
;              "A" pixels is at an angle of "theta" degrees as measured anti-clockwise from the mask
;              x-axis. In other words, this function creates a rectangular mask array.
;                In mathematical terms, this constraint is equivalent to the following two constraints
;              (derived by considering the dot products of the appropriate vector pairs), which must both
;              be true:
;
;              |(x_i - x0)*cos(theta) + (y_j - y0)*sin(theta)| <= A/2                       (1)
;              |(x_i - x0)*sin(theta) - (y_j - y0)*cos(theta)| <= B/2                       (2)
;
;              where "(x_i,y_j)" are the coordinates of a pixel with pixel index coordinates "(i,j)". A
;              pixel has a centre that lies on the border of the rectangular region when at least one of
;              the two constraints is satisfied as an equality. Note that the function does not require
;              that the rectangular region is fully encompassed by the mask area in order to generate the
;              mask array.
;                The function provides the option of setting those pixels whose centres lie on the border
;              of the rectangular region to "0". This is equivalent to changing the constraints "<=" to
;              "<" in each of the equations (1)-(2). This behaviour may be achieved by setting the keyword
;              EXCLUDE_BORDER.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The mask array size (pix) along the x-axis. This parameter must be positive.
;   ysize - INTEGER/LONG - The mask array size (pix) along the y-axis. This parameter must be positive.
;   x0 - FLOAT/DOUBLE - The x coordinate (pix) of the centroid of the rectangle defining the rectangular
;                       mask.
;   y0 - FLOAT/DOUBLE - The y coordinate (pix) of the centroid of the rectangle defining the rectangular
;                       mask.
;   A - FLOAT/DOUBLE - The length (pix) of the "long" side of the rectangle defining the rectangular mask.
;                      This parameter must be non-negative.
;   B - FLOAT/DOUBLE - The length (pix) of the "short" side of the rectangle defining the rectangular mask.
;                      This parameter must be non-negative.
;   theta - FLOAT/DOUBLE - The angle (degrees) as measured anti-clockwise from the x-axis to the side of
;                          length "A" of the rectangle defining the rectangular mask.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully created the rectangular mask array, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a two-dimensional mask array of INTEGER type numbers of size "xsize" by "ysize"
;   pixels. In this mask array, all of the pixels whose centres lie within a rectangular region have the
;   value "1", and all of the remaining pixels have the value "0". The rectangular region is defined as a
;   rectangle with sides of length "A" and "B" pixels which has its centroid at the coordinates "(x0,y0)"
;   and that is inclined such that the side of length "A" pixels is at an angle of "theta" degrees as
;   measured anti-clockwise from the mask x-axis. Note that if "ysize" is set to "1", then the return
;   value will be a one-dimensional vector of length "xsize" pixels since IDL treats an Nx1 array as an
;   N-element one-dimensional vector.
;
; Keywords:
;
;   If the keyword EXCLUDE_BORDER is set (as "/EXCLUDE_BORDER"), then the function will set those pixels
;   whose centres lie on the border of the rectangular region to "0". This is equivalent to changing the
;   constraints "<=" to "<" in each of the equations (1)-(2).
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Generate a set of image subscripts for the rectangular mask in a mask array of size "xsize" by "ysize"
;pixels
generate_pixel_indices_for_rectangle_in_2darr, xsize, ysize, x0, y0, A, B, theta, xind, yind, subs, nind, status, EXCLUDE_BORDER = exclude_border, $
                                               NO_PAR_CHECK = no_par_check
if (status EQ 0) then return, 0

;Create and return the two-dimensional rectangular mask array
rectangular_mask = intarr(xsize, ysize)
if (nind GT 0L) then rectangular_mask[subs] = 1
return, rectangular_mask

END
