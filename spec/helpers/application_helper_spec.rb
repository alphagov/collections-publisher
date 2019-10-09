require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "preview URLs" do
    before do
      allow(Services.publishing_api).to receive(:lookup_content_id)
    end

    let(:step_nav) { create(:step_by_step_page) }
    let(:user) { create(:user) }

    describe "#draft_govuk_url" do
      it "returns a link to the draft content" do
        expected_url = "#{draft_origin_url}/#{step_nav.slug}"

        expect(helper.draft_govuk_url("/#{step_nav.slug}")).to eq(expected_url)
      end
    end

    describe "#step_by_step_preview_url" do
      it "appends a valid JWT token in the querystring" do
        allow(step_nav).to receive(:auth_bypass_id) { "123" }
        allow(step_nav).to receive(:content_id) { "42" }
        allow(user).to receive(:uid) { "7" }

        expected_token = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjMiLCJpc3MiOiI3IiwiY29udGVudF9pZCI6IjQyIn0.AA-b058Pq1aB2JM0FtmLeozRnsM6sVZfMWRcdlHg7xM"
        expected_url = "#{expected_step_nav_preview_url}?token=#{expected_token}"

        expect(helper.step_by_step_preview_url(step_nav, user)).to eq(expected_url)
      end
    end
  end

  describe "#markdown_to_html" do
    it "converts markdown to html" do
      text = "This is some **bold** text with a [link](/a-page)"
      expected_html = "<p>This is some <strong>bold</strong> text with a <a href=\"/a-page\">link</a></p>\n"

      expect(markdown_to_html(text)).to eq(expected_html)
    end
  end

  describe "#render_markdown" do
    it "converts markdown to html" do
      text = "This is some **bold** text with a [link](/a-page)"
      expected_html = "\n<div class=\"gem-c-govspeak govuk-govspeak \" data-module=\"govspeak\">\n    <p>This is some <strong>bold</strong> text with a <a href=\"/a-page\">link</a></p>\n\n</div>\n"

      expect(render_markdown(text)).to eq(expected_html)
    end
  end

  def expected_step_nav_preview_url
    "#{draft_origin_url}/#{step_nav.slug}"
  end

  def draft_origin_url
    Plek.new.external_url_for("draft-origin")
  end
end
