PRO split_full_file_name_to_directory_file, filenames, directories, files, status, NO_PAR_CHECK = no_par_check

; Description: This module takes a set of file names with full directory paths "filenames" and returns the
;              corresponding sets of directory paths "directories" without the file names, and file names
;              "files" without the directory paths.
;
; Input Parameters:
;
;   filenames - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of file names with full
;                                            directory paths that are to be processed.
;
; Output Parameters:
;
;   directories - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array of strings of the same dimensions as
;                                              "filenames" that contains the set of directory paths (without
;                                              file names) corresponding to the input set of file names with
;                                              full directory paths "filenames". In more detail, if an element
;                                              of "filenames" does not start with the character '/', then the
;                                              corresponding element of "directories" is set to the empty
;                                              string ''. However, if an element of "filenames" does start
;                                              with the character '/', then the corresponding element of
;                                              "directories" is set to the substring in the element of
;                                              "filenames" that starts with the first character and ends with
;                                              the last occurrence of the character '/'. For example, the
;                                              "filenames" element '/data/dmb/ngc7789.fits' would be converted
;                                              to the string '/data/dmb/', and the "filenames" element '/data'
;                                              would be converted to the string '/'.
;   files - STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array of strings of the same dimensions as "filenames"
;                                        that contains the set of file names (without directory paths)
;                                        corresponding to the input set of file names with full directory paths
;                                        "filenames". In more detail, if an element of "filenames" does not
;                                        contain any occurrences of the character '/', then the corresponding
;                                        element of "files" is set to a copy of the current element of
;                                        "filenames". However, if an element of "filenames" does contain
;                                        occurrences of the character '/', then the corresponding element of
;                                        "files" is set to the string of characters after the last occurrence
;                                        of the character '/', even if this is the empty string ''. For example,
;                                        the "filenames" element '/data/dmb/ngc7789.fits' would be converted to
;                                        the string 'ngc7789.fits', and the "filenames" element 'DanIDL.pro'
;                                        would be converted to the string 'DanIDL.pro'.
;   status - INTEGER - If the module successfully processed the input file names, then "status" is returned
;                      with a value of "1", otherwise it is returned with a value of "0".
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the module will not perform parameter checking
;   on the input parameter, reducing module overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
directories = ''
files = ''
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "filenames" is a variable of string type
  if (test_str(filenames) NE 1) then return
endif

;Determine the set of output directory paths
directories = extract_directory_from_full_file_name(filenames, stat, /NO_PAR_CHECK)

;Determine the set of output file names
files = extract_file_from_full_file_name(filenames, stat, /NO_PAR_CHECK)

;Set "status" to "1"
status = 1

END
