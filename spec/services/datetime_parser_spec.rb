# frozen_string_literal: true

require "rails_helper"

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
      expect(DatetimeParser.new(**params).parse).to be_nil
    end
  end

  describe "#issues_for" do
    context "an invalid time is provided" do
      let(:parser) { DatetimeParser.new(date: valid_date, time: nil) }

      it "finds issues for schedule_time" do
        parser.parse
        time_issues = parser.issues_for(:time)

        expect(time_issues.count).to eq(1)
        expect(time_issues.first).to eq("Enter a valid time")
      end

      it "doesn't report issues for date" do
        parser.parse
        date_issues = parser.issues_for(:date)

        expect(date_issues.count).to eq(0)
      end
    end

    context "an invalid date is provided" do
      let(:parser) { DatetimeParser.new(date: nil, time: valid_time) }

      it "finds issues for date" do
        parser.parse
        date_issues = parser.issues_for(:date)

        expect(date_issues.count).to eq(1)
        expect(date_issues.first).to eq("Enter a valid date")
      end

      it "doesn't report issues for time" do
        parser.parse
        time_issues = parser.issues_for(:time)

        expect(time_issues.count).to eq(0)
      end
    end
  end

  describe "#issues" do
    it "returns no issues when there are none" do
      parser = DatetimeParser.new(date: valid_date, time: valid_time)
      parser.parse

      expect(parser.issues).to be_empty
    end

    it "returns both date and time issues" do
      parser = DatetimeParser.new(date: nil, time: nil)
      parser.parse

      expect(parser.issues).to include(date: "Enter a valid date")
      expect(parser.issues).to include(time: "Enter a valid time")
    end
  end
end
