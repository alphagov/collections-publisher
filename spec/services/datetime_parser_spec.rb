# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatetimeParser do
  let(:valid_date) { { day: "10", month: "01", year: "2019" } }
  let(:valid_time) { "9:00am" }

  describe "#parse" do
    it "takes time in lowercase 12-hour clock format" do
      parser = DatetimeParser.new(date: valid_date, time: "11:00am")
      expect(parser.parse.hour).to eq 11
    end

    it "takes time in uppercase 12-hour clock format" do
      parser = DatetimeParser.new(date: valid_date, time: "11:00AM")
      expect(parser.parse.hour).to eq 11
    end

    it "defaults to morning if no period provided and time < 12" do
      parser = DatetimeParser.new(date: valid_date, time: "9:34")
      expect(parser.parse.hour).to eq 9
      expect(parser.parse.min).to eq 34
    end

    it "treats 12:00 as midday" do
      parser = DatetimeParser.new(date: valid_date, time: "12:00")
      expect(parser.parse.hour).to eq 12
    end

    it "treats 12:00am as midnight at the beginning of the provided date" do
      parser = DatetimeParser.new(date: valid_date, time: "12:00am")
      expect(parser.parse.hour).to eq 0
      expect(parser.parse.day).to eq valid_date[:day].to_i
      expect(parser.parse.month).to eq valid_date[:month].to_i
      expect(parser.parse.year).to eq valid_date[:year].to_i
    end

    it "allows spaces before the period" do
      parser = DatetimeParser.new(date: valid_date, time: "6:00 pm")
      expect(parser.parse.hour).to eq 18
    end

    it "allows leading zeros" do
      parser = DatetimeParser.new(date: valid_date, time: "09:00am")
      expect(parser.parse.hour).to eq 9
    end

    it "defaults to afternoon/evening if no period provided and time > 12" do
      parser = DatetimeParser.new(date: valid_date, time: "23:32")
      expect(parser.parse.hour).to eq 23
      expect(parser.parse.min).to eq 32
    end

    it "treats 12:30pm as the afternoon of the provided date" do
      parser = DatetimeParser.new(date: valid_date, time: "12:30pm")
      expect(parser.parse.hour).to eq 12
      expect(parser.parse.min).to eq 30
    end

    it "returns nil when the time is blank" do
      parser = DatetimeParser.new(date: valid_date, time: nil)
      expect(parser.parse).to be_nil
    end

    it "returns nil when the time format is invalid" do
      parser = DatetimeParser.new(date: valid_date, time: "13421")
      expect(parser.parse).to be_nil
    end

    it "returns nil when the minutes are invalid" do
      parser = DatetimeParser.new(date: valid_date, time: "7:60am")
      expect(parser.parse).to be_nil
    end

    it "returns nil when the hours are invalid" do
      parser = DatetimeParser.new(date: valid_date, time: "30:00am")
      expect(parser.parse).to be_nil
    end

    it "returns nil when the date is blank" do
      parser = DatetimeParser.new(date: nil, time: valid_time)
      expect(parser.parse).to be_nil
    end

    it "returns nil when the date is invalid" do
      params = { date: { day: "10", month: "60", year: "11" }, time: valid_time }
      expect(DatetimeParser.new(params).parse).to be_nil
    end
  end
end
