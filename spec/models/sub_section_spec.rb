require "rails_helper"

RSpec.describe SubSection do
  let(:sub_section) { create :sub_section }

  describe "validations" do
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
  end
end
