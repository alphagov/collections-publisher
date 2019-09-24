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

    it "appends a valid JWT token in the querystring" do
      allow(step_nav).to receive(:auth_bypass_id) { "123" }

      expected_token = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjMifQ.f7yK2FqG2LVLauPM3K5UYkFPlabvft-lsGeGUhgQwNs"
      expected_url = "#{expected_step_nav_preview_url}?token=#{expected_token}"

      expect(helper.preview_url(step_nav.slug, auth_bypass_id: step_nav.auth_bypass_id)).to eq(expected_url)
    end
  end

  def expected_step_nav_preview_url
    "#{draft_origin_url}/#{step_nav.slug}"
  end

  def draft_origin_url
    Plek.new.external_url_for("draft-origin")
  end
end
