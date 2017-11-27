PRO read_data_columns_from_ascii_file, filename, nheader, nlines_in, column_numbers, column_types, ndata, status, errstr, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, $
                                       c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27, c28, c29, c30, SKIP_LINES = skip_lines, $
                                       ONLY_LINES = only_lines, STARTING = starting, ENDING = ending, NO_NUMBER_CHECK = no_number_check, NO_PAR_CHECK = no_par_check

; Description: This module reads in up to 30 columns of data "c1", "c2", ..., "c30" from the ASCII file specified by
;              "filename". The module will skip the first "nheader" lines from the ASCII file, and then read in the
;              next "nlines_in" lines. The module provides the option of ignoring lines containing, or starting and/or
;              ending with, any non-empty substring drawn from a specific set of substrings via the use of combinations
;              of the keywords SKIP_LINES, STARTING and ENDING. Alternatively, the module provides the option of only
;              reading in lines containing, or starting and/or ending with, any non-empty substring drawn from a
;              specific set of substrings via the use of combinations of the keywords ONLY_LINES, STARTING and ENDING.
;              The actual number of lines read in is recorded in "ndata", corresponding to the number of elements in
;              each of the output parameters "c1", "c2", ..., "c30".
;                The column numbers to be extracted from the lines that have been read in from the ASCII file are
;              specified by the parameter "column_numbers". The module assumes that two adjacent data columns have
;              white space separating them (which may be of any length).
;                All requested data columns are first extracted from the lines that have been read in from the ASCII
;              file as vectors of strings. Where the lines that have been read in do not contain data values for a
;              specific column, empty strings are used as place holders in the data columns. The parameter
;              "column_types" then controls if any of the data columns should be converted from STRING type to any of
;              the number types BYTE, INTEGER, LONG, FLOAT, or DOUBLE. Before type conversion occurs for a specific
;              data column, each data value in that column is checked to make sure that it is a string that represents
;              a number so that the subsequent type conversion is ensured to be error free. If a data value fails this
;              check, then the module will fail, and it will report which data value in which column caused the failure
;              via the error string "errstr". If the user is confident that the data values in the requested columns
;              may be converted safely without checking them, then the number check may be skipped by using the keyword
;              NO_NUMBER_CHECK. Note that IDL will "wrap" data values during the type conversion if they fall outside
;              of the upper or lower limits of the number type to which they are being converted.
;
;              N.B: When calling this module, if N data columns are to be read in where N is less than 30, then it is
;                   only necessary to specify the output parameters "c1", "c2", ..., "cN" on the command line. For
;                   example, if you want to read in only the first 4 data columns, then the module should be called
;                   as:
;
;                   read_data_columns_from_ascii_file, filename, 0, 0, [1,2,3,4], ['s','s','s','s'], ndata, status, errstr, c1, c2, c3, c4
;
; Input Parameters:
;
;   filename - STRING - The file name of the ASCII file from which the data columns are to be read in. This parameter
;                       may be specified as a file name with or without an absolute or relative directory path. If
;                       this parameter is specified as a file name without a directory path, then the module will look
;                       for the ASCII file in the current working directory. If this parameter is specified as a file
;                       name with a relative directory path, then the module will look for the ASCII file in the
;                       relevant directory relative to the current working directory.
;   nheader - INTEGER/LONG - The number of header lines to be skipped when reading in the data columns from the ASCII
;                            file "filename". This parameter must be non-negative.
;   nlines_in - INTEGER/LONG - The number of data lines to be read in from the ASCII file "filename". If this parameter
;                              is zero or negative, then all data lines after the header line(s) will be read in. Lines
;                              containing, or starting or ending with, any non-empty substring drawn from a specific set
;                              of substrings defined by the keyword SKIP_LINES are not considered to be data lines and
;                              therefore do not count against the number of data lines to be read in specified by this
;                              parameter. Alternatively, lines containing, or starting or ending with, any non-empty
;                              substring drawn from a specific set of substrings defined by the keyword ONLY_LINES are
;                              the only lines that count against the number of data lines to be read in specified by
;                              this parameter. Note that the keywords SKIP_LINES and ONLY_LINES cannot both be set at
;                              the same time.
;   column_numbers - INTEGER/LONG VECTOR - A one-dimensional vector that contains the column numbers to be read in
;                                          from the ASCII file. The module assumes that column numbering starts from 1.
;                                          This vector may have up to 30 elements (corresponding to 30 columns to be
;                                          read in), all of which must be positive and unique.
;   column_types - STRING VECTOR - A one-dimensional vector of strings of the same length as the input parameter
;                                  "column_numbers" that specifies the desired variable types of the output data
;                                  columns. The ith element of this vector specifies the desired variable type of the
;                                  ith output data column which in turn corresponds to the column number in the ASCII
;                                  file specified by the ith element of "column_numbers". The acceptable values of the
;                                  elements of this vector are:
;
;                                  s - The corresponding output data column should contain data values of STRING type.
;                                  b - The corresponding output data column should be converted to numbers of the type
;                                      BYTE.
;                                  i - The corresponding output data column should be converted to numbers of the type
;                                      INTEGER.
;                                  l - The corresponding output data column should be converted to numbers of the type
;                                      LONG.
;                                  f - The corresponding output data column should be converted to numbers of the type
;                                      FLOAT.
;                                  d - The corresponding output data column should be converted to numbers of the type
;                                      DOUBLE.
;
; Output Parameters:
;
;   ndata - LONG - The number of data values in each of the output data columns "c1", "c2", ..., "cN".
;   status - INTEGER - If the module successfully read in the requested data columns from the ASCII file "filename",
;                      then "status" is returned with a value of "1", otherwise it is returned with a value of "0".
;   errstr - STRING - If the parameter "status" is returned with a value of "0", then "errstr" is returned with the
;                     corresponding error string, otherwise it is returned as an empty string.
;   c1 ---
;   c2   }
;   .    } - STRING/BYTE/INTEGER/LONG/FLOAT/DOUBLE VECTOR - Each of the output parameters "c1", "c2", ..., "cN" is a
;   .    }                                                  one-dimensional vector with "ndata" elements, where N is
;   .    }                                                  the number of requested data columns (i.e. the number of
;   cN ---                                                  elements in the input parameter "column_numbers"). The
;                                                           ith output parameter "ci" contains the column of data
;                                                           values read in from the ASCII file from the column number
;                                                           specified by the ith element of "column_numbers". The
;                                                           variable type of the ith output parameter "ci"
;                                                           corresponds to the variable type specified by the ith
;                                                           element of the input parameter "column_types".
;   cN+1 ---
;   cN+2   }
;   .      } - UNDEFINED - Each of the remaining output parameters "cN+1", "cN+2", ..., "c30" are left undefined.
;   .      }
;   .      }
;   c30  ---
;
; Keywords:
;
;   If the keyword SKIP_LINES is set to a SCALAR/VECTOR/ARRAY variable of STRING type, then lines from the ASCII
;   file which contain any of the non-empty substrings stored in this variable are ignored. If the keyword STARTING
;   is set at the same time as this keyword, then only lines which start with any of the non-empty substrings stored
;   in this variable are ignored. If the keyword ENDING is set at the same time as this keyword, then only lines
;   which end with any of the non-empty substrings stored in this variable are ignored. If both of the keywords
;   STARTING and ENDING are set at the same time as this keyword, then only lines which start or end with any of the
;   non-empty substrings stored in this variable are ignored. Note that the module will fail if both of the keywords
;   SKIP_LINES and ONLY_LINES are set at the same time.
;
;   If the keyword ONLY_LINES is set to a SCALAR/VECTOR/ARRAY variable of STRING type, then only lines which contain
;   any of the non-empty substrings stored in this variable are read in. If the keyword STARTING is set at the same
;   time as this keyword, then only lines which start with any of the non-empty substrings stored in this variable
;   are read in. If the keyword ENDING is set at the same time as this keyword, then only lines which end with any
;   of the non-empty substrings stored in this variable are read in. If both of the keywords STARTING and ENDING are
;   set at the same time as this keyword, then only lines which start or end with any of the non-empty substrings
;   stored in this variable are read in. Note that the module will fail if both of the keywords SKIP_LINES and
;   ONLY_LINES are set at the same time.
;
;   If the keyword STARTING is set (as "/STARTING"), then the module will only search for the presence of any
;   non-empty substring drawn from the set of substrings defined by the keywords SKIP_LINES/ONLY_LINES at the start
;   of each line. If the keyword ENDING is set at the same time as this keyword, then the module will only search
;   for the presence of any non-empty substring drawn from the set of substrings defined by the keywords
;   SKIP_LINES/ONLY_LINES at the start or the end of each line. This keyword has no effect if neither of the keywords
;   SKIP_LINES or ONLY_LINES are set.
;
;   If the keyword ENDING is set (as "/ENDING"), then the module will only search for the presence of any non-empty
;   substring drawn from the set of substrings defined by the keywords SKIP_LINES/ONLY_LINES at the end of each line.
;   If the keyword STARTING is set at the same time as this keyword, then the module will only search for the
;   presence of any non-empty substring drawn from the set of substrings defined by the keywords SKIP_LINES/ONLY_LINES
;   at the start or the end of each line. This keyword has no effect if neither of the keywords SKIP_LINES or
;   ONLY_LINES are set.
;
;   If the keyword NO_NUMBER_CHECK is set (as "/NO_NUMBER_CHECK"), then the module will not check that the data
;   values in the data columns that are to be converted from STRING type to any of the number types BYTE, INTEGER,
;   LONG, FLOAT, or DOUBLE are strings that represent a number.
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter checking on
;   the input parameters, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Read in the requested lines from the ASCII file "filename"
read_ascii_file, filename, nheader, nlines_in, lines, ndata, status, errstr, SKIP_LINES = skip_lines, ONLY_LINES = only_lines, STARTING = starting, ENDING = ending, $
                 NO_PAR_CHECK = no_par_check
if (status EQ 0) then return

;Extract the required data columns from the lines that have been read in from the ASCII file
extract_data_columns_from_lines, lines, column_numbers, column_types, ndata, status, errstr, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, $
                                 c16, c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27, c28, c29, c30, NO_NUMBER_CHECK = no_number_check, NO_PAR_CHECK = no_par_check

END
