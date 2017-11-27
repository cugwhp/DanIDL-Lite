FUNCTION propagate_variance_for_general_linear_transformation, covar_matrix, coeff_matrix, status, NO_PAR_CHECK = no_par_check

; Description: Given an NxN element covariance matrix "covar_matrix" for a set of N random variables
;              X_j, this function calculates and returns the MxM element covariance matrix for a set
;              of M random variables Y_i, where each random variable Y_i is formed as a linear
;              combination of the set of random variables X_j parameterised by the NxM matrix of
;              coefficients "coeff_matrix". Mathematically, the function does the following. For the
;              set of M random variables Y_i defined by:
;
;                     N
;              Y_i = Sum a_ij*X_j
;                    j=1
;
;              the MxM covariance matrix of the random variables Y_i, denoted by V, is calculated
;              analytically via:
;
;                                     {  N   N                         }
;              V = { Cov(Y_i,Y_j) } = { Sum Sum a_ik*Cov(X_k,X_l)*a_jl }
;                                     { k=1 l=1                        }
;
;              where Cov(Y_i,Y_j) is the covariance between Y_i and Y_j, and Cov(X_k,X_l) is the
;              covariance between X_k and X_l. This formula may be expressed in matrix notation as:
;
;              V = A W transpose(A)
;
;              where W is the covariance matrix { Cov(X_k,X_l) } and A is the matrix of coefficients
;              { a_ij }.
;                Note that the formula for the propagation of the covariances used by this function
;              is an exact formula whose result applies regardless of the underlying probability
;              density functions of the random variables that are being transformed.
;                If the input covariance matrix "covar_matrix" is supplied as an N-element
;              one-dimensional vector, then the function assumes that the elements of this vector
;              represent the diagonal elements of the input covariance matrix and that the off-diagonal
;              elements of the matrix are zero. This covers the case when the N random variables X_j
;              are independent.
;                This function does not make any checks as to whether the input matrix "covar_matrix"
;              is a valid covariance matrix. In other words, the function does not test whether or not
;              "covar_matrix" is symmetric positive-semidefinite.
;
;              N.B: When processing data that include "bad values" that should be ignored, it is
;                   sufficient to set all of the entries in the coefficient matrix corresponding to the
;                   "bad" random variable X_j (i.e. all of the entries in column j) to zero and/or to
;                   set all of the entries in the covariance matrix corresponding to the "bad" random
;                   variable X_j (i.e. all of the entries in column j and row j) to zero.
;
; Input Parameters:
;
;   covar_matrix - FLOAT/DOUBLE VECTOR/ARRAY - A two-dimensional array of size N by N elements
;                                              containing the covariance matrix for the set of N random
;                                              variables X_j. Note that since IDL treats a 1 by 1 array
;                                              as a single-element one-dimensional vector, this function
;                                              accepts such a single-element one-dimensional vector to
;                                              represent the case when N is equal to "1". Alternatively,
;                                              this parameter may be supplied as an N-element
;                                              one-dimensional vector, in which case the function assumes
;                                              that the elements of this vector represent the diagonal
;                                              elements of the covariance matrix for the set of N random
;                                              variables X_j and that the off-diagonal elements of the
;                                              covariance matrix are zero.
;   coeff_matrix - FLOAT/DOUBLE VECTOR/ARRAY - A two-dimensional array of size N by M elements containing
;                                              the coefficients for the set of M linear combinations of
;                                              the N random variables X_j.  Note that since IDL treats an
;                                              N by 1 array as an N-element one-dimensional vector, this
;                                              function accepts such an N-element one-dimensional vector
;                                              to represent the case when M is equal to "1".
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully calculated the output covariance matrix, then "status"
;                      is returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   If M is equal to "1", then the function returns a single-element one-dimensional VECTOR of DOUBLE
;   precision. If M is greater than "1", then the function returns an MxM two-dimensional ARRAY of
;   DOUBLE precision. The return variable of the function represents the covariance matrix for the
;   set of M random variables Y_i each formed as a linear combination of the set of N random variables
;   X_j.
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Calculate and return the covariance matrix for the M random variables Y_i each formed as a linear
;combination of the set of N random variables X_j, performing parameter checking if required
return, calculate_matrix_product_at_b_a(coeff_matrix, covar_matrix, status, /REVERSE_PRODUCT, NO_PAR_CHECK = no_par_check)

END
