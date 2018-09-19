require "rails_helper"

RSpec.describe PublishingApiHelper do
  describe "#latest_edition_number" do
    before do
      @content_id = "i-am-a-content-id"

      allow(Services.publishing_api).to receive(:get_content).with(@content_id).and_return(
        state_history: {
          "3" => "draft",
          "2" => "published",
          "1" => "superseded",
        }
      )
    end

    it "returns the most recent edition number for a content_item" do
      expect(helper.latest_edition_number(@content_id)).to eq(3)
    end

    it "returns the edition number of the published version of content_item" do
      expect(helper.latest_edition_number(@content_id, publication_state: "published")).to eq(2)
    end
  end
end
