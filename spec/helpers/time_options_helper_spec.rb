require "rails_helper"

RSpec.describe TimeOptionsHelper do
  describe "#time_options" do
    subject { helper.time_options }

    it "contains a 12:01am special case" do
      expect(subject).to include "12:01am"
    end

    it "does not contain 12:00am special case" do
      expect(subject).not_to include "12:00am"
    end

    it "returns 48 items (hourly - except 12am special case - and half-hourly)" do
      expect(subject.count).to eq(48)
    end

    it "returns all the AM times before the PM times" do
      index_of_last_am = subject.map.with_index { |time, index| index if time.end_with?("am") }.compact.last
      index_of_first_pm = subject.index { |time| time.end_with?("pm") }
      expect(index_of_last_am).to be < index_of_first_pm
    end

    it "should only contain time values in 12-hour clock format" do
      subject.each do |time|
        expect(time).to match(/
          1[0-2]     # first portion of time can be two digits, e.g. 10am
          |          # or
          [1-9]      # could just be one digit, e.g. 1am
          :          # colon
          [0-5][0-9] # second number must be exactly 2 chars, and no more than 59
          (am|pm)$   # can only end in am or pm
        /x)
      end
    end
  end

  describe "#format_time_12_hour_clock" do
    it "formats the time correctly" do
      expect(helper.format_time_12_hour_clock(Time.current.tomorrow.change(hour: 9))).to eq("9:00am")
    end
  end

  describe "#format_full_date_and_time" do
    it "formats the date and time correctly" do
      datetime = Time.new(2030, 4, 20, 10, 26, 0, '+01:00') # London timezone
      expect(helper.format_full_date_and_time(datetime)).to eq("Saturday, 20 April 2030 at 10:26 am")
    end
  end

  describe "#default_datetime_placeholder" do
    let(:default_day) { Time.current.tomorrow.day }
    let(:default_month) { Time.current.tomorrow.month }
    let(:default_year) { Time.current.tomorrow.year }
    let(:default_time) { '9:00am' }

    context "with no params" do
      it "should fall back to default placeholder values" do
        expect(default_datetime_placeholder[:day]).to eq default_day
        expect(default_datetime_placeholder[:month]).to eq default_month
        expect(default_datetime_placeholder[:year]).to eq default_year
        expect(default_datetime_placeholder[:time]).to eq default_time
      end
    end

    context "with all params" do
      it "should override the default datetime" do
        schedule_datetime = default_datetime_placeholder(
          day: '30',
          month: '12',
          year: '2030',
          time: '13:00'
        )
        expect(schedule_datetime[:day]).to eq '30'
        expect(schedule_datetime[:month]).to eq '12'
        expect(schedule_datetime[:year]).to eq '2030'
        expect(schedule_datetime[:time]).to eq '13:00'
      end
    end

    context "with some params" do
      it "should override those params and fall back to defaults for others" do
        schedule_datetime = default_datetime_placeholder(
          day: '7',
          time: '3:14pm'
        )
        expect(schedule_datetime[:day]).to eq '7'
        expect(schedule_datetime[:month]).to eq default_month
        expect(schedule_datetime[:year]).to eq default_year
        expect(schedule_datetime[:time]).to eq '3:14pm'
      end
    end
  end
end
