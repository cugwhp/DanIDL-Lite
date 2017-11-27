PRO solve_square_linear_system_with_diagonal_submatrix, A, B, C, D, v1, v2, x1, x2, Ainv, Binv, Cinv, Dinv, status, SYMMETRIC = symmetric, $
                                                        POSITIVE_DEFINITE = positive_definite, NO_X1 = no_x1, NO_ABCD_INVERSE = no_abcd_inverse, $
                                                        NO_ABC_INVERSE = no_abc_inverse, NO_A_INVERSE = no_a_inverse, ONLY_INVERSE = only_inverse

; Description: This module calculates the solution to the following linear system of equations:
;
;              [ A B ] [ x1 ] = [ v1 ]
;              [ C D ] [ x2 ]   [ v2 ]
;
;              where the sub-matrices A, B, C, and D, of sizes MxM, NxM, MxN, and NxN elements respectively,
;              make up a single square matrix of size (M+N)x(M+N) elements, and where the sub-matrix A is
;              diagonal. Notice that A and D are square matrices, whereas B and C are not necessarily square.
;              The solution sub-vectors x1 and x2, of lengths M and N elements respectively, make up a single
;              solution vector of length (M+N) elements, and similarly the right-hand side sub-vectors v1 and
;              v2, also of lengths M and N elements respectively, make up a single right-hand side vector of
;              length (M+N) elements.
;                This module takes advantage of the fact that A is diagonal in calculating the solution
;              sub-vectors x1 and x2. If the full matrix is very large, but most of its elements are in the
;              sub-matrix A, then the method used in this module makes the calculation of the solution
;              sub-vectors x1 and x2 tractable, both in terms of memory and computing power. The module uses
;              LU factorisation followed by forwards and back substitution to solve the system of equations
;              (see Bramich & Freudling, 2012, MNRAS, 424, 1584).
;                If the full matrix is symmetric, then the user may instruct the module to take advantage of
;              this fact by setting the keyword SYMMETRIC. If the full matrix is symmetric and positive
;              definite, then the user may instruct the module to take advantage of this fact by setting
;              both of the keywords SYMMETRIC and POSITIVE_DEFINITE, and in this case the module will employ
;              Cholesky factorisation in place of LU factorisation. By setting the keyword NO_X1, the user
;              may instruct the module to only calculate the solution sub-vector x2, which avoids the extra
;              calculations required in determining the solution sub-vector x1 if these parameters are not
;              of interest, allowing the user to build more efficient code with this module.
;                The module represents the inverse of the full matrix by:
;
;              [ A B ]^(-1) = [ Ainv Binv ]
;              [ C D ]        [ Cinv Dinv ]
;
;              where Ainv, Binv, Cinv, and Dinv are sub-matrices of sizes MxM, NxM, MxN, and NxN elements
;              respectively. The calculation of the inverse of the full matrix requires a much larger
;              investment of computing power than simply calculating the solution sub-vectors x1 and x2, and
;              the user may not be interested in the inverse of the full matrix. Also, Ainv is not diagonal,
;              which means that it may be unfeasible to store Ainv in memory in the case that A is a large
;              matrix (M > 10^4). Hence this module provides various options for the calculation of the
;              sub-matrices Ainv, Binv, Cinv, and Dinv. If the keyword NO_ABCD_INVERSE is set, then none of
;              the sub-matrices Ainv, Binv, Cinv, or Dinv are calculated. If the keyword NO_ABC_INVERSE is
;              set, then the sub-matrix Dinv is calculated, but the sub-matrices Ainv, Binv, and Cinv are
;              not calculated. If the keyword NO_A_INVERSE is set, then the sub-matrices Binv, Cinv, and
;              Dinv are calculated, but the sub-matrix Ainv is not calculated.
;                Alternatively, the user may only be interested in obtaining the inverse of the full matrix
;              (or some of the sub-matrices of the inverse of the full matrix). By setting the keyword
;              ONLY_INVERSE, the module will ignore the right-hand side sub-vectors v1 and v2, and simply
;              proceed to calculating the required sub-matrices of the inverse of the full matrix.
;
; Input Parameters:
;
;   A - FLOAT/DOUBLE VECTOR - A one-dimensional vector of length M elements containing the diagonal elements
;                             of the upper-left diagonal sub-matrix A. This vector must have at least two
;                             elements (i.e. M > 1). If any of the elements of this vector have the value
;                             "0.0", then the full matrix is singular, and the module will return with
;                             "status" set to "0" (see below).
;   B - FLOAT/DOUBLE ARRAY - A two-dimensional array of size N by M elements containing the elements of the
;                            upper-right sub-matrix B. The size N can take the value of any positive integer
;                            (i.e. N >= 1). If the keyword SYMMETRIC is set, then the module assumes that
;                            the transpose of this input parameter also represents the elements of the
;                            lower-left sub-matrix C.
;   C - FLOAT/DOUBLE VECTOR/ARRAY - A two-dimensional array of size M by N elements containing the elements
;                                   of the lower-left sub-matrix C. Note that since IDL treats an M by 1
;                                   array as an M-element one-dimensional vector, this module accepts such
;                                   an M-element one-dimensional vector to represent the case when N is
;                                   equal to "1". If the keyword SYMMETRIC is set, then this input parameter
;                                   is ignored.
;   D - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - A two-dimensional array of size N by N elements containing the
;                                          elements of the lower-right sub-matrix D. In the case that N is
;                                          equal to "1", the module accepts that this parameter is supplied
;                                          as a scalar number or as a single-element one-dimensional vector.
;   v1 - FLOAT/DOUBLE VECTOR/ARRAY - This input parameter may be supplied as a one-dimensional vector of
;                                    length M elements, or as a two-dimensional array of size K by M
;                                    elements, where K can take the value of any positive integer (i.e.
;                                    K >= 1). In the case that "v1" is supplied as a one-dimensional vector
;                                    of length M elements, the module assumes that this vector contains the
;                                    elements of the sub-vector v1 from the right-hand side of the system
;                                    of equations. In the case that "v1" is supplied as a two-dimensional
;                                    array of size K by M elements, the module assumes that the user has
;                                    supplied K different vectors each containing a different sub-vector
;                                    v1 from the right-hand side of the system of equations, and the module
;                                    will proceed to determine K solution sub-vectors x1 and x2. If the
;                                    keyword ONLY_INVERSE is set, then this input parameter is ignored.
;   v2 - FLOAT/DOUBLE SCALAR/VECTOR/ARRAY - If K is equal to "1", as determined from the input parameter
;                                           "v1", then "v2" may be supplied as a one-dimensional vector of
;                                           length N elements, as a two-dimensional array of size 1 by N
;                                           elements, or as a scalar number if N is also equal to "1". In
;                                           this case the module assumes that "v2" contains the elements of
;                                           the sub-vector v2 from the right-hand side of the system of
;                                           equations. If K is greater than "1", as determined from the
;                                           input parameter "v1", then "v2" may be supplied as a
;                                           two-dimensional array of size K by N elements, or as a
;                                           one-dimensional vector of length K elements if N is equal to
;                                           "1". In this case the module assumes that the user has supplied
;                                           K different vectors each containing a different sub-vector v2
;                                           from the right-hand side of the system of equations, and the
;                                           module will proceed to determine K solution sub-vectors x1 and
;                                           x2. If the keyword ONLY_INVERSE is set, then this input parameter
;                                           is ignored.
;
; Output Parameters:
;
;   x1 - DOUBLE VECTOR/ARRAY - If K is equal to "1", as determined from the input parameter "v1", then "x1"
;                              is a one-dimensional vector of length M elements containing the solution
;                              sub-vector x1. If K is greater than "1", as determined from the input parameter
;                              "v1", then "x1" is a two-dimensional array of size K by M elements containing
;                              the set of solution sub-vectors x1 corresponding to the set of sub-vectors v1
;                              and v2 from the right-hand side of the system of equations. If either of the
;                              keywords NO_X1 or ONLY_INVERSE are set, then this output parameter is not
;                              calculated.
;   x2 - DOUBLE VECTOR/ARRAY - If K is equal to "1", as determined from the input parameter "v1", then "x2"
;                              is a one-dimensional vector of length N elements containing the solution
;                              sub-vector x2. If K is greater than "1", as determined from the input parameter
;                              "v1", then "x2" is a one-dimensional vector of length K elements (if N is equal
;                              to "1"), or a two-dimensional array of size K by N elements (if N is greater
;                              than "1"), containing the set of solution sub-vectors x2 corresponding to the
;                              set of sub-vectors v1 and v2 from the right-hand side of the system of
;                              equations. If the keyword ONLY_INVERSE is set, then this output parameter is
;                              not calculated.
;   Ainv - DOUBLE ARRAY - A two-dimensional array of size M by M elements containing the elements of the
;                         upper-left sub-matrix Ainv of the inverse of the full matrix in the system of
;                         equations. If any of the keywords NO_ABCD_INVERSE, NO_ABC_INVERSE, or
;                         NO_A_INVERSE are set, then this output parameter is not calculated.
;   Binv - DOUBLE ARRAY - A two-dimensional array of size N by M elements containing the elements of the
;                         upper-right sub-matrix Binv of the inverse of the full matrix in the system of
;                         equations. If either of the keywords NO_ABCD_INVERSE or NO_ABC_INVERSE are set,
;                         then this output parameter is not calculated.
;   Cinv - DOUBLE VECTOR/ARRAY - A two-dimensional array of size M by N elements (or a one-dimensional vector
;                                of length M elements if N is equal to "1") containing the elements of the
;                                lower-left sub-matrix Cinv of the inverse of the full matrix in the system
;                                of equations. If any of the keywords NO_ABCD_INVERSE, NO_ABC_INVERSE, or
;                                SYMMETRIC are set, then this output parameter is not calculated. In the
;                                case of a full matrix that is symmetric, Cinv can be obtained easily if
;                                required as the transpose of Binv.
;   Dinv - DOUBLE VECTOR/ARRAY - A two-dimensional array of size N by N elements (or a single-element
;                                one-dimensional vector if N is equal to "1") containing the elements of
;                                the lower-right sub-matrix Dinv of the inverse of the full matrix in the
;                                system of equations. If the keyword NO_ABCD_INVERSE is set, then this
;                                output parameter is not calculated.
;   status - INTEGER - If the module successfully calculated (where required) the solution sub-vectors "x1"
;                      and "x2", and the sub-matrices of the inverse of the full matrix, then "status" is
;                      set to "1". If the module was unable to calculate any of "x1", "x2", "Ainv", "Binv",
;                      "Cinv", or "Dinv" because the full matrix is singular, then "status" is set to "0".
;                      If the module failed for any other reason, then "status" is set to "-1".
;
; Keywords:
;
;   If the keyword SYMMETRIC is set (as "/SYMMETRIC"), then the module assumes that the full matrix is
;   symmetric. Consequently the input parameter "C" is ignored since it may be formed by transposing the
;   input parameter "B". Furthermore, if the full matrix is symmetric, then the inverse of the full matrix
;   is also symmetric, and hence the module does not calculate the output parameter "Cinv" since it may be
;   obtained by transposing the output parameter "Binv".
;
;   If the keyword POSITIVE_DEFINITE is set (as "/POSITIVE_DEFINITE") in addition to setting the keyword
;   SYMMETRIC, then the module will assume that the full matrix is symmetric and positive-definite, and
;   the module will employ Cholesky factorisation in place of LU factorisation, which is more efficient and
;   numerically stable. Setting the keyword POSITIVE_DEFINITE without setting the keyword SYMMETRIC has no
;   effect.
;
;   If the keyword NO_X1 is set (as "/NO_X1"), then the module will not calculate the solution sub-vector(s)
;   "x1". This option is useful for avoiding the operations required to calculate "x1" if this solution
;   sub-vector is not required, and it can therefore be used to build more efficient code.
;
;   If the keyword NO_ABCD_INVERSE is set (as "/NO_ABCD_INVERSE"), then the module will not calculate any of
;   the output parameters "Ainv", "Binv", "Cinv", or "Dinv", which allows the user to build more efficient
;   code if these output parameters are not required. Note that the module will fail if both of the keywords
;   NO_ABCD_INVERSE and ONLY_INVERSE are set at the same time.
;
;   If the keyword NO_ABC_INVERSE is set (as "/NO_ABC_INVERSE"), then the module will not calculate the output
;   parameters "Ainv", "Binv", or "Cinv", which allows the user to build more efficient code if these output
;   parameters are not required.
;
;   If the keyword NO_A_INVERSE is set (as "/NO_A_INVERSE"), then the module will not calculate the output
;   parameter "Ainv", which allows the user to build more efficient code if this output parameter is not
;   required. Note that if M is large (M > 10^4), then it may not even be feasible to store "Ainv" in memory,
;   and one may be forced to set this keyword in order to obtain the solution sub-vectors "x1" and "x2".
;
;   If the keyword ONLY_INVERSE is set (as "/ONLY_INVERSE"), then the module will ignore the input parameters
;   "v1" and "v2", and it will not calculate the output parameters "x1" and "x2". In this case, the module
;   will simply calculate the required sub-matrices of the inverse of the full matrix. Note that the module
;   will fail if both of the keywords NO_ABCD_INVERSE and ONLY_INVERSE are set at the same time.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
x1 = 0.0D
x2 = 0.0D
Ainv = 0.0D
Binv = 0.0D
Cinv = 0.0D
Dinv = 0.0D
status = -1

;Check that not both of the keywords NO_ABCD_INVERSE and ONLY_INVERSE are set at the same time
if (keyword_set(no_abcd_inverse) AND keyword_set(only_inverse)) then return

;Check that "A" is a one-dimensional vector of the correct number type and that it has at least two elements
test_fltdbl_1dvec, A, pstat, m, ptype
if (pstat EQ 0) then return
if (m LT 2L) then return
A_use = double(A)
m_m1 = m - 1L

;Check that "A" has no elements with a value of "0.0" indicating that the full matrix is singular
if (test_set_membership(0.0D, A_use, /NO_PAR_CHECK) EQ 1) then begin
  status = 0
  return
endif

;Check that "B" is a two-dimensional array of the correct number type and that the size of its second dimension
;is equal to the length of "A"
test_fltdbl_2darr, B, pstat, n, Bysize, ptype
if (pstat EQ 0) then return
if (Bysize NE m) then return
B_use = double(B)

;If the keyword SYMMETRIC is not set, then check that "C" is an array of the correct number type, dimensions,
;and size
if ~keyword_set(symmetric) then begin
  if (n GT 1L) then begin
    test_fltdbl_2darr, C, pstat, Cxsize, Cysize, ptype
    if (pstat EQ 0) then return
    if ((Cxsize NE m) OR (Cysize NE n)) then return
  endif else begin
    test_fltdbl_1dvec, C, pstat, Cxsize, ptype
    if (pstat EQ 0) then return
    if (Cxsize NE m) then return
  endelse
  C_use = double(C)
endif

;Check that "D" is an array of the correct number type, dimensions, and size
if (n GT 1L) then begin
  test_fltdbl_2darr, D, pstat, Dxsize, Dysize, ptype
  if (pstat EQ 0) then return
  if ((Dxsize NE n) OR (Dysize NE n)) then return
endif else begin
  if (test_fltdbl(D) NE 1) then return
  if (D.length NE 1L) then return
endelse
D_use = double(D)

;If the keyword ONLY_INVERSE is not set
if ~keyword_set(only_inverse) then begin

  ;Check that "v1" is an array of the correct number type, dimensions, and size, while determining how many
  ;right-hand side sub-vectors it contains
  if (test_fltdbl(v1) NE 1) then return
  nvdim = v1.ndim
  if (nvdim EQ 1L) then begin
    if (v1.length NE m) then return
    k = 1L
    v1_use = double(reform(v1, 1L, m))
  endif else if (nvdim EQ 2L) then begin
    vdim = v1.dim
    if (vdim[1] NE m) then return
    k = vdim[0]
    v1_use = double(v1)
  endif else return

  ;Check that "v2" is an array of the correct number type, dimensions, and size
  if ((k EQ 1L) AND (n EQ 1L)) then begin
    if (test_fltdbl(v2) NE 1) then return
    if (v2.length NE 1L) then return
    v2_use = double(v2)
  endif else if ((k EQ 1L) AND (n GT 1L)) then begin
    if (test_fltdbl(v2) NE 1) then return
    nvdim = v2.ndim
    if (nvdim EQ 1L) then begin
      if (v2.length NE n) then return
      v2_use = double(reform(v2, 1L, n))
    endif else if (nvdim EQ 2L) then begin
      vdim = v2.dim
      if ((vdim[0] NE 1L) OR (vdim[1] NE n)) then return
      v2_use = double(v2)
    endif else return
  endif else if ((k GT 1L) AND (n EQ 1L)) then begin
    test_fltdbl_1dvec, v2, pstat, v2xsize, ptype
    if (pstat EQ 0) then return
    if (v2xsize NE k) then return
    v2_use = double(v2)
  endif else begin
    test_fltdbl_2darr, v2, pstat, v2xsize, v2ysize, ptype
    if (pstat EQ 0) then return
    if ((v2xsize NE k) OR (v2ysize NE n)) then return
    v2_use = double(v2)
  endelse
endif

;Calculate the inverse of the diagonal sub-matrix "A"
A_use = 1.0D/temporary(A_use)

;If the keyword SYMMETRIC is set
if keyword_set(symmetric) then begin

  ;Calculate the NxM matrix "A^(-1) B"
  Apowm1_B = B_use
  for i = 0L,m_m1 do Apowm1_B[*,i] = A_use[i]*Apowm1_B[*,i]

  ;Calculate the NxN matrix "D - transpose(B) A^(-1) B"
  B_use = transpose(B_use)
  D_use = temporary(D_use) - (B_use ## Apowm1_B)

  ;Compute the LU factorisation (or Cholesky factorisation if the keyword POSITIVE_DEFINITE is set) of the
  ;NxN matrix "D - transpose(B) A^(-1) B"
  if (n GT 1L) then begin
    if keyword_set(positive_definite) then begin
      la_choldc, D_use, /DOUBLE, STATUS = stat
    endif else la_ludc, D_use, Dind, /DOUBLE, STATUS = stat
    if (stat GT 0L) then begin
      status = 0
      return
    endif
  endif else begin
    D_use = D_use[0]
    if (D_use EQ 0.0D) then begin
      status = 0
      return
    endif
    D_use = 1.0D/D_use
  endelse

  ;If the keyword ONLY_INVERSE is not set
  if ~keyword_set(only_inverse) then begin

    ;Calculate the KxN matrix "v2 - (transpose(B) A^(-1) v1)" and solve the system of linear equations for
    ;the solution sub-vector(s) "x2"
    for i = 0L,m_m1 do v1_use[*,i] = A_use[i]*v1_use[*,i]
    if (n GT 1L) then begin
      if keyword_set(positive_definite) then begin
        x2 = la_cholsol(D_use, v2_use - (B_use ## v1_use), /DOUBLE)
      endif else x2 = la_lusol(D_use, Dind, v2_use - (B_use ## v1_use), /DOUBLE)
    endif else x2 = D_use*(v2_use - (B_use ## v1_use))

    ;If required, calculate the solution sub-vector(s) "x1"
    if ~keyword_set(no_x1) then begin
      x1 = v1_use - (Apowm1_B ## x2)
      if (k EQ 1L) then x1 = reform(x1, m, /OVERWRITE)
    endif
    if ((n GT 1L) AND (k EQ 1L)) then x2 = reform(x2, n, /OVERWRITE)
  endif

  ;Set "status" to "1"
  status = 1

  ;If the keyword NO_ABCD_INVERSE is set, then return
  if keyword_set(no_abcd_inverse) then return

  ;Solve an identity system of linear equations to obtain the lower-right sub-matrix "Dinv" of the inverse
  ;of the full matrix
  if (n GT 1L) then begin
    if keyword_set(positive_definite) then begin
      Dinv = la_cholsol(D_use, identity(n, /DOUBLE), /DOUBLE)
    endif else Dinv = la_lusol(D_use, Dind, identity(n, /DOUBLE), /DOUBLE)
  endif else Dinv = [D_use]

  ;If the keyword NO_ABC_INVERSE is set, then return
  if keyword_set(no_abc_inverse) then return

  ;Calculate the upper-right sub-matrix "Binv" of the inverse of the full matrix
  if (n GT 1L) then begin
    Binv = Apowm1_B ## (-Dinv)
  endif else Binv = (-D_use)*Apowm1_B

  ;If the keyword NO_A_INVERSE is set, then return
  if keyword_set(no_a_inverse) then return

  ;Calculate the upper-left sub-matrix "Ainv" of the inverse of the full matrix, and return
  Ainv = dblarr(m,m)
  Ainv[generate_subscripts_for_diagonal_in_2darr(m, m, 0L, 0L, m, 'ur', stat, /NO_PAR_CHECK)] = A_use
  Ainv = temporary(Ainv) - matrix_multiply(Binv, Apowm1_B, /ATRANSPOSE)
  return
endif

;The rest of this code deals with the case that the keyword SYMMETRIC is not set. Firstly, calculate
;the NxM matrix "A^(-1) B".
for i = 0L,m_m1 do B_use[*,i] = A_use[i]*B_use[*,i]

;Calculate the NxN matrix "D - C A^(-1) B"
D_use = temporary(D_use) - (C_use ## B_use)

;Compute the LU factorisation of the NxN matrix "D - C A^(-1) B"
if (n GT 1L) then begin
  la_ludc, D_use, Dind, /DOUBLE, STATUS = stat
  if (stat GT 0L) then begin
    status = 0
    return
  endif
endif else begin
  D_use = D_use[0]
  if (D_use EQ 0.0D) then begin
    status = 0
    return
  endif
  D_use = 1.0D/D_use
endelse

;If the keyword ONLY_INVERSE is not set
if ~keyword_set(only_inverse) then begin

  ;Calculate the KxN matrix "v2 - (C A^(-1) v1)" and solve the system of linear equations for the solution
  ;sub-vector(s) "x2"
  for i = 0L,m_m1 do v1_use[*,i] = A_use[i]*v1_use[*,i]
  if (n GT 1L) then begin
    x2 = la_lusol(D_use, Dind, v2_use - (C_use ## v1_use), /DOUBLE)
  endif else x2 = D_use*(v2_use - (C_use ## v1_use))

  ;If required, calculate the solution sub-vector(s) "x1"
  if ~keyword_set(no_x1) then begin
    x1 = v1_use - (B_use ## x2)
    if (k EQ 1L) then x1 = reform(x1, m, /OVERWRITE)
  endif
  if ((n GT 1L) AND (k EQ 1L)) then x2 = reform(x2, n, /OVERWRITE)
endif

;Set "status" to "1"
status = 1

;If the keyword NO_ABCD_INVERSE is set, then return
if keyword_set(no_abcd_inverse) then return

;Solve an identity system of linear equations to obtain the lower-right sub-matrix "Dinv" of the inverse
;of the full matrix
if (n GT 1L) then begin
  Dinv = la_lusol(D_use, Dind, identity(n, /DOUBLE), /DOUBLE)
endif else Dinv = [D_use]

;If the keyword NO_ABC_INVERSE is set, then return
if keyword_set(no_abc_inverse) then return

;Calculate the upper-right sub-matrix "Binv" of the inverse of the full matrix and solve another identity
;system of linear equations to obtain the lower-left sub-matrix "Cinv" of the inverse of the full matrix
if (n GT 1L) then begin
  Binv = B_use ## (-Dinv)
  for i = 0L,m_m1 do C_use[i,*] = (-A_use[i])*C_use[i,*]
  Cinv = la_lusol(D_use, Dind, C_use, /DOUBLE)
endif else begin
  D_use = -D_use
  Binv = D_use*B_use
  Cinv = (A_use*temporary(C_use))*D_use
endelse

;If the keyword NO_A_INVERSE is set, then return
if keyword_set(no_a_inverse) then return

;Calculate the upper-left sub-matrix "Ainv" of the inverse of the full matrix
Ainv = dblarr(m,m)
Ainv[generate_subscripts_for_diagonal_in_2darr(m, m, 0L, 0L, m, 'ur', stat, /NO_PAR_CHECK)] = A_use
Ainv = temporary(Ainv) - (B_use ## Cinv)

END
