require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "#preview_url" do
    before do
      allow(Services.publishing_api).to receive(:lookup_content_id)
    end

    let(:step_nav) { create(:step_by_step_page) }

    it "returns a link to the draft content" do
      expected_url = "#{draft_origin_url}/#{step_nav.slug}"

      expect(helper.preview_url(step_nav.slug)).to eq(expected_url)
    end
  end

  def draft_origin_url
    Plek.new.external_url_for('draft-origin')
  end
end
