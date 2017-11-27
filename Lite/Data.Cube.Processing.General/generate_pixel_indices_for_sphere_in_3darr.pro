PRO generate_pixel_indices_for_sphere_in_3darr, xsize, ysize, zsize, x0, y0, z0, r, xind, yind, zind, subs, nind, status, EXCLUDE_BORDER = exclude_border, $
                                                NO_SUBS = no_subs, NO_PAR_CHECK = no_par_check

; Description: This module generates a set of x, y and z pixel indices "xind", "yind" and "zind", respectively,
;              for a spherical region in a data cube array of size "xsize" by "ysize" by "zsize" pixels. The
;              spherical region is defined as the set of pixels for which the distance between their centre and
;              the coordinates "(x0,y0,z0)" is less than or equal to "r" pixels. In mathematical terms, this
;              constraint is given by:
;
;              (x_i - x0)^2 + (y_j - y0)^2 + (z_k - z0)^2 <= r^2                (1)
;
;              where "(x_i,y_j,z_k)" are the coordinates of a pixel with pixel index coordinates "(i,j,k)". A
;              pixel has a centre that lies on the border of the spherical region when the constraint is
;              satisfied as an equality. Note that the module does not require that the spherical region is
;              fully encompassed by the data cube volume in order to generate the pixel indices "xind", "yind"
;              and "zind".
;                The module provides the option of excluding those pixels whose centres lie on the border of
;              the spherical region from the set of x, y and z pixel indices "xind", "yind" and "zind". This
;              is equivalent to changing the constraint "<= r^2" to "< r^2" in equation (1). This behaviour
;              may be achieved by setting the keyword EXCLUDE_BORDER.
;                By default, the module also returns the data cube subscripts "subs" corresponding to the set
;              of x, y and z pixel indices "xind", "yind" and "zind". However, if these subscripts are not
;              required, then the module can be instructed not to generate them by setting the keyword NO_SUBS,
;              which leads to a faster execution of this module.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The data cube size (pix) along the x-axis. This parameter must be positive.
;   ysize - INTEGER/LONG - The data cube size (pix) along the y-axis. This parameter must be positive.
;   zsize - INTEGER/LONG - The data cube size (pix) along the z-axis. This parameter must be positive.
;   x0 - FLOAT/DOUBLE - The x coordinate (pix) of the centre of the spherical region.
;   y0 - FLOAT/DOUBLE - The y coordinate (pix) of the centre of the spherical region.
;   z0 - FLOAT/DOUBLE - The z coordinate (pix) of the centre of the spherical region.
;   r - FLOAT/DOUBLE - The radius (pix) of the spherical region. This parameter must be non-negative.
;
; Output Parameters:
;
;   xind - LONG VECTOR - A one-dimensional vector with "nind" elements representing the pixel indices along
;                        the data cube x-axis for the required spherical region in a data cube array of size
;                        "xsize" by "ysize" by "zsize" pixels. All elements in this parameter are non-negative
;                        and less than "xsize". If the overlap region between the spherical region and the
;                        data cube volume is empty, then this parameter is set to the single-element vector
;                        "[-1L]".
;   yind - LONG VECTOR - A one-dimensional vector with "nind" elements representing the pixel indices along
;                        the data cube y-axis for the required spherical region in a data cube array of size
;                        "xsize" by "ysize" by "zsize" pixels. All elements in this parameter are non-negative
;                        and less than "ysize". If the overlap region between the spherical region and the
;                        data cube volume is empty, then this parameter is set to the single-element vector
;                        "[-1L]".
;   zind - LONG VECTOR - A one-dimensional vector with "nind" elements representing the pixel indices along
;                        the data cube z-axis for the required spherical region in a data cube array of size
;                        "xsize" by "ysize" by "zsize" pixels. All elements in this parameter are non-negative
;                        and less than "zsize". If the overlap region between the spherical region and the
;                        data cube volume is empty, then this parameter is set to the single-element vector
;                        "[-1L]".
;   subs - LONG VECTOR - A one-dimensional vector with "nind" elements representing the data cube subscripts
;                        for the required spherical region in a data cube array of size "xsize" by "ysize"
;                        by "zsize" pixels. All elements in this parameter are non-negative. If the overlap
;                        region between the spherical region and the data cube volume is empty, or if the
;                        keyword NO_SUBS is set, then this parameter is set to the single-element vector
;                        "[-1L]".
;   nind - LONG - The number of elements in each of the output parameters "xind", "yind", "zind" and "subs".
;                 If the overlap region between the spherical region and the data cube volume is empty, then
;                 this parameter is set to "0L".
;   status - INTEGER - If the module successfully generated the set of x, y and z pixel indices, then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword EXCLUDE_BORDER is set (as "/EXCLUDE_BORDER"), then the module will exclude those pixels
;   whose centres lie on the border of the spherical region from the set of x, y and z pixel indices "xind",
;   "yind" and "zind". This is equivalent to changing the constraint "<= r^2" to "< r^2" in equation (1).
;
;   If the keyword NO_SUBS is set (as "/NO_SUBS"), then the module will not generate the data cube subscripts
;   "subs", and this parameter will be returned as the single-element vector "[-1L]". Set this keyword if
;   the data cube subscripts are not required in order to obtain a faster execution of this module.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
xind = [-1L]
yind = [-1L]
zind = [-1L]
subs = [-1L]
nind = 0L
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "xsize", "ysize" and "zsize" are positive numbers of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return
  if (test_intlon_scalar(ysize) NE 1) then return
  if (test_intlon_scalar(zsize) NE 1) then return
  if (xsize LT 1) then return
  if (ysize LT 1) then return
  if (zsize LT 1) then return

  ;Check that "x0", "y0", "z0" and "r" are all numbers of the correct type, and that "r" is non-negative
  if (test_fltdbl_scalar(x0) NE 1) then return
  if (test_fltdbl_scalar(y0) NE 1) then return
  if (test_fltdbl_scalar(z0) NE 1) then return
  if (test_fltdbl_scalar(r) NE 1) then return
  if (r LT 0.0) then return
endif
xsize_use = long(xsize)
ysize_use = long(ysize)
zsize_use = long(zsize)
x0_use = double(x0)
y0_use = double(y0)
z0_use = double(z0)
r_use = double(r)

;Set "status" to "1"
status = 1

;Determine the bounding box for the spherical region
xlo = floor(x0_use - r_use)
xhi = floor(x0_use + r_use)
ylo = floor(y0_use - r_use)
yhi = floor(y0_use + r_use)
zlo = floor(z0_use - r_use)
zhi = floor(z0_use + r_use)

;Determine the overlap region between the bounding box and the data cube volume
determine_rectangular_cuboid_overlap_3d, xlo, xhi, ylo, yhi, zlo, zhi, 0L, xsize_use - 1L, 0L, ysize_use - 1L, 0L, zsize_use - 1L, oxlo, oxhi, oylo, oyhi, ozlo, ozhi, $
                                         etag, stat

;If the overlap region between the bounding box and the data cube volume is empty, then return an empty
;set of pixel indices
if (etag NE 1) then return

;Determine the squared distance of each pixel in the overlap region between the bounding box and the data
;cube volume from the pixel coordinates "(x0,y0,z0)"
oxs = oxhi - oxlo + 1L
oys = oyhi - oylo + 1L
ozs = ozhi - ozlo + 1L
create_euclidean_distance_3darr, oxs, oys, ozs, x0_use - double(oxlo), y0_use - double(oylo), z0_use - double(ozlo), dist2_arr, stat, /SQUARED_DISTANCE, /NO_PAR_CHECK

;Generate the subscripts for the spherical region within the overlap region between the bounding box and the
;data cube volume
if keyword_set(exclude_border) then begin
  csubs = where(dist2_arr LT (r_use*r_use), ncsubs)
endif else csubs = where(dist2_arr LE (r_use*r_use), ncsubs)

;If there are no pixels with their centres in the spherical region, then return an empty set of pixel indices
if (ncsubs EQ 0L) then return

;Generate the x, y and z pixel indices for the spherical region in the data cube array
convert_3darr_subscripts_to_pixel_indices, csubs, oxs, oys, xind, yind, zind, nind, stat, /NO_PAR_CHECK
if (oxlo NE 0L) then xind = temporary(xind) + oxlo
if (oylo NE 0L) then yind = temporary(yind) + oylo
if (ozlo NE 0L) then zind = temporary(zind) + ozlo

;If required, then generate the data cube subscripts for the spherical region
if ~keyword_set(no_subs) then convert_pixel_indices_to_3darr_subscripts, xind, yind, zind, xsize_use, ysize_use, subs, nsubs, stat, /NO_PAR_CHECK

END
