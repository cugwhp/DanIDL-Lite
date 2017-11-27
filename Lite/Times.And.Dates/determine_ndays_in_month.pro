FUNCTION determine_ndays_in_month, month, year, status, NO_PAR_CHECK = no_par_check

; Description: This function returns the number of days in the month for a set of months "month" taking
;              into account if the associated years "year" are leap years or not. The input parameters
;              "month" and "year" may be scalars, vectors, or arrays.
;
; Input Parameters:
;
;   month - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of numbers that
;                                              represent the month numbers for which the number of days
;                                              in the month are required. Month numbers run from "1"
;                                              through to "12".
;   year - INTEGER/LONG SCALAR/VECTOR/ARRAY - A scalar/vector/array, with the same number of elements
;                                             as the input parameter "month", containing a set of
;                                             numbers that represent the years corresponding to the
;                                             month numbers in "month".
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
;   The return variable is a SCALAR/VECTOR/ARRAY of INTEGER type, with the same dimensions as the input
;   parameter "month", where the value of each element represents the number of days in the month for
;   the corresponding elements of the input parameters "month" and "year". If an element of "month"
;   does not represent a valid month number, then the corresponding element in the return variable is
;   set to "0".
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

  ;Check that "month" is of the correct number type
  if (test_intlon(month) NE 1) then return, 0

  ;Check that "year" is of the correct number type, and that it has the same number of elements as "month"
  if (test_intlon(year) NE 1) then return, 0
  if (year.length NE month.length) then return, 0
endif
nmonth = month.length

;Determine the number of days in the month for each input month, except where the month is February
ndays = replicate(31, nmonth)
subs = where((month LT 1) OR (month GT 12), nsubs)
if (nsubs GT 0L) then ndays[subs] = 0
subs = where((month EQ 4) OR (month EQ 6) OR (month EQ 9) OR (month EQ 11), nsubs)
if (nsubs GT 0L) then ndays[subs] = 30

;If there is at least one input month that is February
subs = where(month EQ 2, nsubs)
if (nsubs GT 0L) then begin

  ;If all input months are February
  if (nsubs EQ nmonth) then begin

    ;Determine the number of days in the month for each input month and year combination, given that the
    ;input month is February
    leap_year_subs = where(test_leap_year(year, /NO_PAR_CHECK) EQ 1, n_leap_year_subs, COMPLEMENT = normal_year_subs)
    if (n_leap_year_subs EQ 0L) then begin
      ndays[subs] = 28
    endif else if (n_leap_year_subs EQ nsubs) then begin
      ndays[subs] = 29
    endif else begin
      ndays[normal_year_subs] = 28
      ndays[leap_year_subs] = 29
    endelse

  ;If not all input months are February
  endif else begin

    ;Determine the number of days in the month for each input month and year combination, given that the
    ;input month is February
    leap_year_subs = where(test_leap_year(year[subs], /NO_PAR_CHECK) EQ 1, n_leap_year_subs, COMPLEMENT = normal_year_subs)
    if (n_leap_year_subs EQ 0L) then begin
      ndays[subs] = 28
    endif else if (n_leap_year_subs EQ nsubs) then begin
      ndays[subs] = 29
    endif else begin
      ndays[subs[normal_year_subs]] = 28
      ndays[subs[leap_year_subs]] = 29
    endelse
  endelse
endif

;Set "status" to "1"
status = 1

;Return the number of days in the month for each input month and year combination
if (month.ndim EQ 0L) then begin
  return, ndays[0]
endif else return, reform(ndays, month.dim, /OVERWRITE)

END
