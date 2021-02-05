require "rails_helper"

RSpec.describe Coronavirus::PageHelper do
  describe "#page_type" do
    it "returns 'Coronavirus landing page' for the landing page" do
      page = build(:coronavirus_page, :landing)
      expect(helper.page_type(page)).to eq("Coronavirus landing page")
    end

    it "returns 'Coronavirus hub page' for a differnt pages" do
      page = build(:coronavirus_page, :business)
      expect(helper.page_type(page)).to eq("Coronavirus hub page")
    end
  end

  describe "#formatted_title" do
    it "returns 'Coronavirus (COVID-19)' for the landing page" do
      page = build(:coronavirus_page, :landing)
      expect(helper.formatted_title(page)).to eq("Coronavirus (COVID-19)")
    end

    it "returns the page title for a different page" do
      page = build(:coronavirus_page, :business)
      expect(helper.formatted_title(page)).to eq(page.title)
    end
  end
end
