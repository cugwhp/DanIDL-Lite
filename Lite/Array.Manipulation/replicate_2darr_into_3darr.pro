FUNCTION replicate_2darr_into_3darr, data, image_axes, nrep, status, OUT_XSIZE = out_xsize, OUT_YSIZE = out_ysize, OUT_ZSIZE = out_zsize, NO_PAR_CHECK = no_par_check

; Description: This function replicates the contents of a two-dimensional input array "data" to create a
;              three-dimensional output array. If "image_axes" is set to "xy", then "data" is replicated
;              "nrep" times to form the "nrep" two-dimensional xy-slices of the output array, which means
;              that the output array will have a size of M by N by "nrep" elements, where M and N are the
;              sizes of "data" along the x- and y-axes, respectively. If "image_axes" is set to "xz", then
;              "data" is replicated "nrep" times to form the "nrep" two-dimensional xz-slices of the output
;              array, which means that the output array will have a size of M by "nrep" by N elements. If
;              "image_axes" is set to "yz", then "data" is replicated "nrep" times to form the "nrep"
;              two-dimensional yz-slices of the output array, which means that the output array will have
;              a size of "nrep" by M by N elements.
;                In mathematical terms, the function creates the output array A from the input array B via:
;
;              For "image_axes" set to "xy": A_ijk = B_ij               1 <= i <= M, 1 <= j <= N, 1 <= k <= "nrep"
;              For "image_axes" set to "xz": A_ijk = B_ik               1 <= i <= M, 1 <= j <= "nrep", 1 <= k <= N
;              For "image_axes" set to "yz": A_ijk = B_jk               1 <= i <= "nrep", 1 <= j <= M, 1 <= k <= N
;
;              where the (i,j,k) indices refer to the x, y and z axes of A, and B_lm is the (l,m)-th
;              element of the array B.
;                The function provides the option of returning the size of the output array via the keywords
;              OUT_XSIZE, OUT_YSIZE and OUT_ZSIZE.
;
; Input Parameters:
;
;   data - ANY ARRAY - A two-dimensional array of any type with M by N elements which is to be replicated to
;                      create a three-dimensional output array.
;   image_axes - STRING - This input parameter has three acceptable values. If "image_axes" is set to the
;                         string "xy", then "data" is replicated "nrep" times to form the "nrep"
;                         two-dimensional xy-slices of the three-dimensional output array. If "image_axes"
;                         is set to the string "xz", then "data" is replicated "nrep" times to form the
;                         "nrep" two-dimensional xz-slices of the three-dimensional output array. If
;                         "image_axes" is set to the string "yz", then "data" is replicated "nrep" times to
;                         form the "nrep" two-dimensional yz-slices of the three-dimensional output array.
;   nrep - INTEGER/LONG - The number of times that "data" should be replicated to form the appropriate (xy-,
;                         xz- or yz-) two-dimensional slices of the output array. This parameter must be
;                         positive.
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully created the output array, then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a three-dimensional ARRAY formed by the replication of the two-dimensional input
;   array "data". The elements of this output array are necessarily of the same type as the elements of
;   "data". If the input parameter "image_axes" is set to "xy", then the output array will be an M by N
;   by "nrep" element array where each two-dimensional xy-slice contains a copy of "data". If the input
;   parameter "image_axes" is set to "xz", then the output array will be an M by "nrep" by N element
;   array where each two-dimensional xz-slice contains a copy of "data". If the input parameter
;   "image_axes" is set to "yz", then the output array will be an "nrep" by M by N element array where
;   each two-dimensional yz-slice contains a copy of "data". Note that if "nrep" is set to "1" and
;   "image_axes" is set to "xy", then the output array will be a two-dimensional array of size M by N
;   elements since IDL treats an MxNx1 array as an MxN-element two-dimensional array.
;
; Keywords:
;
;   If the keyword OUT_XSIZE is set to a named variable, then, on return, this variable will contain a
;   SCALAR number of LONG type that represents the size of the output array along the x-axis.
;
;   If the keyword OUT_YSIZE is set to a named variable, then, on return, this variable will contain a
;   SCALAR number of LONG type that represents the size of the output array along the y-axis.
;
;   If the keyword OUT_ZSIZE is set to a named variable, then, on return, this variable will contain a
;   SCALAR number of LONG type that represents the size of the output array along the z-axis.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
out_xsize = 0L
out_ysize = 0L
out_zsize = 0L
status = 0

;Perform parameter checking if not instructed otherwise
size_data = size(data)
if ~keyword_set(no_par_check) then begin

  ;Check that "data" is a two-dimensional array
  if (size_data[0] NE 2L) then return, 0.0D

  ;Check that "image_axes" is a scalar string with an acceptable value
  if (test_str_scalar(image_axes) NE 1) then return, 0.0D
  if (test_set_membership(image_axes, ['xy', 'xz', 'yz'], /NO_PAR_CHECK) NE 1) then return, 0.0D

  ;Check that "nrep" is a positive number of the correct type
  if (test_intlon_scalar(nrep) NE 1) then return, 0.0D
  if (nrep LT 1) then return, 0.0D
endif
nrep_use = long(nrep)

;Determine the size of the output array
if (image_axes EQ 'xy') then begin
  out_xsize = size_data[1]
  out_ysize = size_data[2]
  out_zsize = nrep_use
endif else if (image_axes EQ 'xz') then begin
  out_xsize = size_data[1]
  out_ysize = nrep_use
  out_zsize = size_data[2]
endif else begin
  out_xsize = nrep_use
  out_ysize = size_data[1]
  out_zsize = size_data[2]
endelse

;Set "status" to "1"
status = 1

;If "data" is to be replicated only once
if (nrep_use EQ 1L) then begin

  ;Create and return the output array as appropriate
  if (image_axes EQ 'xy') then begin
    return, data
  endif else return, reform(data, out_xsize, out_ysize, out_zsize)
endif

;If "data" contains number data
data_type = size_data[3]
if ((data_type LT 6L) OR (data_type GT 11L)) then begin

  ;Replicate the input array "data" to create the output array, and return
  if (image_axes EQ 'xy') then begin
    return, rebin(data, out_xsize, out_ysize, out_zsize)
  endif else if (image_axes EQ 'xz') then begin
    return, rebin(reform(data, out_xsize, 1L, out_zsize), out_xsize, out_ysize, out_zsize)
  endif else return, rebin(reform(data, 1L, out_ysize, out_zsize), out_xsize, out_ysize, out_zsize)
endif

;If "data" is of the type STRUCT
if (data_type EQ 8L) then begin

  ;Set up the output array
  out_arr = replicate(data[0], out_xsize, out_ysize, out_zsize)

;If "data" is of the type COMPLEX, STRING, DCOMPLEX, POINTER or OBJREF, then set up the output array
endif else out_arr = make_array(out_xsize, out_ysize, out_zsize, TYPE = data_type, /NOZERO)

;Replicate the input array "data" to create the output array
if (image_axes EQ 'xy') then begin
  for i = 0L,(out_zsize - 1L) do out_arr[0L,0L,i] = data
endif else if (image_axes EQ 'xz') then begin
  tmp_arr = reform(data, out_xsize, 1L, out_zsize)
  for i = 0L,(out_ysize - 1L) do out_arr[0L,i,0L] = tmp_arr
endif else begin
  tmp_arr = reform(data, 1L, out_ysize, out_zsize)
  for i = 0L,(out_xsize - 1L) do out_arr[i,0L,0L] = tmp_arr
endelse

;Return the output array
return, out_arr

END
