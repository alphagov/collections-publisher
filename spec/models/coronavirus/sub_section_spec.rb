require "rails_helper"

RSpec.describe Coronavirus::SubSection do
  let(:sub_section) { create :coronavirus_sub_section }

  describe "validations" do
    it "should belong to a page" do
      should validate_presence_of(:page)
    end

    it "fails if page does not exist" do
      sub_section.page = nil

      expect(sub_section).not_to be_valid
    end

    it "is created with valid attributes" do
      expect(sub_section).to be_valid
      expect(sub_section.save).to eql true
      expect(sub_section).to be_persisted
    end

    it "requires a title" do
      sub_section.title = ""

      expect(sub_section).not_to be_valid
      expect(sub_section.errors).to have_key(:title)
    end

    it "requires content" do
      sub_section.content = ""

      expect(sub_section).not_to be_valid
      expect(sub_section.errors).to have_key(:content)
    end

    it "validates that the featured link is in content" do
      sub_section.content = "[test](/bananas)"
      sub_section.action_link_url = "/bananas"

      expect(sub_section).to be_valid
    end

    it "fails if featured link is not in content" do
      sub_section.action_link_url = "/bananas"

      expect(sub_section).not_to be_valid
      expect(sub_section.errors).to have_key(:action_link_url)
    end
  end
end
