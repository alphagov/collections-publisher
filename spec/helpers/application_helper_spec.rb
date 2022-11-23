require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "preview URLs" do
    before do
      allow(Services.publishing_api).to receive(:lookup_content_id)
    end

    let(:step_nav) { create(:step_by_step_page) }
    let(:user) { create(:user) }
    let(:draft_origin_url) { Plek.external_url_for("draft-origin") }

    describe "#draft_govuk_url" do
      it "returns a link to the draft content" do
        expected_url = "#{draft_origin_url}/#{step_nav.slug}"

        expect(helper.draft_govuk_url("/#{step_nav.slug}")).to eq(expected_url)
      end
    end

    describe "#step_by_step_preview_url" do
      it "returns a url to the draft stack with a token" do
        allow(JWT).to receive(:encode).and_return("token")
        url = helper.step_by_step_preview_url(step_nav)
        expect(url).to eq("#{draft_origin_url}/#{step_nav.slug}?token=token")
      end

      it "appends a valid JWT token in the querystring" do
        Timecop.freeze do
          url = helper.step_by_step_preview_url(step_nav)
          token = Rack::Utils.parse_nested_query(URI.parse(url).query)["token"]

          expect(auth_bypass_token_payload(token))
            .to eq("content_id" => step_nav.content_id,
                   "draft_asset_manager_access" => true,
                   "exp" => 1.month.from_now.to_i,
                   "iat" => Time.zone.now.to_i,
                   "sub" => step_nav.auth_bypass_id)
        end
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

  def auth_bypass_token_payload(token)
    payload, _header = JWT.decode(
      token,
      ENV["JWT_AUTH_SECRET"],
      true,
      { algorithm: "HS256" },
    )

    payload
  end
end
