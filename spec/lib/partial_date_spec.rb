require 'lib/partial_date'

shared_examples_for "Any date resolving to March 1985" do
  it "should respond to year() with the number 1985" do
    @date.year.should == 1985
  end

  it "should respond to month() with the number 3" do
    @date.month.should == 3
  end

  it "should respond to day() with the value" do
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
end

shared_examples_for "Any date resolving to 12 March 1985" do
  it "should respond to year() with the number 1985" do
    @date.year.should == 1985
  end

  it "should respond to month() with the number 3" do
    @date.month.should == 3
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
end

describe "A Partial Date" do
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
end
