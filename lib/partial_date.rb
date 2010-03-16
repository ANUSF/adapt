require 'delegate'

class PartialDate
  class Year < DelegateClass(Integer)
    def initialize(val)
      case val
      when Integer
        raise "There was no year 0." if val == 0
      when Year
        val = val.to_i
      else
        raise "Expected an integer or year; got #{val.class}."
      end
      super(val)
    end

    def is_leap_year?
      self % 4 == 0 and (self < 1753 or self % 100 != 0 or self % 400 == 0)
    end

    def to_s
      if (1..99).include? self then "00" else "" end + self.to_i.to_s
    end
  end

  class Month < DelegateClass(Integer)
    DAYS_IN_MONTH = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    MONTH = [ nil,
              "January", "February", "March", "April", "May", "June",
              "July", "August", "September", "October", "November", "December" ]

    MONTH_BY_NAME = {
      "Jan" =>  1, "Feb" =>  2, "Mar" =>  3,
      "Apr" =>  4, "May" =>  5, "Jun" =>  6,
      "Jul" =>  7, "Aug" =>  8, "Sep" =>  9,
      "Oct" => 10, "Nov" => 11, "Dec" => 12
    }

    def initialize(val)
      case val
      when Integer
        num = val
      when String
        num = MONTH_BY_NAME[val.capitalize[0,3]]
        raise "Illegal month name '#{val}'" if num.nil?
      when Month
        num = val.to_i
      else
        raise "Expected integer, string or month; got #{val.class}."
      end
      raise "Month must be between 1 and 12." unless (1..12).include? num
      super(num)
    end

    def number_of_days(year = nil)
      if self == 2
        if year and Year.new(year).is_leap_year? then 29 else 28 end
      else
        DAYS_IN_MONTH[self]
      end
    end

    def short_name
      MONTH[self][0,3]
    end

    def long_name
      MONTH[self]
    end
  end

  class Day < DelegateClass(Integer)
    def initialize(val)
      case val
      when Integer
        raise "Day must be between 1 and 31." unless (1..31).include? val
      when Day
        val = val.to_i
      else
        raise "Expected integer or day; got #{val.class}."
      end
      super(val)
    end
  end

  attr_reader :year, :month, :day

  def initialize(*args)
    raise "Expected 1, 2 or 3 arguments." unless (1..3).include? args.size

    x = if args.size == 1
          case (val = args[0])
          when Date, Time, PartialDate then [val.year, val.month, val.day]
          when String                  then PartialDate::parse(val)
          when Integer                 then [val]
          when Year                    then [val.to_i]
          else
            raise "Expected integer, string or date; got #{val.class}."
          end
        else
          args
        end

    @year = Year.new x[0]
    if x.size >= 2
      @month = Month.new x[1]
      if x.size >= 3
        assert_legal_day(x[2])
        @day = Day.new x[2]
      end
    end
  end

  def to_s
    [year, month, day].compact.map(&:to_s).join "-"
  end

  def pretty
    [day, month && month.short_name, year].compact.map(&:to_s).join " "
  end

  def to_date
    Date.new *([year, month, day].compact)
  end

  private

  YEAR_ANY   = /\A -?\d+ \z/xo
  YEAR_LONG  = /\A -?\d{4} \z/xo
  YEAR_SHORT = /\A \d\d \z/xo
  DAY        = /\A (?: 0?[1-9] | [1-2][0-9] | 3[0-1] ) \z/xo
  MONTH_INT  = /\A (?: 0?[1-9] | 1[0-2] ) \z/xo
  MONTH_STR  = /\A [a-z]{3,} \z/ixo
  MONTH      = / #{MONTH_INT} | #{MONTH_STR} /ixo
  SEPARATOR  = /\A (?: [-.\/] | \,?\s+ ) \z/xo

  def self.resolve_month(s)
    Month.new(if s =~ /\d+/ then s.to_i else s end)
  end

  def self.resolve_year(s)
    year = s.to_i
    if s.size == 2
      now = Date.today.year
      a = year + now - now % 100
      (a > now + 10) ? a - 100 : a
    else
      year
    end
  end

  def self.parse(s)
    date_string = s.strip
    parts = date_string.split /\b/
    case parts.size
    when 1
      assert_format(parts[0], YEAR_ANY, "year")
      [parts[0].to_i]
    when 3
      assert_format(parts[1], SEPARATOR, "separator")
      if parts[2] =~ MONTH
        if parts[2] =~ MONTH_STR or not parts[0] =~ MONTH
          assert_format(parts[0], YEAR_ANY, "year")
          [resolve_year(parts[0]), resolve_month(parts[2])]
        else
          raise "Ambiguous date: '#{date_string}'."
        end
      elsif parts[0] =~ MONTH
        assert_format(parts[2], YEAR_ANY, "year")
        [resolve_year(parts[2]), resolve_month(parts[0])]
      else
        raise "Unknown date format: '#{date_string}'."
      end
    end
  end

  def self.assert_format(text, pattern, concept)
    unless text =~ pattern
      raise "Illegal format for #{concept}: '#{text}'."
    end
  end
  
  def assert_legal_day(day)
    if day
      if month
        if day > month.number_of_days(year)
          if month == 2 and day == 29
            raise "#{year} is not a leap year."
          else
            raise "#{month.long_name} does not have #{day} days."
          end
        end
      else
        raise "Can't have a day without a month." unless month
      end
      if year == 1752 and month == 9 and (3..13).include? day
        raise "Give us our eleven days!"
      end
    end
  end
end
