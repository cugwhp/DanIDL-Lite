FUNCTION extract_subarray_from_3darr, data_arr, xind, yind, zind, status, OUT_XSIZE = out_xsize, OUT_YSIZE = out_ysize, OUT_ZSIZE = out_zsize, NO_PAR_CHECK = no_par_check

; Description: This function extracts and returns an output sub-array from a three-dimensional input array
;              "data_arr" using only the elements in "data_arr" that have x, y and z indices in the index
;              lists "xind", "yind" and "zind", respectively. Let "xind", "yind" and "zind" have M, N and
;              P elements denoted by x_i, y_j and z_k, respectively. Then the elements B_ijk of the MxNxP
;              output sub-array are given by:
;
;              B_ijk = A_lmn
;              l = x_i
;              m = y_j
;              n = z_k
;
;              where A_lmn are the elements of the input array "data_arr".
;                The function provides the option of returning the size of the output sub-array via the
;              keywords OUT_XSIZE, OUT_YSIZE and OUT_ZSIZE.
;
; Input Parameters:
;
;   data_arr - ANY ARRAY - A three-dimensional array of any type from which the sub-array is to be
;                          extracted.
;   xind - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of indices along the x-axis. All
;                                             indices must lie in the range "0 <= xind < xsize" where
;                                             "xsize" is the size of the three-dimensional array
;                                             "data_arr" along the x-axis. Note that repeat indices
;                                             are acceptable.
;   yind - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of indices along the y-axis. All
;                                             indices must lie in the range "0 <= yind < ysize"	where
;                                             "ysize" is the size of the three-dimensional array
;                                             "data_arr" along the y-axis. Note that repeat indices
;                                             are acceptable.
;   zind - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array of indices along the z-axis. All
;                                             indices must lie in the range "0 <= zind < zsize" where
;                                             "zsize" is the size of the three-dimensional array
;                                             "data_arr" along the z-axis. Note that repeat indices
;                                             are acceptable.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully extracted the output sub-array, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a VECTOR/ARRAY formed as described above using only the elements of "data_arr"
;   that have x, y and z indices in the index lists "xind", "yind" and "zind", respectively. The elements
;   of this output sub-array are necessarily of the same type as the elements of "data_arr". Given input
;   parameters "xind", "yind" and "zind" with M, N and P elements, respectively, then the output
;   sub-array will be a three-dimensional array of size MxNxP elements, unless either P = 1 or N = P = 1,
;   in which case it will be a two-dimensional array of size MxN elements or a one-dimensional vector
;   of length M, respectively. Note that since repeat indices are acceptable in "xind", "yind" and
;   "zind", it is possible that the size of the output sub-array along one or more axes is greater than
;   the size of "data_arr".
;
; Keywords:
;
;   If the keyword OUT_XSIZE is set to a named variable, then, on return, this variable will contain
;   a SCALAR number of LONG type that represents the size of the output sub-array along the x-axis.
;
;   If the keyword OUT_YSIZE is set to a named variable, then, on return, this variable will contain
;   a SCALAR number of LONG type that represents the size of the output sub-array along the y-axis.
;
;   If the keyword OUT_ZSIZE is set to a named variable, then, on return, this variable will contain
;   a SCALAR number of LONG type that represents the size of the output sub-array along the z-axis.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform
;   parameter checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
out_xsize = 0L
out_ysize = 0L
out_zsize = 0L
status = 0

;If parameter checking is not required
if keyword_set(no_par_check) then begin

  ;Convert the input parameters "xind", "yind" and "zind"
  xind_use = long(xind)
  yind_use = long(yind)
  zind_use = long(zind)

;If parameter checking is required
endif else begin

  ;Check that "data_arr" is a three-dimensional array
  size_data = size(data_arr)
  if (size_data[0] NE 3L) then return, 0.0D

  ;Check that "xind", "yind" and "zind" are of the correct number type
  if (test_intlon(xind) NE 1) then return, 0.0D
  if (test_intlon(yind) NE 1) then return, 0.0D
  if (test_intlon(zind) NE 1) then return, 0.0D

  ;Check that all of the values in "xind" lie in the range "0 <= xind < xsize" where "xsize" is the size
  ;of the three-dimensional array "data_arr" along the x-axis
  xind_use = long(xind)
  if (array_equal((xind_use GE 0L) AND (xind_use LT size_data[1]), 1B) EQ 0B) then return, 0.0D

  ;Check that all of the values in "yind" lie in the range "0 <= yind < ysize" where "ysize" is the size
  ;of the three-dimensional array "data_arr" along the y-axis
  yind_use = long(yind)
  if (array_equal((yind_use GE 0L) AND (yind_use LT size_data[2]), 1B) EQ 0B) then return, 0.0D

  ;Check that all of the values in "zind" lie in the range "0 <= zind < zsize" where "zsize" is the size
  ;of the three-dimensional array "data_arr" along the z-axis
  zind_use = long(zind)
  if (array_equal((zind_use GE 0L) AND (zind_use LT size_data[3]), 1B) EQ 0B) then return, 0.0D
endelse

;Determine the size of the output sub-array
out_xsize = xind_use.length
out_ysize = yind_use.length
out_zsize = zind_use.length

;Determine the x, y and z indices of the elements of the output sub-array in the input array "data_arr"
xind_out = replicate_1dvec_into_3darr(reform(xind_use, out_xsize, /OVERWRITE), 'x', out_ysize, out_zsize, stat, /NO_PAR_CHECK)
yind_out = replicate_1dvec_into_3darr(reform(yind_use, out_ysize, /OVERWRITE), 'y', out_xsize, out_zsize, stat, /NO_PAR_CHECK)
zind_out = replicate_1dvec_into_3darr(reform(zind_use, out_zsize, /OVERWRITE), 'z', out_xsize, out_ysize, stat, /NO_PAR_CHECK)

;Set "status" to "1"
status = 1

;Extract and return the required output sub-array from the input array "data_arr"
return, data_arr[xind_out, yind_out, zind_out]

END
