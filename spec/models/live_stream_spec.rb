require "rails_helper"

RSpec.describe LiveStream do

  describe "validations" do
    let(:bad_url) { "www.youtbe.co.uk/123" }
    let(:good_url) { "https://www.youtube.com/123" }

    it "is invalid without a url" do
      expect(LiveStream.create).not_to be_valid
    end

    it "it requires a valid url" do
      stub_request(:get, bad_url).to_return(status: 404)
      expect { LiveStream.create!(url: bad_url) }.to raise_error(ActiveRecord::RecordInvalid)

      stub_request(:get, good_url)
      expect(LiveStream.create(url: good_url)).to be_valid
    end
  end
end
