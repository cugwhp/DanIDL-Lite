FUNCTION test_time_in_hours, time, status

; Description: This function checks that the elements of the input parameter "time" are either numbers
;              representing hours in the range "0.0 <= time < 24.0" ("time" may be of number type or
;              string type in this case) or valid time strings of the format "HH:MM:SS.SSS". If an
;              element of "time" satisfies any of these conditions, then the function converts this
;              element to a double precision number representing a time in hours and stores the value
;              in the corresponding element of the return variable. If an element of "time" does not
;              satisfy any of these conditions, then the function writes the value of "-1.0" to the
;              corresponding element of the return variable. The input parameter "time" may be a
;              scalar, vector, or array.
;
; Input Parameters:
;
;   time - NUMBER/STRING SCALAR/VECTOR/ARRAY - A scalar/vector/array containing a set of numbers to
;                                              be tested for representing a time in hours in the
;                                              range "0.0 <= time < 24.0" ("time" may be of number
;                                              type or string type in this case) or containing a set
;                                              of strings to be tested for the format "HH:MM:SS.SSS".
;   status - ANY - A variable which will be used to contain the output status of the function on
;                  returning (see output parameters below).
;
; Output Parameters:
;
;   status - INTEGER - If the function successfully processed the input number(s)/string(s), then
;                      "status" is returned with a value of "1", otherwise it is returned with a
;                      value of "0".
;
; Return Value:
;
;   The function returns a DOUBLE type variable, with the same dimensions as the input parameter
;   "time". If an element of "time" is a number representing hours in the range "0.0 <= time < 24.0"
;   ("time" may be of number type or string type in this case), then the corresponding element of
;   the return variable is set to the double precision value of the current element of "time". If
;   an element of "time" is a valid time string of the format "HH:MM:SS.SSS", then the corresponding
;   element of the return variable is set to the value of the time string converted into a decimal
;   number in hours. If an element of "time" does not satisfy either of the previously described
;   cases, then the corresponding element of the return variable is set to the value "-1.0".
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values   
status = 0

;If "time" is of string type
if (test_str(time) EQ 1) then begin

  ;Attempt to convert the elements of "time" from the format "HH:MM:SS.SSS" to double precision numbers
  ;representing times in hours
  time_out = hms2hours(time, stat, /NO_PAR_CHECK)

  ;Determine which elements of "time" are not of the format "HH:MM:SS.SSS"
  subs = where(time_out EQ -1.0D, nsubs)

  ;If all of the elements of "time" are of the format "HH:MM:SS.SSS" (and have therefore been successfully
  ;converted to double precision numbers representing times in hours)
  if (nsubs EQ 0L) then begin

    ;Set "status" to "1"
    status = 1

    ;Return the elements of "time" as double precision numbers representing times in hours
    return, time_out
  endif

  ;Check which elements of "time" are strings that represent numbers
  time_tmp = test_numstr(time[subs], stat, /NO_PAR_CHECK)
  ok_subs = where(time_tmp NE 'ERROR', nok_subs)

  ;If at least one of the elements of "time" is a string that represents a number
  if (nok_subs GT 0L) then begin

    ;Convert the elements of "time" that are strings representing numbers into double precision numbers
    if (nok_subs LT nsubs) then begin
      time_tmp = double(time_tmp[ok_subs])
      subs = subs[ok_subs]
    endif else time_tmp = double(time_tmp)

    ;Determine which elements of "time" that are strings representing numbers lie outside the range
    ;"0.0 <= time < 24.0", and set the corresponding elements in the return variable to "-1.0"
    range_subs = where((time_tmp LT 0.0D) OR (time_tmp GE 24.0D), nrange_subs)
    if (nrange_subs GT 0L) then time_tmp[range_subs] = -1.0D

    ;Transfer the converted elements of "time" that were strings representing numbers to the return
    ;variable
    time_out[subs] = temporary(time_tmp)
  endif

  ;Set "status" to "1"
  status = 1

  ;Return the elements of "time" as double precision numbers with those elements that do not lie in the
  ;range "0.0 <= time < 24.0" set to the value "-1.0"
  return, time_out
endif

;If "time" contains numbers
test_num, time, numstat, numtype
if (numstat EQ 1) then begin

  ;Convert the elements of "time" to double precision numbers
  time_out = double(time)

  ;Determine which elements of "time" lie outside the range "0.0 <= time < 24.0", and set the corresponding
  ;elements in the return variable to "-1.0"
  range_subs = where((time_out LT 0.0D) OR (time_out GE 24.0D), nrange_subs)
  if (nrange_subs GT 0L) then time_out[range_subs] = -1.0D

  ;Set "status" to "1"
  status = 1

  ;Return the elements of "time" as double precision numbers with those elements that do not lie in the
  ;range "0.0 <= time < 24.0" set to the value "-1.0"
  return, time_out
endif

;Return the default value for the return variable since, by reaching this point, the input parameter "time"
;is not of string type and it does not contain numbers
return, -1.0D

END
