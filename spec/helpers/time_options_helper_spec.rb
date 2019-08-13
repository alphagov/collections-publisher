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
end
