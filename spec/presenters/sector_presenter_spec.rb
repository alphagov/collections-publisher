require "spec_helper"

RSpec.describe SectorPresenter do
  describe "#render_for_publishing_api(sector)" do
    let(:sector) { double(:sector,
      title: "Offshore",
      id: "http://example.com/api/oil-and-gas/offshore.json",
      web_url: "http://example.com/oil-and-gas/offshore",
      details: double(:details, description: "Important information about offshore drilling"),
      lists: lists,
      uncategorized_contents: uncategorized_contents
    ) }

    let(:lists) {
      [
        FactoryGirl.build(:list,
          name: "Oil rigs",
          contents: [
            FactoryGirl.build(:content, api_url: "http://example.com/api/oil-rig-safety-requirements.json"),
            FactoryGirl.build(:content, api_url: "http://example.com/api/oil-rig-staffing.json"),
            FactoryGirl.build(:content, api_url: "http://example.com/api/riggs.json")
          ]
        ),
        FactoryGirl.build(:list,
          name: "Piping",
          contents: [
            FactoryGirl.build(:content, api_url: "http://example.com/api/undersea-piping-restrictions.json")
          ]
        )
      ]
    }

    before do
      oil_rigs, piping = lists
      allow(oil_rigs).to receive(:tagged_contents).and_return(oil_rigs.contents.reject {|c| c.api_url == "http://example.com/api/riggs.json"})
      allow(piping).to receive(:tagged_contents).and_return(piping.contents)
    end

    let(:uncategorized_contents) {
      [
        FactoryGirl.build(:content, api_url: "http://example.com/api/north-sea-shipping-lanes.json")
      ]
    }

    it "provides information about the sector" do
      Timecop.freeze do
        sector_hash = SectorPresenter.render_for_publishing_api(sector)

        expect(sector_hash).to include(
          title: "Offshore",
          base_path: "/oil-and-gas/offshore",
          description: "Important information about offshore drilling",
          format: "specialist_sector",
          need_ids: [],
          public_updated_at: Time.zone.now,
          publishing_app: "collections-publisher",
          rendering_app: "collections", # This will soon change to `collections-frontend`.
          routes: [
            {path: "/oil-and-gas/offshore", type: "exact"}
          ],
          redirects: [],
          update_type: "major" # All changes in this app are de facto major for now.
        )
      end
    end

    it "provides the curated lists in the details hash" do
      sector_hash = SectorPresenter.render_for_publishing_api(sector)

      expect(sector_hash).to include(
        details: {
          groups: [
            # Curated content excluding untagged content
            {
              name: "Oil rigs",
              contents: [
                "http://example.com/api/oil-rig-safety-requirements.json",
                "http://example.com/api/oil-rig-staffing.json"
              ]
            },
            {
              name: "Piping",
              contents: [
                "http://example.com/api/undersea-piping-restrictions.json"
              ]
            },
            # Uncurated content
            {
              name: "Other",
              contents: [
                "http://example.com/api/north-sea-shipping-lanes.json"
              ]
            }
          ]
        }
      )
    end
  end
end
