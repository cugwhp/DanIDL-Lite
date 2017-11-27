PRO generate_pixel_indices_for_rectangle_in_2darr, xsize, ysize, x0, y0, A, B, theta, xind, yind, subs, nind, status, EXCLUDE_BORDER = exclude_border, NO_SUBS = no_subs, $
                                                   NO_PAR_CHECK = no_par_check

; Description: This module generates a set of x and y pixel indices "xind" and "yind", respectively, for a
;              rectangular region in an image array of size "xsize" by "ysize" pixels. The rectangular
;              region is defined as the set of pixels whose centres lie within a rectangular box with sides
;              of length "A" and "B" pixels which has its centroid at the coordinates "(x0,y0)" and that is
;              inclined such that the side of length "A" pixels is at an angle of "theta" degrees as
;              measured anti-clockwise from the image x-axis. In mathematical terms, this constraint is
;              equivalent to the following two constraints (derived by considering the dot products of the
;              appropriate vector pairs), which must both be true:
;
;              |(x_i - x0)*cos(theta) + (y_j - y0)*sin(theta)| <= A/2                       (1)
;              |(x_i - x0)*sin(theta) - (y_j - y0)*cos(theta)| <= B/2                       (2)
;
;              where "(x_i,y_j)" are the coordinates of a pixel with pixel index coordinates "(i,j)". A
;              pixel has a centre that lies on the border of the rectangular region when at least one of
;              the two constraints is satisfied as an equality. Note that the module does not require that
;              the rectangular region is fully encompassed by the image area in order to generate the pixel
;              indices "xind" and "yind".
;                The module provides the option of excluding those pixels whose centres lie on the border
;              of the rectangular region from the set of x and y pixel indices "xind" and "yind". This is
;              equivalent to changing the constraints "<=" to "<" in each of the equations (1)-(2). This
;              behaviour may be achieved by setting the keyword EXCLUDE_BORDER.
;                By default, the module also returns the image subscripts "subs" corresponding to the set
;              of x and y pixel indices "xind" and "yind". However, if these subscripts are not required,
;              then the module can be instructed not to generate them by setting the keyword NO_SUBS, which
;              leads to a faster execution of this module.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The image size (pix) along the x-axis. This parameter must be positive.
;   ysize - INTEGER/LONG - The image size (pix) along the y-axis. This parameter must be positive.
;   x0 - FLOAT/DOUBLE - The x coordinate (pix) of the centroid of the rectangular region.
;   y0 - FLOAT/DOUBLE - The y coordinate (pix) of the centroid of the rectangular region.
;   A - FLOAT/DOUBLE - The length (pix) of the "long" side of the rectangular region. This parameter must
;                      be non-negative.
;   B - FLOAT/DOUBLE - The length (pix) of the "short" side of the rectangular region. This parameter must
;                      be non-negative.
;   theta - FLOAT/DOUBLE - The angle (degrees) as measured anti-clockwise from the x-axis to the side of
;                          length "A" of the rectangle.
;
; Output Parameters:
;
;   xind - LONG VECTOR - A one-dimensional vector with "nind" elements representing the pixel indices along
;                        the image x-axis for the required rectangular region in an image array of size
;                        "xsize" by "ysize" pixels. All elements in this parameter are non-negative and
;                        less than "xsize". If the overlap region between the rectangular region and the
;                        image area is empty, then this parameter is set to the single-element vector "[-1L]".
;   yind - LONG VECTOR - A one-dimensional vector with "nind" elements representing the pixel indices along
;                        the image y-axis for the required rectangular region in an image array of size
;                        "xsize" by "ysize" pixels. All elements in this parameter are non-negative and
;                        less than "ysize". If the overlap region between the rectangular region and the
;                        image area is empty, then this parameter is set to the single-element vector "[-1L]".
;   subs - LONG VECTOR - A one-dimensional vector with "nind" elements representing the image subscripts for
;                        the required rectangular region in an image array of size "xsize" by "ysize" pixels.
;                        All elements in this parameter are non-negative. If the overlap region between the
;                        rectangular region and the image area is empty, or if the keyword NO_SUBS is set,
;                        then this parameter is set to the single-element vector "[-1L]".
;   nind - LONG - The number of elements in each of the output parameters "xind", "yind" and "subs". If the
;                 overlap region between the rectangular region and the image area is empty, then this
;                 parameter is set to "0L".
;   status - INTEGER - If the module successfully generated the set of x and y pixel indices, then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword EXCLUDE_BORDER is set (as "/EXCLUDE_BORDER"), then the module will exclude those pixels
;   whose centres lie on the border of the rectangular region from the set of x and y pixel indices "xind"
;   and "yind". This is equivalent to changing the constraints "<=" to "<" in each of the equations (1)-(2).
;
;   If the keyword NO_SUBS is set (as "/NO_SUBS"), then the module will not generate the image subscripts
;   "subs", and this parameter will be returned as the single-element vector "[-1L]". Set this keyword if
;   the image subscripts are not required in order to obtain a faster execution of this module.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
xind = [-1L]
yind = [-1L]
subs = [-1L]
nind = 0L
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "xsize" and "ysize" are positive numbers of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return
  if (test_intlon_scalar(ysize) NE 1) then return
  if (xsize LT 1) then return
  if (ysize LT 1) then return

  ;Check that "x0" and "y0" are numbers of the correct type
  if (test_fltdbl_scalar(x0) NE 1) then return
  if (test_fltdbl_scalar(y0) NE 1) then return

  ;Check that "A" and "B" are non-negative numbers of the correct type
  if (test_fltdbl_scalar(A) NE 1) then return
  if (test_fltdbl_scalar(B) NE 1) then return
  if (A LT 0.0) then return
  if (B LT 0.0) then return

  ;Check that "theta" is a number of the correct type
  if (test_fltdbl_scalar(theta) NE 1) then return
endif
xsize_use = long(xsize)
ysize_use = long(ysize)
x0_use = double(x0)
y0_use = double(y0)
A_use = double(A)
B_use = double(B)
theta_use = double(theta)

;Set "status" to "1"
status = 1

;Determine the bounding box for the rectangular region
calculate_minmax_xy_for_rectangle_2d, x0_use, y0_use, A_use, B_use, theta_use, min_x, max_x, min_y, max_y, stat, /NO_PAR_CHECK

;Determine the overlap region between the bounding box and the image area
determine_rectangle_overlap_2d, floor(min_x), floor(max_x), floor(min_y), floor(max_y), 0L, xsize_use - 1L, 0L, ysize_use - 1L, oxlo, oxhi, oylo, oyhi, etag, stat

;If the overlap region between the bounding box and the image area is empty, then return an empty set of
;pixel indices
if (etag NE 1) then return

;If "theta" is a multiple of 90 degrees
if (abs(theta_use mod 90.0D) EQ 0.0D) then begin

  ;If there are no pixels with the x coordinates of their centres within the x-axis limits of the rectangular
  ;region, then return an empty set of pixel indices
  if (oxlo EQ 0L) then begin
    oxs = oxhi + 1L
  endif else begin
    min_x = min_x - double(oxlo)
    max_x = max_x - double(oxlo)
    oxs = oxhi - oxlo + 1L
  endelse
  create_pixel_coordinates_1dvec, oxs, 1.0D, 0.0D, 1L, xc, stat, /NO_PAR_CHECK
  if keyword_set(exclude_border) then begin
    rxsubs = where((xc GT min_x) AND (xc LT max_x), nrxsubs)
  endif else rxsubs = where((xc GE min_x) AND (xc LE max_x), nrxsubs)
  if (nrxsubs EQ 0L) then return

  ;If there are no pixels with the y coordinates of their centres within the y-axis limits of the rectangular
  ;region, then return an empty set of pixel indices
  if (oylo EQ 0L) then begin
    oys = oyhi + 1L
  endif else begin
    min_y = min_y - double(oylo)
    max_y = max_y - double(oylo)
    oys = oyhi - oylo + 1L
  endelse
  create_pixel_coordinates_1dvec, oys, 1.0D, 0.0D, 1L, yc, stat, /NO_PAR_CHECK
  if keyword_set(exclude_border) then begin
    rysubs = where((yc GT min_y) AND (yc LT max_y), nrysubs)
  endif else rysubs = where((yc GE min_y) AND (yc LE max_y), nrysubs)
  if (nrysubs EQ 0L) then return

  ;Generate the x and y pixel indices for the rectangular region in the image array
  nind = nrxsubs*nrysubs
  if (oxlo NE 0L) then rxsubs = temporary(rxsubs) + oxlo
  xind = reform(replicate_1dvec_into_2darr(rxsubs, 'x', nrysubs, stat, /NO_PAR_CHECK), nind, /OVERWRITE)
  if (oylo NE 0L) then rysubs = temporary(rysubs) + oylo
  yind = reform(replicate_1dvec_into_2darr(rysubs, 'y', nrxsubs, stat, /NO_PAR_CHECK), nind, /OVERWRITE)

;If "theta" is not a multiple of 90 degrees
endif else begin

  ;Calculate some useful quantities
  A_use = 0.5D*A_use
  B_use = 0.5D*B_use
  theta_rad = deg2rad(theta_use, stat, /NO_PAR_CHECK)
  sin_theta = sin(theta_rad)
  cos_theta = cos(theta_rad)

  ;Create the coordinate arrays required for equations (1)-(2)
  oxs = oxhi - oxlo + 1L
  oys = oyhi - oylo + 1L
  create_pixel_coordinates_1dvec, oxs, 1.0D, x0_use - double(oxlo), 1L, xc, stat, /NO_PAR_CHECK
  create_pixel_coordinates_1dvec, oys, 1.0D, y0_use - double(oylo), 1L, yc, stat, /NO_PAR_CHECK
  coord_arr1 = abs(calculate_outer_sum_of_two_vectors(xc*cos_theta, yc*sin_theta, stat, /NO_PAR_CHECK))
  coord_arr2 = abs(calculate_outer_sum_of_two_vectors(xc*sin_theta, yc*(-cos_theta), stat, /NO_PAR_CHECK))

  ;Generate the subscripts for the rectangular region within the overlap region between the bounding box and
  ;the image area
  if keyword_set(exclude_border) then begin
    rsubs = where((coord_arr1 LT A_use) AND (coord_arr2 LT B_use), nrsubs)
  endif else rsubs = where((coord_arr1 LE A_use) AND (coord_arr2 LE B_use), nrsubs)

  ;If there are no pixels with their centres in the rectangular region, then return an empty set of pixel
  ;indices
  if (nrsubs EQ 0L) then return

  ;Generate the x and y pixel indices for the rectangular region in the image array
  convert_2darr_subscripts_to_pixel_indices, rsubs, oxs, xind, yind, nind, stat, /NO_PAR_CHECK
  if (oxlo NE 0L) then xind = temporary(xind) + oxlo
  if (oylo NE 0L) then yind = temporary(yind) + oylo
endelse

;If required, then generate the image subscripts for the rectangular region
if ~keyword_set(no_subs) then convert_pixel_indices_to_2darr_subscripts, xind, yind, xsize_use, subs, nsubs, stat, /NO_PAR_CHECK

END
