FUNCTION decode_bit_pattern, bit_pattern_data, compare_bits, status, danidl_cppcode, SATISFY_ALL = satisfy_all, SATISFY_ANY = satisfy_any, $
                             OUTPUT_TRUE_VALUE = output_true_value, OUTPUT_FALSE_VALUE = output_false_value, NO_PAR_CHECK = no_par_check

; Description: Given a set of non-negative integers "bit_pattern_data" that each represent a pattern of bits
;              that are set (or the equivalent binary number), this function determines for each input integer
;              value whether or not at least one of the comparison bits "compare_bits" are set. The return
;              value for each input integer value is set to "1" if the input integer value has at least one of
;              the comparison bits "compare_bits" set, and it is set to "0" if the input integer value does
;              not have any of the comparison bits "compare_bits" set.
;                If the keyword SATISFY_ALL is set, then the function will set the return value to "1" for
;              each input integer value that has all of the comparison bits "compare_bits" set, and it will
;              set the return value to "0" otherwise.
;                Alternatively, if the keyword SATISFY_ANY is set, then the function will set the return value
;              to "1" for each input integer value that has at least one bit set, regardless of the which bit
;              is set, and it will set the return value to "0" otherwise. In this case, the input parameter
;              "compare_bits" is ignored.
;                Finally, the function allows the user to configure the return values by setting the
;              OUTPUT_TRUE_VALUE and OUTPUT_FALSE_VALUE keywords to numbers that should be used to replace
;              the return values of "1" and "0" respectively.
;                This module will use C++ code if possible to achieve a faster execution than the default IDL
;              code. The C++ code can be up to a factor of ~1.01 times faster than the IDL code in this case.
;
; Input Parameters:
;
;   bit_pattern_data - BYTE/INTEGER/LONG SCALAR/VECTOR/ARRAY - The set of bit-pattern values, stored as integer
;                                                              numbers, that are to be compared with the set of
;                                                              comparison bits "compare_bits". All elements of
;                                                              this parameter must be non-negative.
;   compare_bits - BYTE/INTEGER/LONG SCALAR/VECTOR/ARRAY - The set of comparison bits, stored as integer
;                                                          numbers, to be checked in the set of bit-pattern
;                                                          values "bit_pattern_data". All elements of this
;                                                          parameter must be positive. Note that each element
;                                                          of this input parameter may represent a single
;                                                          comparison bit (i.e. a power of two), or multiple
;                                                          comparison bits (i.e. not a power of two).
;   status - ANY - A variable which will be used to contain the output status of the function on returning (see
;                  output parameters below).
;   danidl_cppcode - STRING - The full directory path indicating where the DanIDL C++ code is installed. The
;                             shared library of DanIDL C++ routines should exist as
;                             "<danidl_cppcode>/dist/libDanIDL.so" within the installation. If this input
;                             parameter is not specified correctly, then the default IDL code will be used
;                             instead.
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input value(s), then "status" is returned with
;                      a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The return value is a SCALAR/VECTOR/ARRAY of INTEGER type, with the same dimensions as the input parameter
;   "bit_pattern_data", that takes a value of "1" where the input integer values have at least one of the
;   comparison bits "compare_bits" set, and that takes a value of "0" where the input integer values do not have
;   any of the comparison bits "compare_bits" set. Note that this behaviour is modified if any of the keywords
;   SATISFY_ALL, SATISFY_ANY, OUTPUT_TRUE_VALUE and OUTPUT_FALSE_VALUE are set (see "Keywords" below).
;
; Keywords:
;
;   If the keyword SATISFY_ALL is set (as "/SATISFY_ALL"), then the function will set the return value to "1"
;   where the input integer values have all of the comparison bits "compare_bits" set, and it will set the
;   return value to "0" otherwise. Note that the keywords SATISFY_ALL and SATISFY_ANY cannot both be set at
;   the same time.
;
;   If the keyword SATISFY_ANY is set (as "/SATISFY_ANY"), then the function will set the return value to "1"
;   where the input integer values have at least one bit set, regardless of the which bit is set, and it will
;   set the return value to "0" otherwise. In this case, the input parameter "compare_bits" is ignored. Note
;   that the keywords SATISFY_ALL and SATISFY_ANY cannot both be set at the same time.
;
;   If the keyword OUTPUT_TRUE_VALUE is set to an INTEGER value, then the value of this keyword will be used
;   in place of the return value "1".
;
;   If the keyword OUTPUT_FALSE_VALUE is set to an INTEGER value, then the value of this keyword will be used
;   in place of the return value "0".
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform parameter
;   checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "bit_pattern_data" contains non-negative numbers of the correct number type
  if (test_bytintlon(bit_pattern_data) NE 1) then return, 0
  if (array_equal(bit_pattern_data GE 0B, 1B) EQ 0B) then return, 0

  ;Check that the keywords SATISFY_ALL and SATISFY_ANY are not both set at the same time
  if (keyword_set(satisfy_all) AND keyword_set(satisfy_any)) then return, 0

  ;If necessary, check that "compare_bits" contains positive numbers of the correct number type
  if ~keyword_set(satisfy_any) then begin
    if (test_bytintlon(compare_bits) NE 1) then return, 0
    if (array_equal(compare_bits GT 0B, 1B) EQ 0B) then return, 0
  endif
endif

;If the keyword SATISFY_ANY is not set, then calculate the integer value that represents the bit-pattern
;with all of the input comparison bits set
if ~keyword_set(satisfy_any) then compare_bit_pattern = bitwise_or(compare_bits, stat, danidl_cppcode)

;If the keyword SATISFY_ANY is set
if keyword_set(satisfy_any) then begin

  ;Any non-zero integer value indicates that at least one bit is set. Therefore, determine which input
  ;integer values have at least one bit set by determining which input integer values are greater than
  ;zero.
  output_values = fix(bit_pattern_data GT 0B)

;If the keyword SATISFY_ALL is set
endif else if keyword_set(satisfy_all) then begin

  ;Determine which input integer values have all of the comparison bits set
  output_values = fix((bit_pattern_data AND compare_bit_pattern) EQ compare_bit_pattern)

;If neither of the keywords SATISFY_ALL or SATISFY_ANY are set
endif else begin

  ;Determine which input integer values have at least one of the comparison bits set
  output_values = fix((bit_pattern_data AND compare_bit_pattern) GT 0B)
endelse

;Set the required output true and false values
output_tv = 1
output_fv = 0
if (test_int_scalar(output_true_value) EQ 1) then output_tv = output_true_value
if (test_int_scalar(output_false_value) EQ 1) then output_fv = output_false_value
c1 = output_tv - output_fv
if ((c1 EQ 1) AND (output_fv NE 0)) then begin
  output_values = temporary(output_values) + output_fv
endif else if (c1 NE 1) then begin
  if (output_fv EQ 0) then begin
    output_values = c1*temporary(output_values)
  endif else output_values = (c1*temporary(output_values)) + output_fv
endif

;Set "status" to "1"
status = 1

;Return the output values
return, output_values

END
