PRO calculate_interpolation_coeffs_1dvec, vdata, poles, tol, coeffs, status, danidl_cppcode, NO_PAR_CHECK = no_par_check

; Description: This module calculates the vector of interpolation coefficients "coeffs" for an input
;              vector of data "vdata" and an interpolation scheme with filter poles "poles". The type
;              of boundary extension assumed in this module is that of whole-sample symmetric (or
;              mirror) extension (i.e. data values "1 2 3 4 5" are extended to
;              "...4 3 2 1 2 3 4 5 4 3 2..."). The calculation of the initial value of the causal
;              coefficient can be speeded up by setting the value of "tol" to a positive number greater
;              than "0.0" but less than "1.0", which represents the maximum acceptable relative error
;              during the filtering process.
;                This module will use C++ code if possible to achieve a much faster execution than the
;              default IDL code. The C++ code is an astounding factor of ~28 times faster than the IDL
;              code in this case.
;
;              N.B: (i) The code in this module has been developed using the material in the following
;                       references:
;
;                       (a) "Image Interpolation and Resampling", Thevenaz P., Blu T. & Unser M., 2000,
;                           Handbook Of Medical Imaging, Processing And Analysis, Editor: Bankman I.N.,
;                           Academic Press, San Diego CA, USA, 393-420
;
;                       (b) "Linear Methods for Image Interpolation", Getreuer P., 2011, Image
;                           Processing On Line, 1, http://dx.doi.org/10.5201/ipol.2011.g_lmii
;
;                       I have also checked carefully that the implementation in this module matches the
;                       mathematical theory and methods described in the above references.
;
;                   (ii) The implementation of variance propagation in an associated "_werr.pro" module
;                        is feasible, but it has not been done yet due to the lack of a clear use-case
;                        scenario.
;
;                   (iii) The implementation of bad pixel mask propagation in an associated "_werr.pro"
;                         module does not make sense since each output interpolation coefficient depends
;                         on all of the data values in "vdata". This means that a single bad data value
;                         in "vdata" would propagate to all of the output interpolation coefficients.
;                         It is therefore desirable that all bad pixels in the input data "vdata" are
;                         replaced with reasonable values before calculating the interpolation
;                         coefficients.
;
; Input Parameters:
;
;   vdata - FLOAT/DOUBLE VECTOR - A one-dimensional data vector for which the interpolation coefficients
;                                 are to be calculated. Note that this data vector should not contain
;                                 bad data values because all of the data values are used in the
;                                 calculation of each of the interpolation coefficients.
;   poles - FLOAT/DOUBLE VECTOR - A one-dimensional vector of values for the poles required for the
;                                 recursive filter. The elements of this vector must be non-zero. A list
;                                 of the pole values required for each interpolation scheme are reported
;                                 here for convenience:
;
;           Interpolation Scheme:  No. Poles:  First Pole:                             Second Pole:                            Third Pole:           Fourth Pole:
;
;           Quadratic B-splines    1           sqrt(8)-3
;           Cubic B-Splines        1           sqrt(3)-2
;           Quartic B-Splines      2           sqrt(664-sqrt(438976))+sqrt(304)-19     sqrt(664+sqrt(438976))-sqrt(304)-19
;           Quintic B-Splines      2           (sqrt(270-sqrt(70980))+sqrt(105)-13)/2  (sqrt(270+sqrt(70980))-sqrt(105)-13)/2
;           Septic B-Splines       3           -0.535280430796438                      -0.122554615192327                      -0.00914869480960828
;           Nonic B-Splines        4           -0.607997389168626                      -0.201750520193153                      -0.0432226085404818   -0.00212130690318082
;           Cubic O-MOMS           1           (sqrt(105)-13)/8
;           Quintic O-MOMS         2           -0.475812710008440                      -0.0709257189686854
;           Septic O-MOMS          3           -0.568537618002293                      -0.155700774677358                      -0.0197684253838614
;
;   tol - FLOAT/DOUBLE - The maximum acceptable relative error during the filtering process. By setting
;                        this parameter to a positive value greater than "0.0" but less than "1.0", the
;                        initial value of the causal coefficient is calculated from a subset of data
;                        values, while achieving the acceptable relative error "tol". By setting this
;                        parameter to any other value, including "0.0", the initial value of the causal
;                        coefficient is calculated exactly from all of the data values in the data vector.
;   danidl_cppcode - STRING - The full directory path indicating where the DanIDL C++ code is installed.
;                             The shared library of DanIDL C++ routines should exist as
;                             "<danidl_cppcode>/dist/libDanIDL.so" within the installation. If this input
;                             parameter is not specified correctly, then the default IDL code will be
;                             used instead.
;
; Output Parameters:
;
;   coeffs - DOUBLE VECTOR - A one-dimensional vector of the same length as "vdata" that contains the
;                            interpolation coefficients for "vdata" for the interpolation scheme with
;                            filter poles "poles".
;   status - INTEGER - If the vector of interpolation coefficients "coeffs" was calculated successfully,
;                      then "status" is returned with a value of "1", otherwise it is returned with a
;                      value of "0".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter
;   checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
coeffs = [0.0D]
status = 0

;If parameter checking is not required
if keyword_set(no_par_check) then begin

  ;Determine the length of "vdata"
  vsize = vdata.length

  ;Convert the input parameter "poles" and determine the number of poles
  poles_use = double(poles)
  npoles = poles.length

;If parameter checking is required
endif else begin

  ;Check that "vdata" is a one-dimensional vector of the correct number type
  test_fltdbl_1dvec, vdata, vstat, vsize, vtype
  if (vstat EQ 0) then return

  ;Check that "poles" is a one-dimensional vector of the correct number type, and that it has no zero values
  test_fltdbl_1dvec, poles, vstat, npoles, vtype
  if (vstat EQ 0) then return
  poles_use = double(poles)
  if (test_set_membership(0.0D, poles_use, /NO_PAR_CHECK) EQ 1) then return

  ;Check that "tol" is a number of the correct type
  if (test_fltdbl_scalar(tol) NE 1) then return
endelse
npoles = fix(npoles)
tol_use = double(tol)

;Set up the output vector of interpolation coefficients "coeffs"
coeffs = double(vdata)

;If there is only one input data point, then return "coeffs" without any filtering
if (vsize EQ 1L) then begin
  status = 1
  return
endif

;Determine if the shared library of DanIDL C++ routines is installed
test_danidl_cppcode, danidl_cppcode, danidl_cpp_shared_lib, danidl_cppstat

;If the shared library of DanIDL C++ routines is installed, then use the C++ code to speed up the calculation
;of the interpolation coefficients
if (danidl_cppstat EQ 1) then begin

  ;Calculate the interpolation coefficients
  result = call_external(danidl_cpp_shared_lib, 'calculate_interpolation_coeffs_1dvec', vsize, coeffs, npoles, poles_use, tol_use)

;If the shared library of DanIDL C++ routines is not installed, then use the default IDL code
endif else begin

  ;Compute the overall gain, and apply this gain to the interpolation coefficients
  lambda = product(2.0D - poles_use - (1.0D/poles_use))
  coeffs = temporary(coeffs)*lambda

  ;Calculate the lengths of the required sums
  if ((tol_use GT 0.0D) AND (tol_use LT 1.0D)) then begin
    maxn = ceil(alog(tol_use)/alog(abs(poles_use))) > 2L
  endif else maxn = replicate(vsize, npoles)

  ;For each pole
  vsize_m1 = vsize - 1L
  vsize_m2 = vsize_m1 - 1L
  for i = 0,(npoles - 1) do begin

    ;Extract the value of the current pole and the length of the corresponding sum
    cz = poles_use[i]
    cmaxn = maxn[i]

    ;If the length of the sum is less than the length of "vdata"
    if (cmaxn LT vsize) then begin

      ;Calculate the initial value of the causal coefficient using a truncated sum and store it
      coeffs[0] = calculate_dot_product_of_two_vectors(cz^lindgen(cmaxn), coeffs[0L:(cmaxn - 1L)], stat, /NO_PAR_CHECK)

    ;If the length of the sum is greater than or equal to the length of "vdata"
    endif else begin

      ;Calculate the initial value of the causal coefficient using a full sum and store it
      w1 = cz^lindgen(vsize)
      w2 = reverse(w1[vsize_m1]*w1)
      fac = 1.0D - w2[0]
      w2[0] = 0.0D
      w2[vsize_m1] = 0.0D
      coeffs[0] = calculate_dot_product_of_two_vectors(w1 + w2, coeffs, stat, /NO_PAR_CHECK)/fac
    endelse

    ;Execute the causal recursion on the interpolation coefficients
    for j = 1L,vsize_m1 do coeffs[j] = coeffs[j] + (cz*coeffs[j - 1L])

    ;Calculate the initial value of the anti-causal coefficient
    coeffs[vsize_m1] = (cz/((cz*cz) - 1.0D))*((cz*coeffs[vsize_m2]) + coeffs[vsize_m1])

    ;Execute the anti-causal recursion on the interpolation coefficients
    for j = vsize_m2,0L,-1L do coeffs[j] = cz*(coeffs[j + 1L] - coeffs[j])
  endfor
endelse

;Set "status" to "1"
status = 1

END
