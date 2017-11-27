PRO swap_variables, var1, var2, status, NO_PAR_CHECK = no_par_check

; Description: This module swaps the information stored in the variable "var1" with the information
;              stored in the variable "var2" without creating unnecessary copies of either of the
;              variables. The module will fail if either of the input parameters is undefined. Note
;              that this module by definition changes the content of each of the input parameters
;              "var1" and "var2".
;
; Input Parameters:
;
;   var1 - ANY SCALAR/VECTOR/ARRAY - A scalar/vector/array of input data to be moved to the variable
;                                    "var2". This input parameter must not be undefined.
;   var2 - ANY SCALAR/VECTOR/ARRAY - A scalar/vector/array of input data to be moved to the variable
;                                    "var1". This input parameter must not be undefined.
;
; Output Parameters:
;
;   status - INTEGER - If the module successfully swapped the information stored in each of the
;                      variables "var1" and "var2", then "status" is returned with a value of "1",
;                      otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform
;   parameter checking on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that both "var1" and "var2" are not undefined
  if (test_variable_is_defined(var1) NE 1) then return
  if (test_variable_is_defined(var2) NE 1) then return
endif

;Swap the information stored in the variable "var1" with the information stored in the variable "var2"
tmpvar = temporary(var1)
var1 = temporary(var2)
var2 = temporary(tmpvar)

;Set "status" to "1"
status = 1

END
