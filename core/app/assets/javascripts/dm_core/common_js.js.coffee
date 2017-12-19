# Useful utility / support functions for javascript
#------------------------------------------------------------------------------

# Source: http://stackoverflow.com/questions/497790
#------------------------------------------------------------------------------
class DateUtils
  constructor: ->

  # Converts the date in d to a date-object. The input can be:
  #   a date object: returned without modification
  #  an array      : Interpreted as [year,month,day]. NOTE: month is 0-11.
  #   a number     : Interpreted as number of milliseconds
  #                  since 1 Jan 1970 (a timestamp)
  #   a string     : Any format supported by the javascript engine, like
  #                  "YYYY/MM/DD", "MM/DD/YYYY", "Jan 31 2009" etc.
  #  an object     : Interpreted as an object with year, month and date
  #                  attributes.  **NOTE** month is 0-11.
  #------------------------------------------------------------------------------
  convert: (d) ->
    if d.constructor == Date
      return d
    else if d.constructor == Array
      return new Date(d[0],d[1],d[2])
    else if d.constructor == Number
      return new Date(d)
    else if d.constructor == String
      return new Date(d)
    else if typeof d == "object"
      return new Date(d.year,d.month,d.date)
    else
      return NaN

  # Compare two dates (could be of any type supported by the convert
  # function above) and returns:
  #  -1 : if a < b
  #   0 : if a = b
  #   1 : if a > b
  # NaN : if a or b is an illegal date
  # NOTE: The code inside isFinite does an assignment (=).
  #------------------------------------------------------------------------------
  compare: (a, b) ->
    if isFinite(a = this.convert(a).valueOf()) && isFinite(b = this.convert(b).valueOf())
      return (a > b) - (a < b)
    else
      return NaN

  # Checks if date in d is between dates in start and end.
  # Returns a boolean or NaN:
  #    true  : if d is between start and end (inclusive)
  #    false : if d is before start or after end
  #    NaN   : if one or more of the dates is illegal.
  # NOTE: The code inside isFinite does an assignment (=).
  #------------------------------------------------------------------------------
  inRange: (d, start_date, end_date) ->
    if isFinite(d = this.convert(d).valueOf()) && isFinite(start_date = this.convert(start_date).valueOf()) && isFinite(end_date = this.convert(end_date).valueOf())
      return start_date <= d && d <= end_date
    else
      return NaN

#------------------------------------------------------------------------------
@dates = new DateUtils
