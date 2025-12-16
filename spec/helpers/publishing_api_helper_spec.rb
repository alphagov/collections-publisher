require "rails_helper"

RSpec.describe PublishingApiHelper do
  describe "#latest_edition_number" do
    before do
      @content_id = "i-am-a-content-id"

      allow(Services.publishing_api).to receive(:get_content).with(@content_id).and_return(
        state_history: {
          "11" => "draft",
          "10" => "published",
          "9" => "superseded",
          "8" => "superseded",
          "7" => "superseded",
          "6" => "superseded",
          "5" => "superseded",
          "4" => "superseded",
          "3" => "superseded",
          "2" => "superseded",
          "1" => "superseded",
        },
      )
    end

    it "returns the most recent edition number for a content_item" do
      expect(helper.latest_edition_number(@content_id)).to eq(11)
    end
  end
end
