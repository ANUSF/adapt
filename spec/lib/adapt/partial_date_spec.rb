require 'adapt/partial_date'

PartialDate = Adapt::PartialDate


shared_examples_for "Any date resolving to 1985" do
  it "should respond to year() with the number 1985" do
    @date.year.should == 1985
  end

  it "should respond to month() with the value nil" do
    @date.month.should == nil
  end

  it "should respond to day() with the value nil" do
    @date.day.should == nil
  end

  it "should respond to to_s() with the string '1985'" do
    @date.to_s.should == "1985"
  end

  it "should respond to pretty() with the string '1985'" do
    @date.pretty.should == "1985"
  end

  it "should respond to to_date with a Date object for 1 Jan 1985" do
    d = @date.to_date
    d.year.should == 1985
    d.month.should == 1
    d.day.should == 1
  end

  it "should respond to after? with true " +
     "if and only if the argument is a date before 1985" do
    @date.after?('1986').should be_false
    @date.after?('May 1986').should be_false
    @date.after?('May 1985').should be_false
    @date.after?('May 1984').should be_true
    @date.after?('1984').should be_true
  end

  it "should respond to before? with true " +
     "if and only if the argument is a date after 1985" do
    @date.before?('1986').should be_true
    @date.before?('May 1986').should be_true
    @date.before?('May 1985').should be_false
    @date.before?('May 1984').should be_false
    @date.before?('1984').should be_false
  end
end

shared_examples_for "Any date resolving to March 1985" do
  it "should respond to year() with the number 1985" do
    @date.year.should == 1985
  end

  it "should respond to month() with the number 3" do
    @date.month.should == 3
  end

  it "should respond to month().long_name() with the string 'March'" do
    @date.month.long_name.should == "March"
  end

  it "should respond to day() with the value nil" do
    @date.day.should == nil
  end

  it "should respond to to_s() with the string '1985-03'" do
    @date.to_s.should == "1985-03"
  end

  it "should respond to pretty() with the string 'Mar 1985'" do
    @date.pretty.should == "Mar 1985"
  end

  it "should respond to to_date with a Date object for 1 Mar 1985" do
    d = @date.to_date
    d.year.should == 1985
    d.month.should == 3
    d.day.should == 1
  end

  it "should respond to after? with true " +
     "if and only if the argument is a date before March 1985" do
    @date.after?('1986').should be_false
    @date.after?('May 1985').should be_false
    @date.after?('1 March 1985').should be_false
    @date.after?('February 1985').should be_true
    @date.after?('1984').should be_true
  end

  it "should respond to before? with true " +
     "if and only if the argument is a date after March 1985" do
    @date.before?('1986').should be_true
    @date.before?('May 1985').should be_true
    @date.before?('1 March 1985').should be_false
    @date.before?('February 1985').should be_false
    @date.before?('1984').should be_false
  end
end

shared_examples_for "Any date resolving to 12 March 1985" do
  it "should respond to year() with the number 1985" do
    @date.year.should == 1985
  end

  it "should respond to month() with the number 3" do
    @date.month.should == 3
  end

  it "should respond to month().long_name() with the string 'March'" do
    @date.month.long_name.should == "March"
  end

  it "should respond to day() with the number 12" do
    @date.day.should == 12
  end

  it "should respond to to_s() with the string '1985-03-12'" do
    @date.to_s.should == "1985-03-12"
  end

  it "should respond to pretty() with the string '12 Mar 1985'" do
    @date.pretty.should == "12 Mar 1985"
  end

  it "should respond to to_date with a Date object for 12 Mar 1985" do
    d = @date.to_date
    d.year.should == 1985
    d.month.should == 3
    d.day.should == 12
  end

  it "should respond to after? with true " +
     "if and only if the argument is a date before 12 March 1985" do
    @date.after?('1984').should be_true
    @date.after?('1985').should be_false
    @date.after?('1986').should be_false
    @date.after?('February 1985').should be_true
    @date.after?('March 1985').should be_false
    @date.after?('April 1985').should be_false
    @date.after?('11 March 1985').should be_true
    @date.after?('12 March 1985').should be_false
    @date.after?('13 March 1985').should be_false
  end

  it "should respond to before? with true " +
     "if and only if the argument is a date after 12 March 1985" do
    @date.before?('1984').should be_false
    @date.before?('1985').should be_false
    @date.before?('1986').should be_true
    @date.before?('February 1985').should be_false
    @date.before?('March 1985').should be_false
    @date.before?('April 1985').should be_true
    @date.before?('11 March 1985').should be_false
    @date.before?('12 March 1985').should be_false
    @date.before?('13 March 1985').should be_true
  end
end

describe "A Partial Date" do
  context "constructed from the Year object for 1985" do
    before :each do
      @date = PartialDate.new PartialDate::Year.new(1985)
    end

    it_should_behave_like "Any date resolving to 1985"
  end

  context "constructed from the string '1985'" do
    before :each do
      @date = PartialDate.new "1985"
    end

    it_should_behave_like "Any date resolving to 1985"
  end

  context "constructed from the string '85'" do
    before :each do
      @date = PartialDate.new "85"
    end

    it_should_behave_like "Any date resolving to 1985"
  end

  context "constructed from the Year object for 1985 and the string 'Mar'" do
    before :each do
      @date = PartialDate.new PartialDate::Year.new(1985), "Mar"
    end

    it_should_behave_like "Any date resolving to March 1985"
  end

  context "constructed from the string 'March 85'" do
    before :each do
      @date = PartialDate.new "March 85"
    end

    it_should_behave_like "Any date resolving to March 1985"
  end

  context "constructed from the string '1985 Mar'" do
    before :each do
      @date = PartialDate.new "1985 Mar"
    end

    it_should_behave_like "Any date resolving to March 1985"
  end

  context "constructed from the date object for 12 March 1985" do
    before :each do
      @date = PartialDate.new Date.new(1985, 3, 12)
    end

    it_should_behave_like "Any date resolving to 12 March 1985"
  end

  context "constructed from parameters 1985, 'Mar' and 12" do
    before :each do
      @date = PartialDate.new 1985, "Mar", 12
    end

    it_should_behave_like "Any date resolving to 12 March 1985"
  end

  context "constructed from the number 1985 and 3, and the Day object for 12" do
    before :each do
      @date = PartialDate.new 1985, 3, PartialDate::Day.new(12)
    end

    it_should_behave_like "Any date resolving to 12 March 1985"
  end

  context "constructed from the string 'March 12, 85'" do
    before :each do
      @date = PartialDate.new "March 12, 85"
    end

    it_should_behave_like "Any date resolving to 12 March 1985"
  end

  context "constructed from the string 'March 85, 12'" do
    before :each do
      @date = PartialDate.new "March 85, 12"
    end

    it_should_behave_like "Any date resolving to 12 March 1985"
  end

  context "constructed from the string '12 March 1985'" do
    before :each do
      @date = PartialDate.new "12 March 1985"
    end

    it_should_behave_like "Any date resolving to 12 March 1985"
  end

  context "constructed from the string '1985 Mar 12'" do
    before :each do
      @date = PartialDate.new "1985 March 12"
    end

    it_should_behave_like "Any date resolving to 12 March 1985"
  end

  context "constructed from the string '1985, 12 Mar'" do
    before :each do
      @date = PartialDate.new "1985, 12 Mar"
    end

    it_should_behave_like "Any date resolving to 12 March 1985"
  end

  context "constructed from the string '12 85 Mar'" do
    before :each do
      @date = PartialDate.new "12 85 Mar"
    end

    it_should_behave_like "Any date resolving to 12 March 1985"
  end

  context "constructed from the string '1985-03-12'" do
    before :each do
      @date = PartialDate.new "1985-03-12"
    end

    it_should_behave_like "Any date resolving to 12 March 1985"
  end
end

# Bad inputs start here.

describe "A Partial Date constructed from the string '12-12-85'" do
  it "should raise an error for being ambiguous" do
    lambda {
      PartialDate.new("12-12-85")
    }.should raise_error(/Ambiguous date/)
  end
end

describe "A Partial Date constructed from the string '12-May-03'" do
  it "should raise an error for being ambiguous" do
    lambda {
      PartialDate.new("12-May-03")
    }.should raise_error(/Ambiguous date/)
  end
end

describe "A Partial Date constructed from the string 'Mar-Mar'" do
  it "should raise an error" do
    lambda {
      PartialDate.new("Mar-Mar")
    }.should raise_error(/Unrecognized date format/)
  end
end

describe "A Partial Date constructed from the string 'Mar-Mar-Mar'" do
  it "should raise an error" do
    lambda {
      PartialDate.new("Mar-Mar-Mar")
    }.should raise_error(/Unrecognized date format/)
  end
end

describe "A Partial Date constructed from the string '12-Mar-1982, 12:35'" do
  it "should raise an error" do
    lambda {
      PartialDate.new("12-Mar-1982, 12:35")
    }.should raise_error(/Unrecognized date format/)
  end
end

describe "A Partial Date constructed from the string '31-Jun-1985'" do
  it "should raise an error for containing an illegal day" do
    lambda {
      PartialDate.new("31-Jun-1985")
    }.should raise_error(/June does not have 31 days/)
  end
end

describe "A Partial Date constructed from the string '29-Feb-1985'" do
  it "should raise a leap-year error" do
    lambda {
      PartialDate.new("29-Feb-1985")
    }.should raise_error(/1985 is not a leap year/)
  end
end

describe "A Partial Date constructed from the string '29-Feb-1900'" do
  it "should raise a leap-year error" do
    lambda {
      PartialDate.new("29-Feb-1900")
    }.should raise_error(/1900 is not a leap year/)
  end
end

describe "A Partial Date constructed from the string '29-Feb-2000'" do
  it "should not raise a leap-year error" do
    lambda {
      PartialDate.new("29-Feb-2000")
    }.should_not raise_error
  end
end

describe "A Partial Date constructed from the string '29-Feb-1852'" do
  it "should not raise a leap-year error" do
    lambda {
      PartialDate.new("29-Feb-1852")
    }.should_not raise_error
  end
end

describe "A Partial Date constructed from the string '29-Feb-1700'" do
  it "should not raise a leap-year error" do
    lambda {
      PartialDate.new("29-Feb-1700")
    }.should_not raise_error
  end
end

describe "A Partial Date constructed from the string '10-Sep-1752'" do
  it "should make a silly complaint" do
    lambda {
      PartialDate.new("10-Sep-1752")
    }.should raise_error(/Give us our eleven days/)
  end
end

describe "A Partial Date constructed from an Array" do
  it "should raise an input type error" do
    lambda {
      PartialDate.new([1752, 3, 12])
    }.should raise_error(/Expected integer, string or date/)
  end
end

describe "A Partial Date constructed from two numbers and a Hash" do
  it "should raise an input type error" do
    lambda {
      PartialDate.new(1752, 3, { :day => 12 })
    }.should raise_error(/Expected integer or day/)
  end
end

describe "A Partial Date constructed from a number and an Array" do
  it "should raise an input type error" do
    lambda {
      PartialDate.new(1752, [3, 12])
    }.should raise_error(/Expected integer, string or month/)
  end
end

describe "A Year constructed from an Array" do
  it "should raise an input type error" do
    lambda {
      PartialDate::Year.new([3, 12])
    }.should raise_error(/Expected an integer or year/)
  end
end

describe "A Year constructed from the number 0" do
  it "should raise an error" do
    lambda {
      PartialDate::Year.new(0)
    }.should raise_error(/no year 0/)
  end
end
