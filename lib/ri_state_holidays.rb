# Much of this code comes right from the Holidays Ruby gem (https://github.com/alexdunae/holidays)
# I created a separate gem rather than creating an ri_state_holidays 'region' because
#   I wanted to keep the Date class unmodified.

## RI state holiday information from http://sos.ri.gov/library/stateholidays/

# New year's day, 4th of July, Christmas
# Dr. Martin Luther King Jr's Birthday - Third Monday in January
# Memorial Day - Last Monday in May
# Victory Day - Second Monday in August
# Labor Day - First Monday in September
# Columbus Day - Second Monday in October
# Election Day - Tuesday after the First Monday in November
# Thanksgiving - Fourth Thursday in November

require 'date'
require 'digest/md5'

module RiStateHolidays
  WEEKS = {:first => 1, :second => 2, :third => 3, :fourth => 4, :fifth => 5, :last => -1, :second_last => -2, :third_last => -3}
  MONTH_LENGTHS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  DAY_SYMBOLS = Date::DAYNAMES.collect { |n| n.downcase.intern }

  def self.holiday?(d)
    !holiday(d).empty?
  end

  def self.holiday(d)
    self.between(d, d)
  end

  def self.holidays_by_month
    @holidays_by_month ||= get_holidays_by_month
  end


  def self.between(start_date, end_date, *options)
    # remove the timezone
    start_date = start_date.new_offset(0) + start_date.offset if start_date.respond_to?(:new_offset)
    end_date = end_date.new_offset(0) + end_date.offset if end_date.respond_to?(:new_offset)

    # get simple dates
    if start_date.respond_to?(:to_date)
      start_date = start_date.to_date
    else
      start_date = Date.civil(start_date.year, start_date.mon, start_date.mday)
    end

    if end_date.respond_to?(:to_date)
      end_date = end_date.to_date
    else
      end_date = Date.civil(end_date.year, end_date.mon, end_date.mday)
    end

    regions, observed, informal = parse_options(options)

    holidays = []

    dates = {}
    (start_date..end_date).each do |date|
      # Always include month '0' for variable-month holidays
      dates[date.year] = [0] unless dates[date.year]
      # TODO: test this, maybe should push then flatten
      dates[date.year] << date.month unless dates[date.year].include?(date.month)
    end

    dates.each do |year, months|
      months.each do |month|
        next unless hbm = holidays_by_month[month]

        hbm.each do |h|
          if h[:function]
            # Holiday definition requires a calculation
            result = call_proc(h[:function], year)

            # Procs may return either Date or an integer representing mday
            if result.kind_of?(Date)
              month = result.month
              mday = result.mday
            else
              mday = result
            end
          else
            # Calculate the mday
            mday = h[:mday] || calculate_mday(year, month, h[:week], h[:wday])
          end

          # Silently skip bad mdays
          begin
            date = Date.civil(year, month, mday)
          rescue; next; end

          # If the :observed option is set, calculate the date when the holiday
          # is observed.
          if observed and h[:observed]
            date = call_proc(h[:observed], date)
          end

          if date.between?(start_date, end_date)
            holidays << {:date => date, :name => h[:name]}
          end

        end
      end
    end

    holidays.sort{|a, b| a[:date] <=> b[:date] }
  end


  def self.get_holidays_by_month
    {
      1 => [
        {:mday => 1, :observed => lambda { |date| to_weekday_if_weekend(date) }, :observed_id => "to_weekday_if_weekend", :name => "New Year's Day", :regions => [:us, :us_ri]},
        {:wday => 1, :week => 3, :name => "Martin Luther King, Jr. Day", :regions => [:us, :us_ri]},
      ],
      5 => [
        {:wday => 1, :week => -1, :name => "Memorial Day", :regions => [:us, :us_ri]},
      ],
      7 => [
        {:mday => 4, :observed => lambda { |date| to_weekday_if_weekend(date) }, :observed_id => "to_weekday_if_weekend", :name => "Independence Day", :regions => [:us, :us_ri]}
      ],
      8 => [
        {:wday => 1, :week => 2, :name => "Victory Day", :regions => [:us, :us_ri]}
      ],
      9 => [
        {:wday => 1, :week => 1, :name => "Labor Day", :regions => [:us, :us_ri]}
      ],
      10 => [
        {:wday => 1, :week => 2, :name => "Columbus Day", :regions => [:us, :us_ri]}
      ],
      11 => [
        {:mday => 11, :observed => lambda { |date| to_weekday_if_weekend(date) }, :observed_id => "to_weekday_if_weekend", :name => "Veterans Day", :regions => [:us, :us_ri]},
        {:wday => 4, :week => 4, :name => "Thanksgiving", :regions => [:us, :us_ri]},
        {:function => lambda { |year| us_election_day(year) }, :function_id => "us_election_day(year)", :name => "Election Day", :regions => [:us_ri]}
      ],
      12 => [
        {:mday => 25, :observed => lambda { |date| to_weekday_if_weekend(date) }, :observed_id => "to_weekday_if_weekend", :name => "Christmas Day", :regions => [:us, :us_ri]}
      ]
    }
  end
  private_class_method :get_holidays_by_month


  # Return the Tuesday after the first Monday
  def self.us_election_day(year)
    month = 11
    mday = 1
    if year % 2 == 0
      date = Date.civil(year, month, mday)
      if date.wday < 2
        return date + (2 - date.wday)
      elsif date.wday == 2
        return date + 7
      elsif date.wday > 2
        return date + (9 - date.wday)
      end
    end

    return nil
  end
  private_class_method :us_election_day


  def self.to_weekday_if_weekend(date)
    date += 1 if date.wday == 0
    date += 2 if date.wday == 6
    date
  end
  private_class_method :to_weekday_if_weekend


  def self.calculate_mday(year, month, week, wday)
    raise ArgumentError, "Week parameter must be one of Holidays::WEEKS (provided #{week})." unless WEEKS.include?(week) or WEEKS.has_value?(week)

    unless wday.kind_of?(Numeric) and wday.between?(0,6) or DAY_SYMBOLS.index(wday)
      raise ArgumentError, "Wday parameter must be an integer between 0 and 6 or one of Date::DAY_SYMBOLS."
    end

    week = WEEKS[week] if week.kind_of?(Symbol)
    wday = DAY_SYMBOLS.index(wday) if wday.kind_of?(Symbol)

    # :first, :second, :third, :fourth or :fifth
    if week > 0
      return ((week - 1) * 7) + 1 + ((wday - Date.civil(year, month,(week-1)*7 + 1).wday) % 7)
    end

    days = MONTH_LENGTHS[month-1]

    days = 29 if month == 2 and Date.leap?(year)

    return days - ((Date.civil(year, month, days).wday - wday + 7) % 7) - (7 * (week.abs - 1))
  end
  private_class_method :calculate_mday


  def self.call_proc(function, year) # :nodoc:
    proc_key = Digest::MD5.hexdigest("#{function.to_s}_#{year.to_s}")
    function.call(year)
  end
  private_class_method :call_proc


  def self.parse_options(options)
    regions = [:us_ri]
    observed = true
    informal = nil
    return regions, observed, informal
  end
  private_class_method :parse_options

end
