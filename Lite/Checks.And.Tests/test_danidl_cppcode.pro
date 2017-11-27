PRO test_danidl_cppcode, danidl_cppcode, danidl_cpp_shared_lib, status

; Description: This module determines if the shared library of DanIDL C++ routines is installed as a
;              readable file in the directory specified by "danidl_cppcode", and returns the full
;              directory path and file name of the shared library via the parameter
;              "danidl_cpp_shared_lib".
;
; Input Parameters:
;
;   danidl_cppcode - ANY - The parameter to be tested whether or not it is a string that specifies the
;                          full directory path within which the shared library of DanIDL C++ routines
;                          is installed as a readable file.
;
; Output Parameters:
;
;   danidl_cpp_shared_lib - STRING - The full directory path and file name of the shared library of
;                                    DanIDL C++ routines.
;   status - INTEGER - The parameter "status" is set to "1" if "danidl_cppcode" is a string that
;                      specifies the full directory path within which the shared library of DanIDL C++
;                      routines is installed as a readable file. Otherwise, the module sets the value
;                      of "status" to "0".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
danidl_cpp_shared_lib = ''
status = 0

;Check that "danidl_cppcode" contains a string representing a directory path
if (test_dirstr_scalar(danidl_cppcode) NE 1) then return

;Check that the shared library of DanIDL C++ routines exists and is readable
str = danidl_cppcode + '/dist/libDanIDL.so'
if (file_test(str, /REGULAR, /READ) NE 1L) then return
danidl_cpp_shared_lib = str

;Set "status" to "1"
status = 1

END
