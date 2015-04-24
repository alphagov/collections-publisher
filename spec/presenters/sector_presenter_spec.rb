require "spec_helper"

RSpec.describe SectorPresenter do
  include ContentApiHelpers

  describe "#render_for_publishing_api(sector)" do
    let(:oil_and_gas) { create(:topic, :slug => 'oil-and-gas') }
    let(:offshore) {
      create(:topic,
             :parent => oil_and_gas,
             :slug => 'offshore', :title => 'Offshore',
             :description => 'Important information about offshore drilling',
            )
    }

    before :each do
      oil_rigs = create(:list, :topic => offshore, :index => 1, :name => 'Oil rigs')
      create(:list_item, :list => oil_rigs, :index => 1, :api_url => contentapi_url_for_slug('oil-rig-staffing'))
      create(:list_item, :list => oil_rigs, :index => 0, :api_url => contentapi_url_for_slug('oil-rig-safety-requirements'))
      create(:list_item, :list => oil_rigs, :index => 2, :api_url => contentapi_url_for_slug('riggs'))
      piping = create(:list, :topic => offshore, :index => 0, :name => 'Piping')
      create(:list_item, :list => piping, :index => 0, :api_url => contentapi_url_for_slug('undersea-piping-restrictions'))

      content_api_has_artefacts_with_a_tag('specialist_sector', 'oil-and-gas/offshore', [
        'oil-rig-safety-requirements',
        'oil-rig-staffing',
        'undersea-piping-restrictions',
      ])
    end

    it "provides information about the topic" do
      Timecop.freeze do
        content_hash = SectorPresenter.render_for_publishing_api(offshore)

        expect(content_hash).to include(
          title: "Offshore",
          description: "Important information about offshore drilling",
          format: "specialist_sector",
          need_ids: [],
          public_updated_at: Time.zone.now.iso8601,
          publishing_app: "collections-publisher",
          rendering_app: "collections", # This will soon change to `collections-frontend`.
          routes: [
            {path: "/oil-and-gas/offshore", type: "prefix"}
          ],
          redirects: [],
          update_type: "major" # All changes in this app are de facto major for now.
        )
      end
    end

    it "provides the curated lists in the details hash ordered by their index" do
      content_hash = SectorPresenter.render_for_publishing_api(offshore)

      expect(content_hash).to include(
        details: {
          groups: [
            # Curated content excluding untagged content
            {
              name: "Piping",
              contents: [
                contentapi_url_for_slug('undersea-piping-restrictions'),
              ]
            },
            {
              name: "Oil rigs",
              contents: [
                contentapi_url_for_slug('oil-rig-safety-requirements'),
                contentapi_url_for_slug('oil-rig-staffing'),
              ]
            }
          ]
        }
      )
    end
  end
end
