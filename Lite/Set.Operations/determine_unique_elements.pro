PRO determine_unique_elements, data, unique, nunique, UNIQUE_SUBS = unique_subs, REPEAT_SUBS = repeat_subs, NREPEAT = nrepeat, ORIGINAL_ORDERING = original_ordering, $
                               DATA_ALREADY_SORTED = data_already_sorted

; Description: This module determines the set of unique elements in the input array "data" and returns
;              this set as a vector of unique elements "unique" sorted into ascending order, along with
;              the number of unique elements "nunique". There are also options to return the subscripts
;              of the unique elements in the input array "data" via the keyword UNIQUE_SUBS, the
;              subscripts of the repeat elements in the input array "data" via the keyword REPEAT_SUBS,
;              and the number of repeat elements in the input array "data" via the keyword NREPEAT.
;                The module also provides the option of returning the set of unique elements in the input
;              array "data" in the same order as the original ordering of the elements in "data", rather
;              than returning the set of unique elements sorted into ascending order. In this case, the
;              subscripts "unique_subs" and "repeat_subs" of the unique and repeat elements,
;              respectively, in the input array "data" will also be in the order corresponding to the
;              original ordering of the elements in "data" (which happens to be in ascending order for
;              the subscripts themselves!). This behaviour may be achieved by setting the keyword
;              ORIGINAL_ORDERING.
;
; Input Parameters:
;
;   data - ANY SCALAR/VECTOR/ARRAY - A scalar/vector/array of input data. This parameter must be defined,
;                                    and not an IDL structure.
;
; Output Parameters:
;
;   unique - VECTOR (same type as "data") - A one-dimensional vector consisting of the set of unique
;                                           elements in "data" sorted into ascending order. If the
;                                           keyword ORIGINAL_ORDERING is set (see below), then the
;                                           ordering of the elements in "unique" matches the original
;                                           ordering of the elements in "data".
;   nunique - LONG - The number of elements in the output parameter "unique". This parameter is set to
;                    "0" if "data" is undefined or an IDL structure.
;
; Keywords:
;
;   If the keyword UNIQUE_SUBS is set to a named variable, then, on return, this variable will contain
;   a VECTOR of LONG type numbers representing the subscripts of the unique elements in the input array
;   "data". Note that "unique" and "data[unique_subs]" are the same vectors.
;
;   If the keyword REPEAT_SUBS is set to a named variable, then, on return, this variable will contain
;   a VECTOR of LONG type numbers representing the subscripts of the repeat elements in the input array
;   "data". The repeat elements themselves may be obtained by constructing the vector "data[repeat_subs]".
;   Note that if there are no repeat elements in the input array "data", then "repeat_subs" is set to
;   the single element vector "[-1L]".
;
;   If the keyword NREPEAT is set to a named variable, then, on return, this variable will contain a
;   LONG type SCALAR number that represents the number of repeat elements in the input array "data".
;
;   If the keyword ORIGINAL_ORDERING is set (as "/ORIGINAL_ORDERING), then the unique elements "unique"
;   will be returned in the same order as the original ordering of the elements in "data", rather than
;   being returned in ascending order. Furthermore, the subscripts "unique_subs" and "repeat_subs" of
;   the unique and repeat elements, respectively, will be in the order corresponding to the original
;   ordering of the elements in "data" (which happens to be in ascending order for the subscripts
;   themselves!).
;
;   If the keyword DATA_ALREADY_SORTED is set (as "/DATA_ALREADY_SORTED"), then the module will assume
;   that the values of "data" are already sorted into ascending order. This option can be used to avoid
;   a number of operations including a sort operation on the input parameter "data", which allows the
;   user to build more efficient code with this module.
;
; Author: Dan Bramich (dan.bramich@hotmail.co.uk)


;Set the default output parameter values
unique = [0.0]
nunique = 0L
unique_subs = [-1L]
repeat_subs = [-1L]
nrepeat = 0L

;Check that "data" is defined, and that it is not an IDL structure
dtype = determine_idl_type_as_int(data)
if ((dtype EQ 0) OR (dtype EQ 8)) then return

;Determine the number of elements in "data"
ndata = data.length

;If "data" has one element
if (ndata EQ 1L) then begin
  unique = [data[0L]]
  nunique = 1L
  unique_subs = [0L]
  return
endif

;If "data" is already sorted
if keyword_set(data_already_sorted) then begin

  ;Find the positions in the data where adjacent elements are different
  unique_subs = where(data[1L:(ndata - 1L)] NE data[0L:(ndata - 2L)], nunique, COMPLEMENT = repeat_subs, NCOMPLEMENT = nrepeat)
  nunique = nunique + 1L

  ;If all of the elements in "data" are unique
  if (nunique EQ ndata) then begin

    ;Construct the output vector of unique elements, and the subscripts of the unique and repeat
    ;elements in "data", and then return
    unique = reform(data, ndata)
    unique_subs = lindgen(ndata)
    repeat_subs = [-1L]
    nrepeat = 0L
    return
  endif

  ;If only one element in "data" is unique
  if (nunique EQ 1L) then begin

    ;Construct the output vector of unique elements, and the subscripts of the unique and repeat
    ;elements in "data", and then return
    unique = [data[0L]]
    unique_subs = [0L]
    repeat_subs = temporary(repeat_subs) + 1L
    return
  endif

  ;Otherwise, determine the subscripts of the unique and repeat elements in "data"
  unique_subs = [0L, temporary(unique_subs) + 1L]
  repeat_subs = temporary(repeat_subs) + 1L

  ;Construct the output vector of unique elements, and then return
  unique = data[unique_subs]
  return
endif

;If "data" is not already sorted, then sort "data"
sort_subs = sort(data)
unique = data[sort_subs]

;Find the positions in the sorted data vector where adjacent elements are different
unique_subs = where(unique[1L:(ndata - 1L)] NE unique[0L:(ndata - 2L)], nunique, COMPLEMENT = repeat_subs, NCOMPLEMENT = nrepeat)
nunique = nunique + 1L

;If all of the elements in "data" are unique
if (nunique EQ ndata) then begin

  ;Construct the output vector of unique elements, and the subscripts of the unique and repeat
  ;elements in "data", and then return
  if keyword_set(original_ordering) then begin
    unique = reform(data, ndata)
    unique_subs = lindgen(ndata)
  endif else unique_subs = sort_subs
  repeat_subs = [-1L]
  nrepeat = 0L
  return
endif

;If only one element in "data" is unique
if (nunique EQ 1L) then begin

  ;Construct the output vector of unique elements, and the subscripts of the unique and repeat
  ;elements in "data", and then return
  unique = [data[0L]]
  unique_subs = [0L]
  repeat_subs = temporary(repeat_subs) + 1L
  return
endif

;Otherwise, determine the subscripts of the unique and repeat elements in "data" such that the
;unique elements are arranged in ascending order
unique_subs = sort_subs[[0L, temporary(unique_subs) + 1L]]
repeat_subs = sort_subs[temporary(repeat_subs) + 1L]

;If the keyword ORIGINAL_ORDERING is set
if keyword_set(original_ordering) then begin

  ;Reorder the subscripts of the unique and repeat elements in "data" such that the ordering
  ;matches the original ordering of the elements in "data"
  unique_subs = unique_subs[sort(unique_subs)]
  repeat_subs = repeat_subs[sort(repeat_subs)]
endif

;Construct the output vector of unique elements in the required order
unique = data[unique_subs]

END
