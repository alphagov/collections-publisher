require "rails_helper"

RSpec.describe JwtHelper do
  describe "#auth_bypass_token" do
    it 'should create a predictable hex string based on the id' do
      expect(auth_bypass_token(123)).to eq("61363635-6134-4539-b230-343232663964")
    end
  end

  describe "#access_limited_preview_url" do
    it "appends a valid JWT token in the querystring" do
      slug = "step-nav-slug"

      expected_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOjEyM30.xTbOwaYOmzgd16a-cMrkBIeB5lY7qneU66rqFTwTKPw"
      expected_url = "#{Services.draft_origin}/#{slug}?token=#{expected_token}"

      expect(access_limited_preview_url(slug, 123)).to eq(expected_url)
    end
  end
end
