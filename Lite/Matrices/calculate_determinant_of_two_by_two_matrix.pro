FUNCTION calculate_determinant_of_two_by_two_matrix, matrix, status, NO_PAR_CHECK = no_par_check

; Description: This function calculates the determinant of the two-by-two element square matrix "matrix".
;
;              N.B: (i) This function is approximately four times faster than using the equivalent IDL
;                       functions "determ" or "la_determ" to do the same calculation for a two-by-two
;                       matrix.
;
;                   (ii) The implementation of variance propagation and bad pixel mask propagation in an
;                        associated "_werr.pro" function is feasible, but it has not been done yet due
;                        to the lack of a clear use-case scenario.
;
; Input Parameters:
;
;   matrix - FLOAT/DOUBLE ARRAY - A 2x2 element array representing the input matrix.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully calculated the determinant of the input matrix, then
;                      "status" is returned with a value of "1", otherwise it is returned with a value
;                      of "0".
;
; Return Value:
;
;   The function returns a DOUBLE precision number whose value is the determinant of the input matrix
;   "matrix".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameter, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "matrix" is a 2x2 array of the correct number type
  test_fltdbl_2darr, matrix, mstat, mxsize, mysize, mtype
  if (mstat EQ 0) then return, 0.0D
  if (mxsize NE 2L) then return, 0.0D
  if (mysize NE 2L) then return, 0.0D
endif
matrix_use = double(matrix)

;Set "status" to "1"
status = 1

;Calculate and return the determinant of the input matrix
return, (matrix_use[0]*matrix_use[3]) - (matrix_use[1]*matrix_use[2])

END
