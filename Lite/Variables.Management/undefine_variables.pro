PRO undefine_variables, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30

; Description: This module undefines up to 30 variables "v1", "v2", ..., "v30" in the IDL module/function
;              from which it is called, freeing up the associated memory resources.
;
;              N.B: (i) When calling this module, if only N variables are to be undefined, then it is only
;                       necessary to specify the input parameters "v1", "v2", ..., "vN" on the command line.
;                       For example, to undefine only the variables "xc", "yc" and "zc", then the module
;                       should be called as:
;
;                       undefine_variables, xc, yc, zc
;
;                   (ii) The implementation in this module uses the IDL function "n_elements()" instead of
;                        the variable attribute ".length" because the attribute ".length" will cause an
;                        error for variables that happen to already be undefined.
;
; Input Parameters:
;
;   v1 ----
;   v2    }
;   .     } - ANY - The variables to be undefined in the IDL module/function from which this module is
;   .     }         called.
;   .     }
;   v30 ---
;
; Output Parameters:
;
;   None.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Determine the number of variables to be undefined
nvar = n_params()

;If there are no variables to be undefined, then return
if (nvar EQ 0L) then return

;Undefine each variable
x = n_elements(temporary(v1))
if (nvar EQ 1L) then return
x = n_elements(temporary(v2))
if (nvar EQ 2L) then return
x = n_elements(temporary(v3))
if (nvar EQ 3L) then return
x = n_elements(temporary(v4))
if (nvar EQ 4L) then return
x = n_elements(temporary(v5))
if (nvar EQ 5L) then return
x = n_elements(temporary(v6))
if (nvar EQ 6L) then return
x = n_elements(temporary(v7))
if (nvar EQ 7L) then return
x = n_elements(temporary(v8))
if (nvar EQ 8L) then return
x = n_elements(temporary(v9))
if (nvar EQ 9L) then return
x = n_elements(temporary(v10))
if (nvar EQ 10L) then return
x = n_elements(temporary(v11))
if (nvar EQ 11L) then return
x = n_elements(temporary(v12))
if (nvar EQ 12L) then return
x = n_elements(temporary(v13))
if (nvar EQ 13L) then return
x = n_elements(temporary(v14))
if (nvar EQ 14L) then return
x = n_elements(temporary(v15))
if (nvar EQ 15L) then return
x = n_elements(temporary(v16))
if (nvar EQ 16L) then return
x = n_elements(temporary(v17))
if (nvar EQ 17L) then return
x = n_elements(temporary(v18))
if (nvar EQ 18L) then return
x = n_elements(temporary(v19))
if (nvar EQ 19L) then return
x = n_elements(temporary(v20))
if (nvar EQ 20L) then return
x = n_elements(temporary(v21))
if (nvar EQ 21L) then return
x = n_elements(temporary(v22))
if (nvar EQ 22L) then return
x = n_elements(temporary(v23))
if (nvar EQ 23L) then return
x = n_elements(temporary(v24))
if (nvar EQ 24L) then return
x = n_elements(temporary(v25))
if (nvar EQ 25L) then return
x = n_elements(temporary(v26))
if (nvar EQ 26L) then return
x = n_elements(temporary(v27))
if (nvar EQ 27L) then return
x = n_elements(temporary(v28))
if (nvar EQ 28L) then return
x = n_elements(temporary(v29))
if (nvar EQ 29L) then return
x = n_elements(temporary(v30))

END
