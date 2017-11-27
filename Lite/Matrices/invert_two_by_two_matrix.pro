PRO invert_two_by_two_matrix, matrix, inv_matrix, determinant, status, NO_PAR_CHECK = no_par_check

; Description: This module calculates the inverse matrix "inv_matrix" of an input two-by-two
;              element square matrix "matrix". The module also returns the determinant
;              "determinant" of the input matrix "matrix". The module will fail (gracefully)
;              if the input matrix "matrix" is singular.
;
;              N.B: The implementation of variance propagation and bad pixel mask propagation
;                   in an associated "_werr.pro" module is feasible, but it has not been done
;                   yet due to the lack of a clear use-case scenario.
;
; Input Parameters:
;
;   matrix - FLOAT/DOUBLE ARRAY - A 2x2 element array representing the input matrix.
;
; Output Parameters:
;
;   inv_matrix - DOUBLE ARRAY - A 2x2 element array representing the inverse matrix of the
;                               input matrix.
;   determinant - DOUBLE - The determinant of the input matrix "matrix". If the input matrix
;                          is singular, then this parameter is set to "0.0".
;   status - INTEGER - If the module successfully calculated the inverse matrix "inv_matrix",
;                      then "status" is set to "1". If the module was unable to calculate the
;                      inverse matrix "inv_matrix" because the input matrix "matrix" is
;                      singular, then "status" is set to "0". If the module failed for any
;                      other reason, then "status" is set to "-1".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform
;   parameter checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
inv_matrix = 0.0D
determinant = 0.0D
status = -1

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "matrix" is a 2x2 array of the correct number type
  test_fltdbl_2darr, matrix, mstat, mxsize, mysize, mtype
  if (mstat EQ 0) then return
  if (mxsize NE 2L) then return
  if (mysize NE 2L) then return
endif
matrix_use = double(matrix)

;Calculate the determinant of the input matrix
determinant = calculate_determinant_of_two_by_two_matrix(matrix_use, stat, /NO_PAR_CHECK)

;If the input matrix is singular (zero determinant), then return with "status" set to "0"
if (determinant EQ 0.0D) then begin
  status = 0
  return
endif

;Calculate the elements of the inverse matrix
inv_matrix = [[matrix_use[3], -matrix_use[1]], [-matrix_use[2], matrix_use[0]]]*(1.0D/determinant)

;Set "status" to "1"
status = 1

END
