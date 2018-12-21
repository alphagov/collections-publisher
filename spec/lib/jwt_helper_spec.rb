require "rails_helper"

RSpec.describe JwtHelper do
  describe "#access_limited_preview_url" do
    it "appends a valid JWT token in the querystring" do
      url = "http://step-nav-slug"

      expected_token = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEyM30.-r0B06VSBvNo2Z_WMSuC9G65epKc3ZdYxM8L-3xfsvI"
      expected_url = "#{url}?token=#{expected_token}"

      expect(described_class.access_limited_preview_url(url, 123)).to eq(expected_url)
    end
  end
end
