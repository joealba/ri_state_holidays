require 'spec_helper'

describe RiStateHolidays do

  describe "easy day-of-month holidays" do
    it "knows New Years Day" do
      RiStateHolidays.holiday?(Date.new(2013, 1, 1)).should be_true
    end

    it "knows Independence Day" do
      RiStateHolidays.holiday?(Date.new(2012, 7, 4)).should be_true
    end

    it "knows Christmas" do
      RiStateHolidays.holiday?(Date.new(2012, 12, 25)).should be_true
    end

    it "knows a non-holiday" do
      RiStateHolidays.holiday?(Date.new(2012, 2, 28)).should be_false
    end
  end


  describe "observed holidays" do
    # When any legal holiday falls on a Sunday, the day following it is a full holiday.
    it "observed New Years from a Sunday" do
      RiStateHolidays.holiday?(Date.new(2012, 1, 2)).should be_true
    end

    it "observed Veterans Day from a Sunday" do
      RiStateHolidays.holiday?(Date.new(2012, 11, 12)).should be_true
    end
  end


  describe "calculated holidays" do
    it "knows Veteran's Day" do
      RiStateHolidays.holiday?(Date.new(2013, 11, 11)).should be_true
      RiStateHolidays.holiday?(Date.new(2014, 11, 11)).should be_true
    end

    it "knows Victory Day" do
      RiStateHolidays.holiday?(Date.new(2012, 8, 13)).should be_true
      RiStateHolidays.holiday?(Date.new(2013, 8, 12)).should be_true
      RiStateHolidays.holiday?(Date.new(2014, 8, 11)).should be_true
    end

    it "knows Labor Day" do
      RiStateHolidays.holiday?(Date.new(2012, 9, 3)).should be_true
      RiStateHolidays.holiday?(Date.new(2013, 9, 2)).should be_true
      RiStateHolidays.holiday?(Date.new(2014, 9, 1)).should be_true
    end

    it "knows election day" do
      RiStateHolidays.holiday?(Date.new(2012, 11, 6)).should be_true
      RiStateHolidays.holiday?(Date.new(2013, 11, 5)).should be_false
      RiStateHolidays.holiday?(Date.new(2014, 11, 4)).should be_true
    end

    it "knows Thanksgiving" do
      RiStateHolidays.holiday?(Date.new(2012, 11, 22)).should be_true
      RiStateHolidays.holiday?(Date.new(2013, 11, 28)).should be_true
      RiStateHolidays.holiday?(Date.new(2014, 11, 27)).should be_true
    end
  end


end
