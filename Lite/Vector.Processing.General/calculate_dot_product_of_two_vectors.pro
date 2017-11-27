FUNCTION calculate_dot_product_of_two_vectors, vec1, vec2, status, INTEGER_OUTPUT = integer_output, NO_PAR_CHECK = no_par_check

; Description: This function calculates the dot product (or scalar product, or inner product) of two input
;              vectors "vec1" and "vec2" of the same length. The dot product of two vectors V1 and V2 is a
;              scalar (single number) defined as:
;
;                       N
;              V1.V2 = SUM V1_i*V2_i
;                      i=1
;
;              where V1_i and V2_i are the ith elements of the vectors V1 and V2, respectively, and N is the
;              number of elements in each vector.
;                The function provides the option of using LONG type integers for the calculation of the dot
;              product instead of DOUBLE type numbers via the use of the keyword INTEGER_OUTPUT.
;                This function uses the IDL function "matrix_multiply" to obtain the dot product rather than
;              calculating the equivalent expression "total(vec1*vec2, /DOUBLE)". The reason for this is
;              that the "matrix_multiply" implementation is faster, with a speed increase of ~2.14 times for
;              vectors of length 1000 elements, and even better for longer vectors. In fact, expressions of
;              the type "total(vec1*vec2, /DOUBLE)" should in general be replaced where possible by:
;
;              result = calculate_dot_product_of_two_vectors(vec1, vec2, status, /NO_PAR_CHECK)
;
;              N.B: I also developed a similar module for calculating the dot product of two arrays, using
;                   the IDL "reform" function to convert the arrays to vectors which in turn allowed me to
;                   employ the IDL "matrix_multiply" function. However, I found that this slowed down the
;                   dot product calculation for arrays with two or more dimensions. Hence, DanIDL does not
;                   supply an equivalent function "calculate_dot_product_of_two_arrays.pro", and the user
;                   is encouraged to use the expression "total(arr1*arr2, /DOUBLE)" for the dot product of
;                   two arrays "arr1" and "arr2".
;
; Input Parameters:
;
;   vec1 - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR - A scalar number or a vector of numbers.
;   vec2 - BYTE/INTEGER/LONG/FLOAT/DOUBLE SCALAR/VECTOR - A scalar number or a vector of numbers. This
;                                                         parameter must have the same number of elements
;                                                         as "vec1".
;   status - ANY - A variable which will be used to contain the output status of the function on returning
;                  (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully calculated the dot product, then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision SCALAR number that represents the dot product of the two
;   vectors "vec1" and "vec2".
;
; Keywords:
;
;   If the keyword INTEGER_OUTPUT is set (as "/INTEGER_OUTPUT"), then the module will convert the elements
;   of the input parameters "vec1" and "vec2" into LONG type integers, and it will use them to calculate
;   the dot product as a LONG type integer instead of as a DOUBLE type number.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "vec1" contains numbers of the correct type
  if (test_bytintlonfltdbl(vec1) NE 1) then return, 0.0D

  ;Check that "vec1" is a scalar or vector
  if (vec1.ndim GT 1L) then return, 0.0D

  ;Check that "vec2" contains numbers of the correct type
  if (test_bytintlonfltdbl(vec2) NE 1) then return, 0.0D

  ;Check that "vec2" is a scalar or vector
  if (vec2.ndim GT 1L) then return, 0.0D

  ;Check that "vec1" and "vec2" have the same number of elements
  if (vec2.length NE vec1.length) then return, 0.0D
endif

;Calculate the dot product
if keyword_set(integer_output) then begin
  dot_product = matrix_multiply(long(vec1), long(vec2), /ATRANSPOSE)
endif else dot_product = matrix_multiply(double(vec1), double(vec2), /ATRANSPOSE)

;Set "status" to "1"
status = 1

;Return the dot product
return, dot_product[0]

END
