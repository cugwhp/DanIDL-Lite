FUNCTION set_1dvec_border_to_value, vdata, border_value, xlo_bw, xhi_bw, status, NO_PAR_CHECK = no_par_check

; Description: This function sets the pixel values in a border at each end of a pixel vector "vdata" to the
;              value specified by the parameter "border_value". The thickness of the required border (pix)
;              at the left and right hand ends of the vector is defined by the input parameters "xlo_bw" and
;              "xhi_bw", respectively.
;
; Input Parameters:
;
;   vdata - BYTE/INTEGER/LONG/FLOAT/DOUBLE VECTOR - A one-dimensional vector for which the border pixel
;                                                   values at each end are to be replaced.
;   border_value - BYTE/INTEGER/LONG/FLOAT/DOUBLE - The pixel value to be used to replace the pixel values
;                                                   in the required border at each end of the pixel vector
;                                                   "vdata". This input parameter will be converted to
;                                                   match the variable type of the vector data "vdata"
;                                                   before being used to replace the pixel values in "vdata".
;   xlo_bw - INTEGER/LONG - The thickness of the required border (pix) at the left hand end of the vector.
;                           If this parameter is zero or negative, then no border pixels at the left hand
;                           end of the vector will be modified.
;   xhi_bw - INTEGER/LONG - The thickness of the required border (pix) at the right hand end of the vector.
;                           If this parameter is zero or negative, then no border pixels at the right hand
;                           end of the vector will be modified.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully replaced the pixel values in the required border at each
;                      end of the input vector, then "status" is returned with a value of "1", otherwise it
;                      is returned with a value of "0".
;
; Return Value:
;
;   The return value is a modified version of the pixel vector "vdata" where the required border pixel values
;   at each end have been replaced with the value specified by "border_value". Therefore the return value is
;   also a one-dimensional vector of the same length and number type as "vdata".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;If parameter checking is not required
if keyword_set(no_par_check) then begin

  ;Determine the length of "vdata"
  vsize = vdata.length

;If parameter checking is required
endif else begin

  ;Check that "vdata" is a vector of the correct number type
  test_bytintlonfltdbl_1dvec, vdata, vstat, vsize, vtype
  if (vstat EQ 0) then return, [0.0D]

  ;Check that "border_value" is a number of the correct type
  if (test_bytintlonfltdbl_scalar(border_value) NE 1) then return, [0.0D]

  ;Check that "xlo_bw" and "xhi_bw" are numbers of the correct type
  if (test_intlon_scalar(xlo_bw) NE 1) then return, [0.0D]
  if (test_intlon_scalar(xhi_bw) NE 1) then return, [0.0D]
endelse
xlo_bw_use = long(xlo_bw) > 0L
xhi_bw_use = long(xhi_bw) > 0L

;Set up the output vector
vec_out = vdata

;If the thickness of the required border covers all of the vector pixels
if ((xlo_bw_use + xhi_bw_use) GE vsize) then begin

  ;Set all of the vector pixels to the value specified by "border_value"
  replicate_inplace, vec_out, border_value

;If the thickness of the required border does not cover all of the vector pixels
endif else begin

  ;If the border at the left hand end of the vector is at least one pixel thick, then replace the pixel
  ;values in this border range with the value specified by "border_value"
  if (xlo_bw_use GT 0L) then vec_out[0L:(xlo_bw_use - 1L)] = border_value

  ;If the border at the right hand end of the vector is at least one pixel thick, then replace the pixel
  ;values in this border range with the value specified by "border_value"
  if (xhi_bw_use GT 0L) then vec_out[(vsize - xhi_bw_use):(vsize - 1L)] = border_value
endelse

;Set "status" to "1"
status = 1

;Return the output vector
return, vec_out

END
