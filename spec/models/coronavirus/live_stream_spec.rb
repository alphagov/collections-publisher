require "rails_helper"

RSpec.describe Coronavirus::LiveStream do
  describe "validations" do
    let(:bad_url) { "www.youtbe.co.uk/123" }
    let(:good_url) { "https://www.youtube.com/123" }
    before do
      stub_request(:get, bad_url).to_return(status: 404)
      stub_request(:get, good_url)
    end

    it "is invalid without a url" do
      expect(described_class.create).not_to be_valid
    end

    it "it requires a valid url" do
      expect { described_class.create!(url: bad_url) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(described_class.create(url: good_url)).to be_valid
    end

    it "has a formatted_stream_date column that is neither required nor validated" do
      expect(described_class.create(url: good_url, formatted_stream_date: "1 April 2020")).to be_valid
      expect(described_class.create(url: good_url, formatted_stream_date: "")).to be_valid
    end
  end
end
