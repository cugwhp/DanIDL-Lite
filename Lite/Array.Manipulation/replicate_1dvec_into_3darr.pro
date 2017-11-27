FUNCTION replicate_1dvec_into_3darr, data, vector_axis, nrep1, nrep2, status, OUT_XSIZE = out_xsize, OUT_YSIZE = out_ysize, OUT_ZSIZE = out_zsize, NO_PAR_CHECK = no_par_check

; Description: This function replicates the contents of a one-dimensional input vector "data" to create a
;              three-dimensional output array. If "vector_axis" is set to "x", then each value in "data"
;              is replicated "nrep1*nrep2" times to form a "nrep1"x"nrep2"-element two-dimensional yz-slice
;              of the output array, which means that the output array will have a size of N by "nrep1" by
;              "nrep2" elements, where N is the number of elements in "data". If "vector_axis" is set to
;              "y", then each value in "data" is replicated "nrep1*nrep2" times to form a
;              "nrep1"x"nrep2"-element two-dimensional xz-slice of the output array, which means that the
;              output array will have a size of "nrep1" by N by "nrep2" elements. If "vector_axis" is set
;              to "z", then each value in "data" is replicated "nrep1*nrep2" times to form a
;              "nrep1"x"nrep2"-element two-dimensional xy-slice of the output array, which means that the
;              output array will have a size of "nrep1" by "nrep2" by N elements.
;                In mathematical terms, the function creates the output array A from the input vector V via:
;
;              For "vector_axis" set to "x": A_ijk = V_i                1 <= i <= N, 1 <= j <= "nrep1", 1 <= k <= "nrep2"
;              For "vector_axis" set to "y": A_ijk = V_j                1 <= i <= "nrep1", 1 <= j <= N, 1 <= k <= "nrep2"
;              For "vector_axis" set to "z": A_ijk = V_k                1 <= i <= "nrep1", 1 <= j <= "nrep2", 1 <= k <= N
;
;              where the (i,j,k) indices refer to the x, y and z axes of A, and V_i is the ith element of
;              the vector V.
;                The function provides the option of returning the size of the output array via the
;              keywords OUT_XSIZE, OUT_YSIZE and OUT_ZSIZE.
;
; Input Parameters:
;
;   data - ANY VECTOR - A one-dimensional vector of any type with N elements which is to be replicated to
;                       create a three-dimensional output array.
;   vector_axis - STRING - This input parameter has three acceptable values. If "vector_axis" is set to the
;                          string "x", then each value in "data" is replicated "nrep1*nrep2" times to form
;                          a "nrep1"x"nrep2"-element two-dimensional yz-slice of the three-dimensional output
;                          array. If "vector_axis" is set to the string "y", then each value in "data" is
;                          replicated "nrep1*nrep2" times to form a "nrep1"x"nrep2"-element two-dimensional
;                          xz-slice of the three-dimensional output array. If "vector_axis" is set to the
;                          string "z", then each value in "data" is replicated "nrep1*nrep2" times to form
;                          a "nrep1"x"nrep2"-element two-dimensional xy-slice of the three-dimensional output
;                          array.
;   nrep1 - INTEGER/LONG - The number of times that each element in "data" should be replicated along the
;                          first dimension of the appropriate (yz-, xz- or xy-) two-dimensional slice of the
;                          output array. This parameter must be positive.
;   nrep2 - INTEGER/LONG - The number of times that each element in "data" should be replicated along the
;                          second dimension of the appropriate (yz-, xz- or xy-) two-dimensional slice of
;                          the output array. This parameter must be positive.
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
;   The function returns a three-dimensional ARRAY formed by the replication of the one-dimensional input
;   vector "data". The elements of this output array are necessarily of the same type as the elements of
;   "data". If the input parameter "vector_axis" is set to "x", then the output array will be an N by
;   "nrep1" by "nrep2" element array where each vector in the output array parallel to the x-axis contains
;   a copy of "data". If the input parameter "vector_axis" is set to "y", then the output array will be an
;   "nrep1" by N by "nrep2" element array where each vector in the output array parallel to the y-axis
;   contains a copy of "data". If the input parameter "vector_axis" is set to "z", then the output array
;   will be an "nrep1" by "nrep2" by N element array where each vector in the output array parallel to the
;   z-axis contains a copy of "data". Note that if the input parameters are such that the output array has
;   trailing dimension(s) of size unity, then the output array will be a one-dimensional vector or a
;   two-dimensional array, as opposed to a three-dimensional array. This is because IDL treats an Mx1x1
;   array as an M-element one-dimensional vector, and it treats an MxPx1 array as an MxP-element
;   two-dimensional array.
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

  ;Check that "data" is a one-dimensional vector
  if (size_data[0] NE 1L) then return, 0.0D

  ;Check that "vector_axis" is a scalar string with an acceptable value
  if (test_str_scalar(vector_axis) NE 1) then return, 0.0D
  if (test_set_membership(vector_axis, ['x', 'y', 'z'], /NO_PAR_CHECK) NE 1) then return, 0.0D

  ;Check that "nrep1" and "nrep2" are positive numbers of the correct type
  if (test_intlon_scalar(nrep1) NE 1) then return, 0.0D
  if (test_intlon_scalar(nrep2) NE 1) then return, 0.0D
  if (nrep1 LT 1) then return, 0.0D
  if (nrep2 LT 1) then return, 0.0D
endif
ndata = size_data[1]
nrep1_use = long(nrep1)
nrep2_use = long(nrep2)

;Determine the size of the output array
if (vector_axis EQ 'x') then begin
  out_xsize = ndata
  out_ysize = nrep1_use
  out_zsize = nrep2_use
endif else if (vector_axis EQ 'y') then begin
  out_xsize = nrep1_use
  out_ysize = ndata
  out_zsize = nrep2_use
endif else begin
  out_xsize = nrep1_use
  out_ysize = nrep2_use
  out_zsize = ndata
endelse

;Set "status" to "1"
status = 1

;If "data" is to be replicated only once
if ((nrep1_use EQ 1L) AND (nrep2_use EQ 1L)) then begin

  ;Create and return the output array as appropriate
  if (vector_axis EQ 'x') then begin
    return, data
  endif else if (vector_axis EQ 'y') then begin
    if (out_ysize EQ 1L) then begin
      return, data
    endif else return, reform(data, 1L, out_ysize)
  endif else begin
    if (out_zsize EQ 1L) then begin
      return, data
    endif else return, reform(data, 1L, 1L, out_zsize)
  endelse
endif

;If "data" has only one element, then replicate the input vector "data" to create the output array, and
;return
if (ndata EQ 1L) then return, replicate(data, out_xsize, out_ysize, out_zsize)

;If "data" contains number data
data_type = size_data[2]
if ((data_type LT 6L) OR (data_type GT 11L)) then begin

  ;Replicate the input vector "data" to create the output array, and return
  if (vector_axis EQ 'x') then begin
    return, rebin(data, out_xsize, out_ysize, out_zsize)
  endif else if (vector_axis EQ 'y') then begin
    return, rebin(reform(data, 1L, out_ysize), out_xsize, out_ysize, out_zsize)
  endif else return, rebin(reform(data, 1L, 1L, out_zsize), out_xsize, out_ysize, out_zsize)
endif

;If "data" is of the type STRUCT
if (data_type EQ 8L) then begin

  ;Set up the output array
  out_arr = replicate(data[0], out_xsize, out_ysize, out_zsize)

;If "data" is of the type COMPLEX, STRING, DCOMPLEX, POINTER or OBJREF, then set up the output array
endif else out_arr = make_array(out_xsize, out_ysize, out_zsize, TYPE = data_type, /NOZERO)

;Replicate the input vector "data" to create the output array
if (vector_axis EQ 'x') then begin
  for i = 0L,(out_ysize - 1L) do begin
    for j = 0L,(out_zsize - 1L) do out_arr[0L,i,j] = data
  endfor
endif else if (vector_axis EQ 'y') then begin
  tmp_vec = reform(data, 1L, out_ysize)
  for i = 0L,(out_xsize - 1L) do begin
    for j = 0L,(out_zsize - 1L) do out_arr[i,0L,j] = tmp_vec
  endfor
endif else begin
  tmp_vec = reform(data, 1L, 1L, out_zsize)
  for i = 0L,(out_xsize - 1L) do begin
    for j = 0L,(out_ysize - 1L) do out_arr[i,j,0L] = tmp_vec
  endfor
endelse

;Return the output array
return, out_arr

END
