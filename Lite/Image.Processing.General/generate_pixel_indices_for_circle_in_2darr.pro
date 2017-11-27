PRO generate_pixel_indices_for_circle_in_2darr, xsize, ysize, x0, y0, r, xind, yind, subs, nind, status, EXCLUDE_BORDER = exclude_border, NO_SUBS = no_subs, $
                                                NO_PAR_CHECK = no_par_check

; Description: This module generates a set of x and y pixel indices "xind" and "yind", respectively, for a
;              circular region in an image array of size "xsize" by "ysize" pixels. The circular region is
;              defined as the set of pixels for which the distance between their centre and the coordinates
;              "(x0,y0)" is less than or equal to "r" pixels. In mathematical terms, this constraint is given
;              by:
;
;              (x_i - x0)^2 + (y_j - y0)^2 <= r^2                (1)
;
;              where "(x_i,y_j)" are the coordinates of a pixel with pixel index coordinates "(i,j)". A pixel
;              has a centre that lies on the border of the circular region when the constraint is satisfied
;              as an equality. Note that the module does not require that the circular region is fully
;              encompassed by the image area in order to generate the pixel indices "xind" and "yind".
;                The module provides the option of excluding those pixels whose centres lie on the border of
;              the circular region from the set of x and y pixel indices "xind" and "yind". This is equivalent
;              to changing the constraint "<= r^2" to "< r^2" in equation (1). This behaviour may be achieved
;              by setting the keyword EXCLUDE_BORDER.
;                By default, the module also returns the image subscripts "subs" corresponding to the set of
;              x and y pixel indices "xind" and "yind". However, if these subscripts are not required, then
;              the module can be instructed not to generate them by setting the keyword NO_SUBS, which leads
;              to a faster execution of this module.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The image size (pix) along the x-axis. This parameter must be positive.
;   ysize - INTEGER/LONG - The image size (pix) along the y-axis. This parameter must be positive.
;   x0 - FLOAT/DOUBLE - The x coordinate (pix) of the centre of the circular region.
;   y0 - FLOAT/DOUBLE - The y coordinate (pix) of the centre of the circular region.
;   r - FLOAT/DOUBLE - The radius (pix) of the circular region. This parameter must be non-negative.
;
; Output Parameters:
;
;   xind - LONG VECTOR - A one-dimensional vector with "nind" elements representing the pixel indices along
;                        the image x-axis for the required circular region in an image array of size "xsize"
;                        by "ysize" pixels. All elements in this parameter are non-negative and less than
;                        "xsize". If the overlap region between the circular region and the image area is
;                        empty, then this parameter is set to the single-element vector "[-1L]".
;   yind - LONG VECTOR - A one-dimensional vector with "nind" elements representing the pixel indices along
;                        the image y-axis for the required circular region in an image array of size "xsize"
;                        by "ysize" pixels. All elements in this parameter are non-negative and less than
;                        "ysize". If the overlap region between the circular region and the image area is
;                        empty, then this parameter is set to the single-element vector "[-1L]".
;   subs - LONG VECTOR - A one-dimensional vector with "nind" elements representing the image subscripts for
;                        the required circular region in an image array of size "xsize" by "ysize" pixels.
;                        All elements in this parameter are non-negative. If the overlap region between the
;                        circular region and the image area is empty, or if the keyword NO_SUBS is set, then
;                        this parameter is set to the single-element vector "[-1L]".
;   nind - LONG - The number of elements in each of the output parameters "xind", "yind" and "subs". If the
;                 overlap region between the circular region and the image area is empty, then this parameter
;                 is set to "0L".
;   status - INTEGER - If the module successfully generated the set of x and y pixel indices, then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword EXCLUDE_BORDER is set (as "/EXCLUDE_BORDER"), then the module will exclude those pixels
;   whose centres lie on the border of the circular region from the set of x and y pixel indices "xind" and
;   "yind". This is equivalent to changing the constraint "<= r^2" to "< r^2" in equation (1).
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

  ;Check that "x0", "y0", and "r" are all numbers of the correct type, and that "r" is non-negative
  if (test_fltdbl_scalar(x0) NE 1) then return
  if (test_fltdbl_scalar(y0) NE 1) then return
  if (test_fltdbl_scalar(r) NE 1) then return
  if (r LT 0.0) then return
endif
xsize_use = long(xsize)
ysize_use = long(ysize)
x0_use = double(x0)
y0_use = double(y0)
r_use = double(r)

;Set "status" to "1"
status = 1

;Determine the bounding box for the circular region
xlo = floor(x0_use - r_use)
xhi = floor(x0_use + r_use)
ylo = floor(y0_use - r_use)
yhi = floor(y0_use + r_use)

;Determine the overlap region between the bounding box and the image area
determine_rectangle_overlap_2d, xlo, xhi, ylo, yhi, 0L, xsize_use - 1L, 0L, ysize_use - 1L, oxlo, oxhi, oylo, oyhi, etag, stat

;If the overlap region between the bounding box and the image area is empty, then return an empty set of
;pixel indices
if (etag NE 1) then return

;Determine the squared distance of each pixel in the overlap region between the bounding box and the image
;area from the pixel coordinates "(x0,y0)"
oxs = oxhi - oxlo + 1L
oys = oyhi - oylo + 1L
create_euclidean_distance_2darr, oxs, oys, x0_use - double(oxlo), y0_use - double(oylo), dist2_arr, stat, /SQUARED_DISTANCE, /NO_PAR_CHECK

;Generate the subscripts for the circular region within the overlap region between the bounding box and the
;image area
if keyword_set(exclude_border) then begin
  csubs = where(dist2_arr LT (r_use*r_use), ncsubs)
endif else csubs = where(dist2_arr LE (r_use*r_use), ncsubs)

;If there are no pixels with their centres in the circular region, then return an empty set of pixel indices
if (ncsubs EQ 0L) then return

;Generate the x and y pixel indices for the circular region in the image array
convert_2darr_subscripts_to_pixel_indices, csubs, oxs, xind, yind, nind, stat, /NO_PAR_CHECK
if (oxlo NE 0L) then xind = temporary(xind) + oxlo
if (oylo NE 0L) then yind = temporary(yind) + oylo

;If required, then generate the image subscripts for the circular region
if ~keyword_set(no_subs) then convert_pixel_indices_to_2darr_subscripts, xind, yind, xsize_use, subs, nsubs, stat, /NO_PAR_CHECK

END
