require "spec_helper"

RSpec.describe SectorPresenter do
  describe "#render_for_publishing_api(sector)" do
    let(:sector) { double(:sector,
      title: "Offshore",
      id: "http://example.com/api/oil-and-gas/offshore.json",
      web_url: "http://example.com/oil-and-gas/offshore",
      details: double(:details, description: "Important information about offshore drilling"),
      ordered_lists: ordered_lists,
      uncategorized_contents: uncategorized_contents
    ) }

    let(:ordered_lists) {
      [
        FactoryGirl.build(:list,
          name: "Piping",
          index: 0,
          contents: [
            FactoryGirl.build(:content, api_url: "http://example.com/api/undersea-piping-restrictions.json")
          ]
        ),
        FactoryGirl.build(:list,
          name: "Oil rigs",
          index: 1,
          contents: [
            FactoryGirl.build(:content, api_url: "http://example.com/api/oil-rig-safety-requirements.json"),
            FactoryGirl.build(:content, api_url: "http://example.com/api/oil-rig-staffing.json"),
            FactoryGirl.build(:content, api_url: "http://example.com/api/riggs.json")
          ]
        )
      ]
    }

    before do
      piping, oil_rigs = ordered_lists
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
          public_updated_at: Time.zone.now.iso8601,
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

    it "provides the curated lists in the details hash ordered by their index" do
      sector_hash = SectorPresenter.render_for_publishing_api(sector)

      expect(sector_hash).to include(
        details: {
          groups: [
            # Curated content excluding untagged content
            {
              name: "Piping",
              contents: [
                "http://example.com/api/undersea-piping-restrictions.json"
              ]
            },
            {
              name: "Oil rigs",
              contents: [
                "http://example.com/api/oil-rig-safety-requirements.json",
                "http://example.com/api/oil-rig-staffing.json"
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

    context "with no uncategorized contents" do
      let(:uncategorized_contents) { [] }

      it "does not include the 'other' block" do
        sector_hash = SectorPresenter.render_for_publishing_api(sector)

        sector_hash[:details][:groups].each do |group|
          expect(group[:name]).not_to eq("Other")
        end
      end
    end
  end
end
