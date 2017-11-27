FUNCTION test_calendar_date, year, month, day, status, NO_PAR_CHECK = no_par_check

; Description: This function checks that the dates specified by "year", "month", and "day" are valid
;              calendar dates, taking into account the number of days in each month, and whether a year
;              is a leap year or not. If a date is a valid calendar date, then the function sets the
;              corresponding element of the return variable to "1", otherwise it sets the corresponding
;              element of the return variable to "0". The input parameters "year", "month", and "day"
;              may be scalars, vectors, or arrays.
;
; Input Parameters:
;
;   year - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of numbers that
;                                             represent the years in the calendar dates to be tested.
;   month - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array, with the same number of elements
;                                              as the input parameter "year", containing a set of
;                                              numbers that represent the month numbers in the calendar
;                                              dates to be tested. Month numbers run from "1" through
;                                              to "12".
;   day - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array, with the same number of elements
;                                            as the input parameter "year", containing a set of numbers
;                                            that represent the day numbers in the calendar dates to be
;                                            tested. The range of valid day numbers in a calendar date
;                                            depends on the month and year in the calendar date that is
;                                            being tested.
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input parameters, then "status" is
;                      returned with a value of "1", otherwise it is returned with a value of "0".
;
; Return Value:
;
;   The return variable is a SCALAR/VECTOR/ARRAY of INTEGER type, with the same dimensions as the
;   input parameter "year", where the value of each element is set to "1" if the corresponding elements
;   of the input parameters "year", "month", and "day" represent a valid calendar date, and set to "0"
;   otherwise.
;
; Keywords:
;
;   If the keyword NO_PAR_CHECK is set (as "/NO_PAR_CHECK"), then the function will not perform
;   parameter checking on the input parameters, reducing function overheads.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
status = 0

;Perform parameter checking if not instructed otherwise
if ~keyword_set(no_par_check) then begin

  ;Check that "year" is of the correct number type
  if (test_intlon(year) NE 1) then return, 0
  nyear = year.length

  ;Check that "month" is of the correct number type, and that it has the same number of elements as "year"
  if (test_intlon(month) NE 1) then return, 0
  if (month.length NE nyear) then return, 0

  ;Check that "day" is of the correct number type, and that it has the same number of elements as "year"
  if (test_intlon(day) NE 1) then return, 0
  if (day.length NE nyear) then return, 0
endif

;Determine which calendar dates are valid
date_tag = fix((day GT 0) AND (day LE determine_ndays_in_month(month, year, stat, /NO_PAR_CHECK)))

;Set "status" to "1"
status = 1

;Return the results of the calendar date test on the input parameters
if (year.ndim EQ 0L) then begin
  return, date_tag[0]
endif else return, reform(date_tag, year.dim, /OVERWRITE)

END
