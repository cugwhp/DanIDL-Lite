PRO extract_data_columns_from_lines, lines, column_numbers, column_types, ndata, status, errstr, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, $
                                     c16, c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27, c28, c29, c30, NO_NUMBER_CHECK = no_number_check, NO_PAR_CHECK = no_par_check

; Description: This module extracts up to 30 columns of data "c1", "c2", ..., "c30", each with "ndata" data values,
;              from the input set of strings "lines". These strings are usually lines that have been read in from an
;              ASCII data file. The column numbers to be extracted are specified by the parameter "column_numbers".
;              The module assumes that two adjacent data columns have white space separating them (which may be of
;              any length).
;                All requested data columns are first extracted from "lines" as vectors of strings. Where the
;              strings in "lines" do not contain data values for a specific column, empty strings are used as place
;              holders in the data columns. The parameter "column_types" then controls if any of the data columns
;              should be converted from STRING type to any of the number types BYTE, INTEGER, LONG, FLOAT, or DOUBLE.
;              Before type conversion occurs for a specific data column, each data value in that column is checked
;              to make sure that it is a string that represents a number so that the subsequent type conversion is
;              ensured to be error free. If a data value fails this check, then the module will fail, and it will
;              report which data value in which column caused the failure via the error string "errstr". If the user
;              is confident that the data values in the requested columns may be converted safely without checking
;              them, then the number check may be skipped by using the keyword NO_NUMBER_CHECK. Note that IDL will
;              "wrap" data values during the type conversion if they fall outside of the upper or lower limits of
;              the number type to which they are being converted.
;
;              N.B: (i) When calling this module, if N data columns are to be extracted where N is less than 30,
;                       then it is only necessary to specify the output parameters "c1", "c2", ..., "cN" on the
;                       command line. For example, if you want to extract only the first 4 data columns, then the
;                       module should be called as:
;
;                       extract_data_columns_from_lines, lines, [1,2,3,4], ['s','s','s','s'], ndata, status, errstr, c1, c2, c3, c4
;
;                   (ii) The implementation in this module does not use the string method ".split" because it is
;                        slower for scalar strings by a factor of ~1.5.
;
; Input Parameters:
;
;   lines - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing the set of strings from which the data
;                                        columns are to be extracted.
;   column_numbers - INTEGER/LONG VECTOR - A one-dimensional vector that contains the column numbers to be extracted
;                                          from "lines". The module assumes that column numbering starts from 1.
;                                          This vector may have up to 30 elements (corresponding to 30 columns to be
;                                          extracted), all of which must be positive and unique.
;   column_types - STRING VECTOR - A one-dimensional vector of strings of the same length as the input parameter
;                                  "column_numbers" that specifies the desired variable types of the output data
;                                  columns. The ith element of this vector specifies the desired variable type of
;                                  the ith output data column which in turn corresponds to the column number in
;                                  "lines" specified by the ith element of "column_numbers". The acceptable values
;                                  of the elements of this vector are:
;
;                                  s - The corresponding output data column should contain data values of STRING
;                                      type.
;                                  b - The corresponding output data column should be converted to numbers of the
;                                      type BYTE.
;                                  i - The corresponding output data column should be converted to numbers of the
;                                      type INTEGER.
;                                  l - The corresponding output data column should be converted to numbers of the
;                                      type LONG.
;                                  f - The corresponding output data column should be converted to numbers of the
;                                      type FLOAT.
;                                  d - The corresponding output data column should be converted to numbers of the
;                                      type DOUBLE.
;
; Output Parameters:
;
;   ndata - LONG - The number of data values in each of the output data columns "c1", "c2", ..., "cN".
;   status - INTEGER - If the module successfully extracted the requested data columns from the set of strings
;                      "lines", then "status" is returned with a value of "1", otherwise it is returned with a
;                      value of "0".
;   errstr - STRING - If the parameter "status" is returned with a value of "0", then "errstr" is returned with
;                     the corresponding error string, otherwise it is returned as an empty string.
;   c1 ---
;   c2   }
;   .    } - STRING/BYTE/INTEGER/LONG/FLOAT/DOUBLE VECTOR - Each of the output parameters "c1", "c2", ..., "cN"
;   .    }                                                  is a one-dimensional vector with "ndata" elements,
;   .    }                                                  where N is the number of requested data columns
;   cN ---                                                  (i.e. the number of elements in the input parameter
;                                                           "column_numbers"). The ith output parameter "ci"
;                                                           contains the column of data values extracted from
;                                                           "lines" from the column number specified by the ith
;                                                           element of "column_numbers". The variable type of the
;                                                           ith output parameter "ci" corresponds to the variable
;                                                           type specified by the ith element of the input parameter
;                                                           "column_types".
;   cN+1 ---
;   cN+2   }
;   .      } - UNDEFINED - Each of the remaining output parameters "cN+1", "cN+2", ..., "c30" are left undefined.
;   .      }
;   .      }
;   c30  ---
;
; Keywords:
;
;   If the keyword NO_NUMBER_CHECK is set (as "/NO_NUMBER_CHECK"), then the module will not check that the data
;   values in the data columns that are to be converted from STRING type to any of the number types BYTE, INTEGER,
;   LONG, FLOAT, or DOUBLE are strings that represent a number.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter checking
;   on the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
ndata = 0L
status = 0
errstr = ''

;If parameter checking is not required
if keyword_set(no_par_check) then begin

  ;Determine the length of the one-dimensional vector "column_numbers"
  ncolumn_numbers = column_numbers.length

;If parameter checking is required
endif else begin

  ;Check that "lines" is a variable of string type
  if (test_str(lines) NE 1) then begin
    errstr = 'ERROR - The input parameter "lines" is not a variable of string type...'
    return
  endif

  ;Check that "column_numbers" is a one-dimensional vector of the correct number type
  test_intlon_1dvec, column_numbers, stat, ncolumn_numbers, ctype
  if (stat EQ 0) then begin
    errstr = 'ERROR - The input parameter "column_numbers" is not a one-dimensional vector of the correct number type...'
    return
  endif

  ;Check that "column_numbers" has no more than 30 elements, and that all of the elements are positive and unique
  if (ncolumn_numbers GT 30L) then begin
    errstr = 'ERROR - The input parameter "column_numbers" has more than 30 elements...'
    return
  endif
  if (array_equal(column_numbers GT 0, 1B) EQ 0B) then begin
    errstr = 'ERROR - The input parameter "column_numbers" contains at least one number that is zero or negative...'
    return
  endif
  determine_unique_elements, column_numbers, column_numbers_unique, ncolumn_numbers_unique
  if (ncolumn_numbers_unique LT ncolumn_numbers) then begin
    errstr = 'ERROR - The input parameter "column_numbers" does not contain a set of unique numbers...'
    return
  endif

  ;Check that "column_types" is a string vector with the same number of elements as "column_numbers"
  test_str_1dvec, column_types, stat, ncolumn_types, ctype
  if (stat EQ 0) then begin
    errstr = 'ERROR - The input parameter "column_types" is not a string vector...'
    return
  endif
  if (ncolumn_types NE ncolumn_numbers) then begin
    errstr = 'ERROR - The input parameter "column_types" does not have the same number of elements as "column_numbers"...'
    return
  endif

  ;Check that "column_types" only contains the strings "s", "b", "i", "l", "f" and "d"
  if ((['b', 'd', 'f', 'i', 'l', 's']).hasvalue(column_types) EQ 0B) then begin
    errstr = 'ERROR - The input parameter "column_types" contains at least one unacceptable value...'
    return
  endif
endelse
column_numbers_m1 = long(column_numbers) - 1L

;Determine the number of data values in each of the output data columns
ndata = lines.length

;Set up the output parameters that will contain the data columns
c1 = strarr(ndata)
if (ncolumn_numbers GT 1L) then c2 = strarr(ndata)
if (ncolumn_numbers GT 2L) then c3 = strarr(ndata)
if (ncolumn_numbers GT 3L) then c4 = strarr(ndata)
if (ncolumn_numbers GT 4L) then c5 = strarr(ndata)
if (ncolumn_numbers GT 5L) then c6 = strarr(ndata)
if (ncolumn_numbers GT 6L) then c7 = strarr(ndata)
if (ncolumn_numbers GT 7L) then c8 = strarr(ndata)
if (ncolumn_numbers GT 8L) then c9 = strarr(ndata)
if (ncolumn_numbers GT 9L) then c10 = strarr(ndata)
if (ncolumn_numbers GT 10L) then c11 = strarr(ndata)
if (ncolumn_numbers GT 11L) then c12 = strarr(ndata)
if (ncolumn_numbers GT 12L) then c13 = strarr(ndata)
if (ncolumn_numbers GT 13L) then c14 = strarr(ndata)
if (ncolumn_numbers GT 14L) then c15 = strarr(ndata)
if (ncolumn_numbers GT 15L) then c16 = strarr(ndata)
if (ncolumn_numbers GT 16L) then c17 = strarr(ndata)
if (ncolumn_numbers GT 17L) then c18 = strarr(ndata)
if (ncolumn_numbers GT 18L) then c19 = strarr(ndata)
if (ncolumn_numbers GT 19L) then c20 = strarr(ndata)
if (ncolumn_numbers GT 20L) then c21 = strarr(ndata)
if (ncolumn_numbers GT 21L) then c22 = strarr(ndata)
if (ncolumn_numbers GT 22L) then c23 = strarr(ndata)
if (ncolumn_numbers GT 23L) then c24 = strarr(ndata)
if (ncolumn_numbers GT 24L) then c25 = strarr(ndata)
if (ncolumn_numbers GT 25L) then c26 = strarr(ndata)
if (ncolumn_numbers GT 26L) then c27 = strarr(ndata)
if (ncolumn_numbers GT 27L) then c28 = strarr(ndata)
if (ncolumn_numbers GT 28L) then c29 = strarr(ndata)
if (ncolumn_numbers GT 29L) then c30 = strarr(ndata)

;For each string in "lines"
for i = 0L,(ndata - 1L) do begin

  ;Extract the row of data values from the current string
  row_vec = strsplit(lines[i], ' ', /EXTRACT, COUNT = ncols)

  ;If the current string consists only of white spaces or is the empty string, then no further processing is necessary
  ;and the module will move on to the next string
  if (ncols EQ 0L) then continue

  ;For each column of data values to be extracted from "lines"
  for j = 0L,(ncolumn_numbers - 1L) do begin

    ;Determine the column number of the current data value to be extracted from the current string
    curr_column_number_m1 = column_numbers_m1[j]

    ;If the column number of the current data value to be extracted does not exist in the current string, then no
    ;further processing is necessary and the module will move on to the next data value
    if (curr_column_number_m1 GE ncols) then continue

    ;Extract the current data value from the requested column number in the current string and save it in the correct
    ;output data column
    case j of
      0L: c1[i] = row_vec[curr_column_number_m1]
      1L: c2[i] = row_vec[curr_column_number_m1]
      2L: c3[i] = row_vec[curr_column_number_m1]
      3L: c4[i] = row_vec[curr_column_number_m1]
      4L: c5[i] = row_vec[curr_column_number_m1]
      5L: c6[i] = row_vec[curr_column_number_m1]
      6L: c7[i] = row_vec[curr_column_number_m1]
      7L: c8[i] = row_vec[curr_column_number_m1]
      8L: c9[i] = row_vec[curr_column_number_m1]
      9L: c10[i] = row_vec[curr_column_number_m1]
      10L: c11[i] = row_vec[curr_column_number_m1]
      11L: c12[i] = row_vec[curr_column_number_m1]
      12L: c13[i] = row_vec[curr_column_number_m1]
      13L: c14[i] = row_vec[curr_column_number_m1]
      14L: c15[i] = row_vec[curr_column_number_m1]
      15L: c16[i] = row_vec[curr_column_number_m1]
      16L: c17[i] = row_vec[curr_column_number_m1]
      17L: c18[i] = row_vec[curr_column_number_m1]
      18L: c19[i] = row_vec[curr_column_number_m1]
      19L: c20[i] = row_vec[curr_column_number_m1]
      20L: c21[i] = row_vec[curr_column_number_m1]
      21L: c22[i] = row_vec[curr_column_number_m1]
      22L: c23[i] = row_vec[curr_column_number_m1]
      23L: c24[i] = row_vec[curr_column_number_m1]
      24L: c25[i] = row_vec[curr_column_number_m1]
      25L: c26[i] = row_vec[curr_column_number_m1]
      26L: c27[i] = row_vec[curr_column_number_m1]
      27L: c28[i] = row_vec[curr_column_number_m1]
      28L: c29[i] = row_vec[curr_column_number_m1]
      29L: c30[i] = row_vec[curr_column_number_m1]
    endcase
  endfor
endfor

;Determine which data columns should be converted from STRING type to any of the number types BYTE, INTEGER, LONG,
;FLOAT, or DOUBLE
subs = where(column_types NE 's', nsubs)

;If none of the data columns need to be converted, then set "status" to "1" and return
if (nsubs EQ 0L) then begin
  status = 1
  return
endif

;If the keyword NO_NUMBER_CHECK is not set
if ~keyword_set(no_number_check) then begin

  ;For each data column that needs to be converted
  for j = 0L,(nsubs - 1L) do begin

    ;Copy the current data column into a temporary variable
    csub = subs[j]
    case csub of
      0L: test_column = c1
      1L: test_column = c2
      2L: test_column = c3
      3L: test_column = c4
      4L: test_column = c5
      5L: test_column = c6
      6L: test_column = c7
      7L: test_column = c8
      8L: test_column = c9
      9L: test_column = c10
      10L: test_column = c11
      11L: test_column = c12
      12L: test_column = c13
      13L: test_column = c14
      14L: test_column = c15
      15L: test_column = c16
      16L: test_column = c17
      17L: test_column = c18
      18L: test_column = c19
      19L: test_column = c20
      20L: test_column = c21
      21L: test_column = c22
      22L: test_column = c23
      23L: test_column = c24
      24L: test_column = c25
      25L: test_column = c26
      26L: test_column = c27
      27L: test_column = c28
      28L: test_column = c29
      29L: test_column = c30
    endcase

    ;For each data value in the current data column
    for i = 0L,(ndata - 1L) do begin

      ;Check that the current data value in the current data column is a string that represents a number
      if (test_numstr_scalar(test_column[i]) EQ 'ERROR') then begin
        ndata = 0L
        undefine_variables, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27, c28, c29, c30
        errstr = 'ERROR - The data value number ' + scmp(i + 1L) + ' in column number ' + scmp(column_numbers_m1[csub] + 1L) + ' is not a string that represents a number...'
        return
      endif
    endfor
  endfor
endif

;For each data column that needs to be converted
for j = 0L,(nsubs - 1L) do begin

  ;Determine which number type the data values in the current data column should be converted to
  csub = subs[j]
  case column_types[csub] of
    'b': type_code = 1
    'i': type_code = 2
    'l': type_code = 3
    'f': type_code = 4
    'd': type_code = 5
  endcase

  ;Convert the data values in the current data column to the requested number type. Note that IDL will "wrap" data
  ;values during the type conversion if they fall outside of the upper or lower limits of the number type to which
  ;they are being converted.
  case csub of
    0L: c1 = fix(double(c1), TYPE = type_code)
    1L: c2 = fix(double(c2), TYPE = type_code)
    2L: c3 = fix(double(c3), TYPE = type_code)
    3L: c4 = fix(double(c4), TYPE = type_code)
    4L: c5 = fix(double(c5), TYPE = type_code)
    5L: c6 = fix(double(c6), TYPE = type_code)
    6L: c7 = fix(double(c7), TYPE = type_code)
    7L: c8 = fix(double(c8), TYPE = type_code)
    8L: c9 = fix(double(c9), TYPE = type_code)
    9L: c10 = fix(double(c10), TYPE = type_code)
    10L: c11 = fix(double(c11), TYPE = type_code)
    11L: c12 = fix(double(c12), TYPE = type_code)
    12L: c13 = fix(double(c13), TYPE = type_code)
    13L: c14 = fix(double(c14), TYPE = type_code)
    14L: c15 = fix(double(c15), TYPE = type_code)
    15L: c16 = fix(double(c16), TYPE = type_code)
    16L: c17 = fix(double(c17), TYPE = type_code)
    17L: c18 = fix(double(c18), TYPE = type_code)
    18L: c19 = fix(double(c19), TYPE = type_code)
    19L: c20 = fix(double(c20), TYPE = type_code)
    20L: c21 = fix(double(c21), TYPE = type_code)
    21L: c22 = fix(double(c22), TYPE = type_code)
    22L: c23 = fix(double(c23), TYPE = type_code)
    23L: c24 = fix(double(c24), TYPE = type_code)
    24L: c25 = fix(double(c25), TYPE = type_code)
    25L: c26 = fix(double(c26), TYPE = type_code)
    26L: c27 = fix(double(c27), TYPE = type_code)
    27L: c28 = fix(double(c28), TYPE = type_code)
    28L: c29 = fix(double(c29), TYPE = type_code)
    29L: c30 = fix(double(c30), TYPE = type_code)
  endcase
endfor

;Set "status" to "1"
status = 1

END
