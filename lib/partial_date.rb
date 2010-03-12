class PartialDate
  DAYS_IN_MONTH = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  MONTH = [ nil,
            "January", "February", "March", "April", "June",
            "July", "August", "September", "October", "November", "December" ]

  MONTH_BY_NAME = {
    "Jan" =>  1, "Feb" =>  2, "Mar" =>  3,
    "Apr" =>  4, "Mai" =>  5, "Jun" =>  6,
    "Jul" =>  7, "Aug" =>  8, "Sep" =>  9,
    "Oct" => 10, "Nov" => 11, "Dec" => 12
  }

  attr_reader :year, :month, :day

  def initialize(*args)
    raise "Expected 1, 2 or 3 arguments." unless (1..3).include? args.size

    val = args[0]
    if val.is_a? Integer
      self.year= val
    elsif args.size == 1
      if val.is_a? String
        #TODO implement better parsing
        val = begin Date.parse(val) rescue nil end
      end
      case val
      when Date, Time, PartialDate
        self.year= val.year
        self.month= val.month
        self.day= val.day
      else
        raise "Expected integer, string or date argument; got #{val.class}."
      end
    end

    self.month= args[1] if args.size >= 2
    self.day= args[2] if args.size >= 3
  end

  def year=(val)
    unless val.is_a? Integer
      raise "Expected integer argument; got #{val.class}."
    end
    check_date(day, month, val)
    @year = val
  end

  def month=(val)
    if val.is_a? Integer
      raise "Month must be between 1 and 12." unless (1..12).include? val
    elsif val.is_a? String
      val = MONTH_BY_NAME[val.capitalize[0,3]]
      raise "Illegal month name '#{val}'" if val.nil?
    elsif not val.nil?
      raise "Expected integer, string or nil; got #{val.class}."
    end
    check_date(day, val, year)
    @month = val
    @day = nil if val.nil?
  end

  def day=(val)
    if val.is_a? Integer
      raise "Day must be between 1 and 31." unless (1..31).include? val
    elsif not val.nil?
      raise "Expected integer or nil; got #{val.class}."
    end
    check_date(val, month, year)
    @day = val
  end

  def short_month_name
    month ? MONTH[month][0,3] : nil
  end

  def long_month_name
    month ? MONTH[month] : nil
  end

  def to_s
    [year, month, day].compact.map(&:to_s).join "-"
  end

  def pretty
    [day, short_month_name, year].compact.map(&:to_s).join " "
  end

  def to_date
    Date.new *([year, month, day].compact)
  end

  private

  def check_date(day, month, year)
    raise "There was no year 0." if year == 0
    raise "Can't have a day without a month." if day and not month

    if day
      if month == 2 and day == 29
        unless year % 4 == 0 and
            (year < 1752 or year % 100 != 0 or year % 400 == 0)
          raise "The year #{year} does not have a 29 February."
        end
      else
        unless (1..DAYS_IN_MONTH[month]).include? day
          raise "Day #{day} is out of range for #{MONTH[month]}."
        end
      end
      if year == 1752 and month == 9 and (3..13).include? day
        raise "Give us our eleven days!"
      end
    end
  end
end
