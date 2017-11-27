FUNCTION bitwise_and, bit_pattern_data, status, danidl_cppcode

; Description: This function performs a bit-wise AND operation between all elements of the input set of integers
;              "bit_pattern_data", where each integer represents a pattern of bits that are set (or the equivalent
;              binary number). The function returns an integer number representing the bit-pattern result. The
;              input parameter "bit_pattern_data" may be a scalar, vector, or array.
;                This function will use C++ code if possible to achieve a faster execution than the default IDL
;              code. The C++ code can be up to ~14.5 times faster than the IDL code in this case.
;
;              N.B: The implementation of bad pixel mask propagation in an associated "_werr.pro" function is
;                   feasible, but it has not been done yet due to the lack of a clear use-case scenario.
;
; Input Parameters:
;
;   bit_pattern_data - BYTE/INTEGER/LONG SCALAR/VECTOR/ARRAY - The set of bit-pattern values, stored as integer
;                                                              numbers, that are to be combined using the bit-wise
;                                                              AND operation.
;   status - ANY - A variable which will be used to contain the output status of the function on returning (see
;                  output parameters below).
;   danidl_cppcode - STRING - The full directory path indicating where the DanIDL C++ code is installed. The shared
;                             library of DanIDL C++ routines should exist as "<danidl_cppcode>/dist/libDanIDL.so"
;                             within the installation. If this input parameter is not specified correctly, then
;                             the default IDL code will be used instead.
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input value(s), then "status" is returned with
;                      a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The return value is a SCALAR of the same number type as the input parameter "bit_pattern_data" that is the
;   result of performing a bit-wise AND operation between all the elements of "bit_pattern_data".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Check that "bit_pattern_data" contains numbers of the correct type
bptype = determine_idl_type_as_int(bit_pattern_data)
if ((bptype LT 1) OR (bptype GT 3)) then return, 0

;If the input parameter "bit_pattern_data" has only one element, then set the return value of this function to the
;value of the single element of "bit_pattern_data"
ndata = bit_pattern_data.length
if (ndata EQ 1L) then begin
  status = 1
  return, bit_pattern_data[0]
endif

;Determine if the shared library of DanIDL C++ routines is installed
test_danidl_cppcode, danidl_cppcode, danidl_cpp_shared_lib, danidl_cppstat

;If the shared library of DanIDL C++ routines is installed, then use the C++ code to speed up the calculation
if (danidl_cppstat EQ 1) then begin

  ;Combine the elements of "bit_pattern_data" using the bit-wise AND operator
  bit_pattern_result = 0L
  result = call_external(danidl_cpp_shared_lib, 'bitwise_and', ndata, long(bit_pattern_data), bit_pattern_result)
  if (bptype EQ 1) then begin
    bit_pattern_result = byte(bit_pattern_result)
  endif else if (bptype EQ 2) then bit_pattern_result = fix(bit_pattern_result)

;If the shared library of DanIDL C++ routines is not installed, then use the default IDL code
endif else begin

  ;Use an iterative algorithm employing as many vector operations as possible (for maximum calculation efficiency)
  ;to combine the elements of "bit_pattern_data" using the bit-wise AND operator
  bit_pattern_result = bit_pattern_data
  while (ndata GT 1L) do begin

    ;If at least one of the elements still to be combined using the bit-wise AND operator is zero, then the result
    ;of the combination is also guaranteed to be zero, so break out of the loop
    if (array_equal(bit_pattern_result, 0B, /NOT_EQUAL) EQ 0B) then break

    ;If the current number of elements still to be combined using the bit-wise AND operator is odd
    if ((ndata mod 2L) EQ 1L) then begin

      ;Perform a bit-wise AND operation between the first and last element of the current set of elements still
      ;to be combined
      ndata = ndata - 1L
      bit_pattern_result[0] = bit_pattern_result[0] AND bit_pattern_result[ndata]
    endif

    ;Perform a bit-wise AND operation between each pair of elements still to be combined by employing a vector
    ;operation
    hndata = ndata/2L
    bit_pattern_result = bit_pattern_result[0L:(hndata - 1L)] AND bit_pattern_result[hndata:(ndata - 1L)]

    ;Update the number of elements still to be combined using the bit-wise AND operator
    ndata = hndata
  endwhile

  ;Extract the bit-pattern result as a scalar value
  if (ndata EQ 1L) then begin
    bit_pattern_result = bit_pattern_result[0]
  endif else begin
    if (bptype EQ 1) then begin
      bit_pattern_result = 0B
    endif else if (bptype EQ 2) then begin
      bit_pattern_result = 0
    endif else bit_pattern_result = 0L
  endelse
endelse

;Set "status" to "1"
status = 1

;Return the bit-pattern result
return, bit_pattern_result

END
