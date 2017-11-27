FUNCTION create_gaussian_1dvec, xsize, x0, sig, hires, status, NORMALISE_BY_MAX = normalise_by_max, NORMALISE_BY_SUM = normalise_by_sum, $
                                NORMALISE_BY_INTEGRAL = normalise_by_integral, NO_PAR_CHECK = no_par_check

; Description: This function creates a one-dimensional output pixel vector of length "xsize" pixels
;              representing a Gaussian profile with a sigma value of "sig" pixels. The Gaussian profile
;              has its centre at the x coordinate "x0". The equation of the Gaussian profile G(x) is
;              given by:
;
;              G(x) = exp(-0.5*((x - x0)/sig)^2)
;
;                The pixel values are calculated from a pixel grid that samples the Gaussian profile at
;              "hires" times the resolution of the output pixel vector, which gives the user the option
;              of accurately calculating the integrals over the discrete pixels. The function also
;              provides the option of normalising the Gaussian profile by its peak pixel value, by the
;              sum of its pixel values, or by its analytical integral over the real number line via the
;              use of the keywords NORMALISE_BY_MAX, NORMALISE_BY_SUM, and NORMALISE_BY_INTEGRAL,
;              respectively. Note that the analytical integral of G(x) over the real number line is
;              "sqrt(2*pi)*sig".
;
;              N.B: The implementation of variance propagation in an associated "_werr.pro" function is
;                   feasible, but it has not been done yet due to the lack of a clear use-case scenario.
;
; Input Parameters:
;
;   xsize - INTEGER/LONG - The length (pix) of the output pixel vector along the x-axis. This parameter
;                          must be positive.
;   x0 - FLOAT/DOUBLE - The x coordinate (pix) of the centre of the Gaussian profile.
;   sig - FLOAT/DOUBLE - The value of sigma (pix) for the Gaussian profile. This parameter must be
;                        positive.
;   hires - INTEGER/LONG - The oversampling factor to be used to calculate the output pixel vector. This
;                          parameter must be positive. The minimum allowed value of "1" corresponds to
;                          no oversampling.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully created the output vector representing the required
;                      Gaussian profile, then "status" is returned with a value of "1", otherwise it is
;                      returned with a value of "0".
;
; Return Value:
;
;   The function returns a one-dimensional vector of DOUBLE type numbers of length "xsize" pixels that
;   contains the required Gaussian profile.
;
; Keywords:
;
;   If the keyword NORMALISE_BY_MAX is set (as "/NORMALISE_BY_MAX"), then the output Gaussian profile is
;   normalised to a peak pixel value of "1.0". Note that the keywords NORMALISE_BY_MAX, NORMALISE_BY_SUM
;   and NORMALISE_BY_INTEGRAL cannot be set at the same time.
;
;   If the keyword NORMALISE_BY_SUM is set (as "/NORMALISE_BY_SUM"), then the output Gaussian profile is
;   normalised such that the sum of its pixel values is "1.0". Note that the keywords NORMALISE_BY_MAX,
;   NORMALISE_BY_SUM and NORMALISE_BY_INTEGRAL cannot be set at the same time.
;
;   If the keyword NORMALISE_BY_INTEGRAL is set (as "/NORMALISE_BY_INTEGRAL"), then the output Gaussian
;   profile is normalised by its analytical integral over the real number line "sqrt(2*pi)*sig". Note
;   that the keywords NORMALISE_BY_MAX, NORMALISE_BY_SUM and NORMALISE_BY_INTEGRAL cannot be set at the
;   same time.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "xsize" is a positive number of the correct type
  if (test_intlon_scalar(xsize) NE 1) then return, [0.0D]
  if (xsize LT 1) then return, [0.0D]

  ;Check that "x0" is a number of the correct type
  if (test_fltdbl_scalar(x0) NE 1) then return, [0.0D]

  ;Check that "sig" is a positive number of the correct type
  if (test_fltdbl_scalar(sig) NE 1) then return, [0.0D]
  if (sig LE 0.0) then return, [0.0D]

  ;Check that "hires" is a positive number of the correct type
  if (test_intlon_scalar(hires) NE 1) then return, [0.0D]
  if (hires LT 1) then return, [0.0D]

  ;Check that the keywords NORMALISE_BY_MAX, NORMALISE_BY_SUM and NORMALISE_BY_INTEGRAL are not set at the
  ;same time
  if (keyword_set(normalise_by_max) AND keyword_set(normalise_by_sum)) then return, [0.0D]
  if (keyword_set(normalise_by_max) AND keyword_set(normalise_by_integral)) then return, [0.0D]
  if (keyword_set(normalise_by_sum) AND keyword_set(normalise_by_integral)) then return, [0.0D]
endif
i_sig_use = sqrt(0.5D)/double(sig)
hires_use = long(hires)

;Generate the coordinate vector for the oversampled pixel vector
create_pixel_coordinates_1dvec, xsize, i_sig_use, x0, hires_use, gvec, stat, /NO_PAR_CHECK

;Calculate the values of the Gaussian profile for the oversampled pixel vector, and if necessary, bin the
;oversampled pixel vector by the oversampling factor "hires"
if (hires_use GT 1L) then begin
  gvec = rebin(exp(-(gvec*gvec)), xsize)
endif else gvec = exp(-(gvec*gvec))

;If required, normalise the output Gaussian profile appropriately
if keyword_set(normalise_by_max) then begin
  i_max_gvec = 1.0D/max(gvec)
  gvec = temporary(gvec)*i_max_gvec
endif else if keyword_set(normalise_by_sum) then begin
  i_tot_gvec = 1.0D/total(gvec, /DOUBLE)
  gvec = temporary(gvec)*i_tot_gvec
endif else if keyword_set(normalise_by_integral) then gvec = temporary(gvec)*(i_sig_use/sqrt(get_dbl_pi()))

;Set "status" to "1"
status = 1

;Return the Gaussian profile
return, gvec

END
