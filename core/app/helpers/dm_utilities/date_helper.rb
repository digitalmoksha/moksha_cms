# Date/Time helper routines
#------------------------------------------------------------------------------
module DmUtilities::DateHelper
  include ActionView::Helpers::NumberHelper

  # format a date or date range, using the same format for each date
  # Mar 3, 2012 -- Mar 5, 2012
  #  options
  #   :format => specifies the localize format to use, rather than the default
  #   :ignore_year => don't display the year
  #   :end_date => end date to display, creating a date range
  #------------------------------------------------------------------------------
  def format_date(start_date, full_date = false, options = {})
    format = options[:format].nil? ? ((full_date ? :wwmmddyy : (options[:ignore_year] ? :mmdd : :mmddyy))) : options[:format]
    date  = (start_date.nil? or start_date.year < 1900) ? 'n/a' : start_date.localize(:count => start_date.day, :format => format)
    date += " &mdash; #{options[:end_date].localize(:count => options[:end_date].day, :format => format)}".html_safe unless options[:end_date].blank?
    return date.html_safe
  end

  # We check the start_date year in case it's a null date (set to a zero date, not just nil)
  #------------------------------------------------------------------------------
  def format_date_range(start_date, end_date, full_date = false, options = {})
    return '' if start_date.nil? or start_date.year < 1900
    end_date ||= start_date
    options[:separator] ||= " &mdash; "

    if start_date.month == end_date.month && start_date.day == end_date.day && start_date.year == end_date.year
      event_date     = start_date.localize(:count => start_date.day, :format => (options[:ignore_year] ? :mmdd : :mmddyy))
      fullevent_date = start_date.localize(:count => start_date.day, :format => :wwmmddyy)
    elsif start_date.month == end_date.month && start_date.year == end_date.year
      event_date     = start_date.localize(:count => start_date.day, :format => :mmdd) + options[:separator] + end_date.localize(:count => end_date.day, :format => (options[:ignore_year] ? "%d" : "%d, %Y"))
      fullevent_date = start_date.localize(:count => start_date.day, :format => :wwmmdd) + options[:separator] + end_date.localize(:count => end_date.day, :format => :wwmmddyy)
    elsif start_date.year == end_date.year
      event_date     = start_date.localize(:count => start_date.day, :format => :mmdd) + options[:separator] + end_date.localize(:count => end_date.day, :format => (options[:ignore_year] ? :mmdd : :mmddyy))
      fullevent_date = start_date.localize(:count => start_date.day, :format => :wwmmdd) + options[:separator] + end_date.localize(:count => end_date.day, :format => :wwmmddyy)
    else
      event_date     = start_date.localize(:count => start_date.day, :format => (options[:ignore_year] ? :mmdd : :mmddyy)) + options[:separator] + end_date.localize(:count => end_date.day, :format => (options[:ignore_year] ? :mmdd : :mmddyy))
      fullevent_date = start_date.localize(:count => start_date.day, :format => :wwmmddyy) + options[:separator] + end_date.localize(:count => end_date.day, :format => :wwmmddyy)
    end

    full_date ? fullevent_date.html_safe : event_date.html_safe
  end

  #------------------------------------------------------------------------------
  def format_time_range(start_time, end_time, ignore_end_time = false)
    return '' if start_time.nil?

    ignore_end_time = true if end_time.nil?

    eventTime = start_time.localize(:format => :hhmmpp)

    ignore_end_time ? eventTime : "#{eventTime} &mdash; #{end_time.localize(:format => :hhmmpp)}".html_safe
  end

  #------------------------------------------------------------------------------
  def format_time(start_time)
    start_time.nil? ? 'n/a' : start_time.localize(:format => :hhmmpp)
  end

  # options
  #  :date_only => true   only show the date
  #------------------------------------------------------------------------------
  def format_datetime(time, options = {})
    time.nil? ? 'n/a' : (format_date(time, options[:full_date], options) + (options[:date_only] ? '' : " " + time.localize(:format => :hhmmpp)) )
  end

  # age / date
  #------------------------------------------------------------------------------
  def age_date(date)
    date.nil? ? 'n/a' : (date.to_age.to_s + ' / ' + format_date(date))
  end
end