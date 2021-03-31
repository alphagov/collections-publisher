require "rails_helper"

RSpec.describe GovukUrlHelper do
  describe "#remove_govuk_from_url" do
    it "removes everything before the path of a https://www.gov.uk URL" do
      expect(helper.remove_govuk_from_url("https://www.gov.uk/vat-rates"))
        .to eq("/vat-rates")
    end

    it "doesn't change a different URL" do
      expect(helper.remove_govuk_from_url("https://www.example.com/page"))
        .to eq("https://www.example.com/page")
    end
  end
end
