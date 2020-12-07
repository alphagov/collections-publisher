require "rails_helper"
RSpec.describe DateFormatHelper do
  let(:day) { "01" }
  let(:month) { "10" }
  let(:year) { "2020" }

  describe "#format_published_at" do
    it "formats time with valid parameters" do
      expect(format_published_at(day, month, year)).to eq({ published_at: expected_published_at_time })
    end

    it "returns nil if any of the date params are empty" do
      year = ""
      expect(format_published_at(day, month, year)).to eq(nil)
    end

    it "throws an ArgumentError and returns nil if param is outside of the calendar" do
      day = "2020"
      expect(format_published_at(day, month, year)).to eq(nil)
    end

    it "throws a RangeError and returns nil if param is too big" do
      day = "99999999999999999999999999999999999999999999999"
      expect(format_published_at(day, month, year)).to eq(nil)
    end

    def expected_published_at_time
      Time.zone.local(
        year,
        month,
        day,
      )
    end
  end
end
