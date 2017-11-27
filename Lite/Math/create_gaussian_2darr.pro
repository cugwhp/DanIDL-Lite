FUNCTION create_gaussian_2darr, xsize, ysize, x0, y0, sig_a, sig_b, theta, hires, status, NORMALISE_BY_MAX = normalise_by_max, NORMALISE_BY_SUM = normalise_by_sum, $
                                NORMALISE_BY_INTEGRAL = normalise_by_integral, NO_PAR_CHECK = no_par_check

; Description: This function creates a two-dimensional output pixel array of size "xsize" by "ysize"
;              pixels representing an elliptical Gaussian profile with major and minor axes that have
;              sigma values of "sig_a" and "sig_b" pixels, respectively. The elliptical Gaussian profile
;              has its centre at the coordinates "(x0,y0)" and is orientated such that its major axis is
;              inclined at an angle of "theta" degrees as measured anti-clockwise from the x-axis. The
;              equation of the elliptical Gaussian profile G(x,y) is given by:
;
;              G(x,y) = exp(-0.5*((((x - x0)*cos(theta) + (y - y0)*sin(theta))/sig_a)^2 + (((y - y0)*cos(theta) - (x - x0)*sin(theta))/sig_b)^2))
;
;                The pixel values are calculated from a pixel grid that samples the Gaussian profile at
;              "hires" times the resolution of the output pixel array, which gives the user the option
;              of accurately calculating the integrals over the discrete pixels. The function also
;              provides the option of normalising the Gaussian profile by its peak pixel value, by the
;              sum of its pixel values, or by its analytical integral over the real number plane via the
;              use of the keywords NORMALISE_BY_MAX, NORMALISE_BY_SUM, and NORMALISE_BY_INTEGRAL,
;              respectively. Note that the analytical integral of G(x,y) over the real number plane is
;              "2*pi*sig_a*sig_b".
;
;              N.B: The implementation of variance propagation in an associated "_werr.pro" function is
;                   feasible, but it has not been done yet due to the lack of a clear use-case scenario.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The size (pix) of the output pixel array along the x-axis. This parameter
;                          must be positive.
;   ysize - INTEGER/LONG - The size (pix) of the output pixel array along the y-axis. This parameter
;                          must be positive.
;   x0 - FLOAT/DOUBLE - The x coordinate (pix) of the centre of the elliptical Gaussian profile.
;   y0 - FLOAT/DOUBLE - The y coordinate (pix) of the centre of the elliptical Gaussian profile.
;   sig_a - FLOAT/DOUBLE - The value of sigma (pix) along the major axis of the elliptical Gaussian
;                          profile. This parameter must be positive.
;   sig_b - FLOAT/DOUBLE - The value of sigma (pix) along the minor axis of the elliptical Gaussian
;                          profile. This parameter must be positive.
;   theta - FLOAT/DOUBLE - The angle (degrees) as measured anti-clockwise from the x-axis to the major
;                          axis of the elliptical Gaussian profile.
;   hires - INTEGER/LONG - The oversampling factor to be used to calculate the output pixel array. This
;                          parameter must be positive. The minimum allowed value of "1" corresponds to
;                          no oversampling. Care should be taken with setting "hires" to large values
;                          due to the risk of running out of memory.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully created the output array representing the required
;                      Gaussian profile, then "status" is returned with a value of "1", otherwise it is
;                      returned with a value of "0".
;
; Return Value:
;
;   The function returns a two-dimensional array of DOUBLE type numbers of size "xsize" by "ysize"
;   pixels that contains the required elliptical Gaussian profile. Note that if "ysize" is set to "1",
;   then the function will return a one-dimensional vector of length "xsize" pixels since IDL treats
;   an Nx1 array as an N-element one-dimensional vector.
;
; Keywords:
;
;   If the keyword NORMALISE_BY_MAX is set (as "/NORMALISE_BY_MAX"), then the output Gaussian profile
;   is normalised to a peak pixel value of "1.0". Note that the keywords NORMALISE_BY_MAX,
;   NORMALISE_BY_SUM and NORMALISE_BY_INTEGRAL cannot be set at the same time.
;
;   If the keyword NORMALISE_BY_SUM is set (as "/NORMALISE_BY_SUM"), then the output Gaussian profile
;   is normalised such that the sum of its pixel values is "1.0". Note that the keywords
;   NORMALISE_BY_MAX, NORMALISE_BY_SUM and NORMALISE_BY_INTEGRAL cannot be set at the same time.
;
;   If the keyword NORMALISE_BY_INTEGRAL is set (as "/NORMALISE_BY_INTEGRAL"), then the output Gaussian
;   profile is normalised by its analytical integral over the real number plane "2*pi*sig_a*sig_b".
;   Note that the keywords NORMALISE_BY_MAX, NORMALISE_BY_SUM and NORMALISE_BY_INTEGRAL cannot be set
;   at the same time.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "xsize" and "ysize" are positive numbers of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return, 0.0D
  if (test_intlon_scalar(ysize) NE 1) then return, 0.0D
  if (xsize LT 1) then return, 0.0D
  if (ysize LT 1) then return, 0.0D

  ;Check that "x0" and "y0" are numbers of the correct type
  if (test_fltdbl_scalar(x0) NE 1) then return, 0.0D
  if (test_fltdbl_scalar(y0) NE 1) then return, 0.0D

  ;Check that "sig_a" and "sig_b" are positive numbers of the correct type
  if (test_fltdbl_scalar(sig_a) NE 1) then return, 0.0D
  if (test_fltdbl_scalar(sig_b) NE 1) then return, 0.0D
  if (sig_a LE 0.0) then return, 0.0D
  if (sig_b LE 0.0) then return, 0.0D

  ;Check that "theta" is a number of the correct type
  if (test_fltdbl_scalar(theta) NE 1) then return, 0.0D

  ;Check that "hires" is a positive number of the correct type
  if (test_intlon_scalar(hires) NE 1) then return, 0.0D
  if (hires LT 1) then return, 0.0D

  ;Check that the keywords NORMALISE_BY_MAX, NORMALISE_BY_SUM and NORMALISE_BY_INTEGRAL are not set at the
  ;same time
  if (keyword_set(normalise_by_max) AND keyword_set(normalise_by_sum)) then return, 0.0D
  if (keyword_set(normalise_by_max) AND keyword_set(normalise_by_integral)) then return, 0.0D
  if (keyword_set(normalise_by_sum) AND keyword_set(normalise_by_integral)) then return, 0.0D
endif
sig_a_use = double(sig_a)
sig_b_use = double(sig_b)
hires_use = long(hires)

;Generate the coordinate vectors for the oversampled pixel array
create_pixel_coordinates_1dvec, xsize, 1.0D, x0, hires_use, xc, stat, /NO_PAR_CHECK
create_pixel_coordinates_1dvec, ysize, 1.0D, y0, hires_use, yc, stat, /NO_PAR_CHECK

;If the major and minor axes of the Gaussian profile have the same sigma values, then the Gaussian profile
;is circular
if (sig_b_use EQ sig_a_use) then begin

  ;Calculate the values of the circular Gaussian profile for the oversampled pixel array, and if necessary,
  ;bin the oversampled pixel array by the oversampling factor "hires". Also, if required, normalise the
  ;output Gaussian profile appropriately.
  tmp_fac = -0.5D/(sig_a_use*sig_a_use)
  if (hires_use GT 1L) then begin
    xc = rebin(exp(tmp_fac*(xc*xc)), xsize)
    yc = rebin(exp(tmp_fac*(yc*yc)), ysize)
  endif else begin
    xc = exp(tmp_fac*(xc*xc))
    yc = exp(tmp_fac*(yc*yc))
  endelse
  if keyword_set(normalise_by_max) then begin
    garr = calculate_outer_product_of_two_vectors(xc, yc*(1.0D/(max(xc)*max(yc))), stat, /NO_PAR_CHECK)
  endif else if keyword_set(normalise_by_sum) then begin
    garr = calculate_outer_product_of_two_vectors(xc, yc*(1.0D/(total(xc, /DOUBLE)*total(yc, /DOUBLE))), stat, /NO_PAR_CHECK)
  endif else if keyword_set(normalise_by_integral) then begin
    garr = calculate_outer_product_of_two_vectors(xc, yc*(-tmp_fac/get_dbl_pi()), stat, /NO_PAR_CHECK)
  endif else garr = calculate_outer_product_of_two_vectors(xc, yc, stat, /NO_PAR_CHECK)

  ;Set "status" to "1" and return the Gaussian profile
  status = 1
  return, garr
endif

;The rest of the code deals with the case where the major and minor axes of the Gaussian profile do not have
;the same sigma values and the Gaussian profile is elliptical. If "theta" is a multiple of 180 degrees.
theta_use = double(theta)
theta_mod_180 = abs(theta_use mod 180.0D)
if (theta_mod_180 EQ 0.0D) then begin

  ;Calculate the values of the elliptical Gaussian profile for the oversampled pixel array, and if necessary,
  ;bin the oversampled pixel array by the oversampling factor "hires". Also, if required, normalise the
  ;output Gaussian profile appropriately.
  if (hires_use GT 1L) then begin
    xc = rebin(exp((-0.5D/(sig_a_use*sig_a_use))*(xc*xc)), xsize)
    yc = rebin(exp((-0.5D/(sig_b_use*sig_b_use))*(yc*yc)), ysize)
  endif else begin
    xc = exp((-0.5D/(sig_a_use*sig_a_use))*(xc*xc))
    yc = exp((-0.5D/(sig_b_use*sig_b_use))*(yc*yc))
  endelse
  if keyword_set(normalise_by_max) then begin
    garr = calculate_outer_product_of_two_vectors(xc, yc*(1.0D/(max(xc)*max(yc))), stat, /NO_PAR_CHECK)
  endif else if keyword_set(normalise_by_sum) then begin
    garr = calculate_outer_product_of_two_vectors(xc, yc*(1.0D/(total(xc, /DOUBLE)*total(yc, /DOUBLE))), stat, /NO_PAR_CHECK)
  endif else if keyword_set(normalise_by_integral) then begin
    garr = calculate_outer_product_of_two_vectors(xc, yc*(0.5D/(get_dbl_pi()*sig_a_use*sig_b_use)), stat, /NO_PAR_CHECK)
  endif else garr = calculate_outer_product_of_two_vectors(xc, yc, stat, /NO_PAR_CHECK)

;If "theta" plus 90 degrees is a multiple of 180 degrees
endif else if (theta_mod_180 EQ 90.0D) then begin

  ;Calculate the values of the elliptical Gaussian profile for the oversampled pixel array, and if necessary,
  ;bin the oversampled pixel array by the oversampling factor "hires". Also, if required, normalise the
  ;output Gaussian profile appropriately.
  if (hires_use GT 1L) then begin
    xc = rebin(exp((-0.5D/(sig_b_use*sig_b_use))*(xc*xc)), xsize)
    yc = rebin(exp((-0.5D/(sig_a_use*sig_a_use))*(yc*yc)), ysize)
  endif else begin
    xc = exp((-0.5D/(sig_b_use*sig_b_use))*(xc*xc))
    yc = exp((-0.5D/(sig_a_use*sig_a_use))*(yc*yc))
  endelse
  if keyword_set(normalise_by_max) then begin
    garr = calculate_outer_product_of_two_vectors(xc, yc*(1.0D/(max(xc)*max(yc))), stat, /NO_PAR_CHECK)
  endif else if keyword_set(normalise_by_sum) then begin
    garr = calculate_outer_product_of_two_vectors(xc, yc*(1.0D/(total(xc, /DOUBLE)*total(yc, /DOUBLE))), stat, /NO_PAR_CHECK)
  endif else if keyword_set(normalise_by_integral) then begin
    garr = calculate_outer_product_of_two_vectors(xc, yc*(0.5D/(get_dbl_pi()*sig_a_use*sig_b_use)), stat, /NO_PAR_CHECK)
  endif else garr = calculate_outer_product_of_two_vectors(xc, yc, stat, /NO_PAR_CHECK)

;If "theta" has any other value
endif else begin

  ;Calculate some useful quantities
  theta_rad = deg2rad(theta_use, stat, /NO_PAR_CHECK)
  sin_theta = sin(theta_rad)
  cos_theta = cos(theta_rad)

  ;Calculate the values of the elliptical Gaussian profile for the oversampled pixel array
  coord_arr1 = calculate_outer_sum_of_two_vectors(xc*(cos_theta/sig_a_use), yc*(sin_theta/sig_a_use), stat, /NO_PAR_CHECK)
  coord_arr2 = calculate_outer_sum_of_two_vectors(xc*(-sin_theta/sig_b_use), yc*(cos_theta/sig_b_use), stat, /NO_PAR_CHECK)
  garr = exp(-0.5D*((coord_arr1*coord_arr1) + (coord_arr2*coord_arr2)))

  ;If necessary, bin the oversampled pixel array by the oversampling factor "hires"
  if (hires_use GT 1L) then garr = rebin(garr, xsize, ysize)

  ;If required, normalise the output Gaussian profile appropriately
  if keyword_set(normalise_by_max) then begin
    i_max_garr = 1.0D/max(garr)
    garr = temporary(garr)*i_max_garr
  endif else if keyword_set(normalise_by_sum) then begin
    i_tot_garr = 1.0D/total(garr, /DOUBLE)
    garr = temporary(garr)*i_tot_garr
  endif else if keyword_set(normalise_by_integral) then garr = temporary(garr)*(0.5D/(get_dbl_pi()*sig_a_use*sig_b_use))
endelse

;Set "status" to "1"
status = 1

;Return the Gaussian profile
return, garr

END
