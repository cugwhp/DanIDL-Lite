FUNCTION replicate_1dvec_into_2darr, data, vector_axis, nrep, status, OUT_XSIZE = out_xsize, OUT_YSIZE = out_ysize, NO_PAR_CHECK = no_par_check

; Description: This function replicates the contents of a one-dimensional input vector "data" to create a
;              two-dimensional output array. If "vector_axis" is set to "x", then "data" is replicated
;              "nrep" times to form the "nrep" rows of the output array, which means that the output array
;              will have a size of N by "nrep" elements, where N is the number of elements in "data".
;              Alternatively, if "vector_axis" is set to "y", then "data" is replicated "nrep" times to
;              form the "nrep" columns of the output array, which means that the output array will have a
;              size of "nrep" by N elements.
;                In mathematical terms, the function creates the output array A from the input vector V via:
;
;              For "vector_axis" set to "x": A_ij = V_i                 1 <= i <= N, 1 <= j <= "nrep"
;              For "vector_axis" set to "y": A_ij = V_j                 1 <= i <= "nrep", 1 <= j <= N
;
;              where the (i,j) indices refer to the x and y axes of A, and V_i is the ith element of the
;              vector V.
;                The function provides the option of returning the size of the output array via the
;              keywords OUT_XSIZE and OUT_YSIZE.
;
; Input Parameters:
;
;   data - ANY VECTOR - A one-dimensional vector of any type with N elements which is to be replicated to
;                       create a two-dimensional output array.
;   vector_axis - STRING - This input parameter has two acceptable values. If "vector_axis" is set to the
;                          string "x", then "data" is replicated "nrep" times to form the "nrep" rows of
;                          the two-dimensional output array. If "vector_axis" is set to the string "y",
;                          then "data" is replicated "nrep" times to form the "nrep" columns of the
;                          two-dimensional output array.
;   nrep - INTEGER/LONG - The number of times that "data" should be replicated to form the rows or columns
;                         of the output array. This parameter must be positive.
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
;   The function returns a two-dimensional ARRAY formed by the replication of the one-dimensional input
;   vector "data". The elements of this output array are necessarily of the same type as the elements of
;   "data". If the input parameter "vector_axis" is set to "x", then the output array will be an N by
;   "nrep" element array where each row contains a copy of "data". If the input parameter "vector_axis"
;   is set to "y", then the output array will be an "nrep" by N element array where each column contains
;   a copy of "data". Note that if "data" has a single element and "vector_axis" is set to "y", then the
;   output array will be a one-dimensional vector of length "nrep" elements since IDL treats an Mx1 array
;   as an M-element one-dimensional vector. For the same reason, if "nrep" is set to "1" and "vector_axis"
;   is set to "x", then the output array will be a one-dimensional vector of length N elements.
;
; Keywords:
;
;   If the keyword OUT_XSIZE is set to a named variable, then, on return, this variable will contain a
;   SCALAR number of LONG type that represents the size of the output array along the x-axis.
;
;   If the keyword OUT_YSIZE is set to a named variable, then, on return, this variable will contain a
;   SCALAR number of LONG type that represents the size of the output array along the y-axis.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
out_xsize = 0L
out_ysize = 0L
status = 0

;Perform parameter checking if not instructed otherwise
size_data = size(data)
if ~keyword_set(no_par_check) then begin

  ;Check that "data" is a one-dimensional vector
  if (size_data[0] NE 1L) then return, 0.0D

  ;Check that "vector_axis" is a scalar string with an acceptable value
  if (test_str_scalar(vector_axis) NE 1) then return, 0.0D
  if (test_set_membership(vector_axis, ['x', 'y'], /NO_PAR_CHECK) NE 1) then return, 0.0D

  ;Check that "nrep" is a positive number of the correct type
  if (test_intlon_scalar(nrep) NE 1) then return, 0.0D
  if (nrep LT 1) then return, 0.0D
endif
ndata = size_data[1]
nrep_use = long(nrep)

;Determine the size of the output array
if (vector_axis EQ 'x') then begin
  out_xsize = ndata
  out_ysize = nrep_use
endif else begin
  out_xsize = nrep_use
  out_ysize = ndata
endelse

;Set "status" to "1"
status = 1

;If "data" is to be replicated only once
if (nrep_use EQ 1L) then begin

  ;Create and return the output array as appropriate
  if (vector_axis EQ 'x') then begin
    return, data
  endif else begin
    if (out_ysize EQ 1L) then begin
      return, data
    endif else return, reform(data, 1L, out_ysize)
  endelse
endif

;If "data" has only one element, then replicate the input vector "data" to create the output array, and
;return
if (ndata EQ 1L) then return, replicate(data, out_xsize, out_ysize)

;If "data" contains number data
data_type = size_data[2]
if ((data_type LT 6L) OR (data_type GT 11L)) then begin

  ;Replicate the input vector "data" to create the output array, and return
  if (vector_axis EQ 'x') then begin
    return, rebin(data, out_xsize, out_ysize)
  endif else return, rebin(reform(data, 1L, out_ysize), out_xsize, out_ysize)
endif

;If "data" is of the type STRUCT
if (data_type EQ 8L) then begin

  ;Set up the output array
  out_arr = replicate(data[0], out_xsize, out_ysize)

;If "data" is of the type COMPLEX, STRING, DCOMPLEX, POINTER or OBJREF, then set up the output array
endif else out_arr = make_array(out_xsize, out_ysize, TYPE = data_type, /NOZERO)

;Replicate the input vector "data" to create the output array
if (vector_axis EQ 'x') then begin
  for i = 0L,(out_ysize - 1L) do out_arr[0L,i] = data
endif else begin
  tmp_vec = reform(data, 1L, out_ysize)
  for i = 0L,(out_xsize - 1L) do out_arr[i,0L] = tmp_vec
endelse

;Return the output array
return, out_arr

END
