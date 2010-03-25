require 'delegate'

class PartialDate
  class Year < DelegateClass(Integer)
    def initialize(val)
      num = case val
            when 0       then raise "There was no year 0."
            when Year    then val.to_i
            when Integer then val
            else
              raise "Expected an integer or year; got #{val.class}."
            end
      super(num)
    end

    def to_s
      if (1..99).include? self then "00" else "" end + self.to_i.to_s
    end
  end

  class Month < DelegateClass(Integer)
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
      DAYS_IN_MONTH[self]
    end

    def short_name
      MONTH[self][0,3]
    end

    def long_name
      MONTH[self]
    end

    def to_s
      if (1..9).include? self then "0" else "" end + self.to_i.to_s
    end

    private

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
  end

  class Day < DelegateClass(Integer)
    def initialize(val)
      num = case val
            when Integer
              raise "Day must be between 1 and 31." unless (1..31).include? val
              val
            when Day
              val.to_i
            else
              raise "Expected integer or day; got #{val.class}."
            end
      super(num)
    end

    def to_s
      if (1..9).include? self then "0" else "" end + self.to_i.to_s
    end
  end

  attr_reader :year, :month, :day

  def initialize(*args)
    raise "Expected 1, 2 or 3 arguments." unless (1..3).include? args.size

    x = if args.size == 1
          case (val = args[0])
          when Date, Time, PartialDate then [val.year, val.month, val.day]
          when String                  then PartialDate::parse(val)
          when Integer, Year           then [val]
          else
            raise "Expected integer, string or date; got #{val.class}."
          end
        else
          args
        end

    @year  = Year.new(x[0])
    @month = Month.new(x[1]) if x[1]
    @day   = Day.new(x[2])   if x[2]
    assert_legal_date
    freeze
  end

  def to_s
    [year, month, day].compact.map { |x| x.to_s }.join "-"
  end

  def pretty
    [day, month && month.short_name, year].compact.map { |x| x.to_s }.join " "
  end

  def to_date
    Date.new *([year, month, day].compact)
  end

  private

  def assert_legal_date
    #TODO support other dates for adoption of Gregorian calendar

    leap = (year % 4 == 0 and
            (year < 1753 or year % 100 != 0 or year % 400 == 0))
    if day
      raise "Can't have a day without a month." unless month
      if month == 2 and day == 29 and not leap
        raise "#{year} is not a leap year."
      elsif day > month.number_of_days
        raise "#{month.long_name} does not have #{day} days."
      end
      if year == 1752 and month == 9 and (3..13).include? day
        raise "Give us our eleven days!"
      end
    end
  end

  YEAR      = /\A -?\d+ \z/xo
  DAY       = /\A (?: 0?[1-9] | [1-2][0-9] | 3[0-1] ) \z/xo
  MONTH_INT = /\A (?: 0?[1-9] | 1[0-2] ) \z/xo
  MONTH_STR = /\A [a-z]{3,} \z/ixo
  MONTH     = / #{MONTH_INT} | #{MONTH_STR} /ixo
  SEPARATOR = /\A (?: [-.\/] | \,?\s+ ) \z/xo

  def self.parse(s)
    date_string = s.strip
    a = date_string.split /\b/
    case a.size
    when 1
      [resolve_year(a[0])]
    when 3
      assert_format(a[1], SEPARATOR, "separator")
      if a[0] =~ MONTH and not a[2] =~ MONTH_STR
        resolve(date_string, a[0], a[2], nil)
      elsif a[2] =~ MONTH and not a[0] =~ MONTH_STR
        resolve(date_string, a[2], a[0], nil)
      else
        unknown date_string
      end
    when 5
      assert_format(a[1], SEPARATOR, "separator")
      assert_format(a[3], SEPARATOR, "separator")
      if a[1] == a[3] and date_string =~ /\A\d{4}.\d\d.\d\d\z/
        [resolve_year(a[0]), resolve_month(a[2]), resolve_day(a[4])]
      elsif a[0] =~ MONTH and not (a[2] =~ MONTH_STR or a[4] =~ MONTH_STR)
        resolve(date_string, a[0], a[2], a[4])
      elsif a[2] =~ MONTH and not (a[0] =~ MONTH_STR or a[4] =~ MONTH_STR)
        resolve(date_string, a[2], a[4], a[0])
      elsif a[4] =~ MONTH and not (a[0] =~ MONTH_STR or a[2] =~ MONTH_STR)
        resolve(date_string, a[4], a[0], a[2])
      else
        unknown date_string
      end
    else
      unknown date_string
    end
  end

  def self.resolve(date_string, month, a, b)
    if month =~ MONTH_STR or not (a =~ MONTH or b =~ MONTH)
      if b.nil?
        [resolve_year(a), resolve_month(month)]
      elsif not b =~ DAY
        [resolve_year(b), resolve_month(month), resolve_day(a)]
      elsif not a =~ DAY
        [resolve_year(a), resolve_month(month), resolve_day(b)]
      else
        ambiguous date_string
      end
    else
      ambiguous date_string
    end
  end

  def self.resolve_day(s)
    assert_format(s, DAY, "day")
    s.to_i
  end

  def self.resolve_month(s)
    assert_format(s, MONTH, "month")
    Month.new(if s =~ /\d+/ then s.to_i else s end)
  end

  def self.resolve_year(s)
    assert_format(s, YEAR, "year")
    year = s.to_i
    if s.size == 2
      now = Date.today.year
      a = year + now - now % 100
      (a > now + 10) ? a - 100 : a
    else
      year
    end
  end

  def self.assert_format(text, pattern, concept)
    raise("Illegal format for #{concept}: '#{text}'.") unless text =~ pattern
  end

  def self.ambiguous(s)
    raise "Ambiguous date (consider using 4-digit year or month name): '#{s}'."
  end

  def self.unknown(s)
    raise "Unrecognized date format: '#{s}'."
  end
end
