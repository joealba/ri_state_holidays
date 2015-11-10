require 'spec_helper'

describe RiStateHolidays do

  describe "easy day-of-month holidays" do
    it "knows New Years Day" do
      expect(RiStateHolidays.holiday?(Date.new(2013, 1, 1))).to eq(true)
    end

    it "knows Independence Day" do
      expect(RiStateHolidays.holiday?(Date.new(2012, 7, 4))).to eq(true)
    end

    it "knows Christmas" do
      expect(RiStateHolidays.holiday?(Date.new(2012, 12, 25))).to eq(true)
    end

    it "knows a non-holiday" do
      expect(RiStateHolidays.holiday?(Date.new(2012, 2, 28))).to eq(false)
    end
  end


  describe "observed holidays" do
    # When any legal holiday falls on a Sunday, the day following it is a full holiday.
    it "observed New Years from a Sunday" do
      expect(RiStateHolidays.holiday?(Date.new(2012, 1, 2))).to eq(true)
    end

    it "observed Veterans Day from a Sunday" do
      expect(RiStateHolidays.holiday?(Date.new(2012, 11, 12))).to eq(true)
    end

    it 'observed a Saturday holiday on the following Monday, not the previous Friday' do
      expect(RiStateHolidays.holiday?(Date.new(2015, 7, 3))).to eq(false)
      expect(RiStateHolidays.holiday?(Date.new(2015, 7, 6))).to eq(true)
    end
  end


  describe "calculated holidays" do
    it "knows Veteran's Day" do
      expect(RiStateHolidays.holiday?(Date.new(2013, 11, 11))).to eq(true)
      expect(RiStateHolidays.holiday?(Date.new(2014, 11, 11))).to eq(true)
    end

    it "knows Victory Day" do
      expect(RiStateHolidays.holiday?(Date.new(2012, 8, 13))).to eq(true)
      expect(RiStateHolidays.holiday?(Date.new(2013, 8, 12))).to eq(true)
      expect(RiStateHolidays.holiday?(Date.new(2014, 8, 11))).to eq(true)
    end

    it "knows Labor Day" do
      expect(RiStateHolidays.holiday?(Date.new(2012, 9, 3))).to eq(true)
      expect(RiStateHolidays.holiday?(Date.new(2013, 9, 2))).to eq(true)
      expect(RiStateHolidays.holiday?(Date.new(2014, 9, 1))).to eq(true)
    end

    it "knows election day" do
      expect(RiStateHolidays.holiday?(Date.new(2012, 11, 6))).to eq(true)
      expect(RiStateHolidays.holiday?(Date.new(2013, 11, 5))).to eq(false)
      expect(RiStateHolidays.holiday?(Date.new(2014, 11, 4))).to eq(true)
    end

    it "knows Thanksgiving" do
      expect(RiStateHolidays.holiday?(Date.new(2012, 11, 22))).to eq(true)
      expect(RiStateHolidays.holiday?(Date.new(2013, 11, 28))).to eq(true)
      expect(RiStateHolidays.holiday?(Date.new(2014, 11, 27))).to eq(true)
    end
  end


end
