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

    it "is invalid with a sub heading of more than 255 characters" do
      sub_section.sub_heading = Faker::Lorem.paragraph_by_chars(number: 256)

      expect(sub_section).not_to be_valid
      expect(sub_section.errors).to have_key(:sub_heading)
    end

    describe "action link fields" do
      it { should validate_length_of(:action_link_url).is_at_most(255) }
      it { should validate_length_of(:action_link_content).is_at_most(255) }
      it { should validate_length_of(:action_link_summary).is_at_most(255) }

      it "validates if none of the action link fields are filled in" do
        sub_section.action_link_url = ""
        sub_section.action_link_content = nil
        sub_section.action_link_summary = ""

        expect(sub_section).to be_valid
      end

      it "validates if all of the action link fields are filled in" do
        sub_section.action_link_url = "/bananas"
        sub_section.action_link_content = "Bananas"
        sub_section.action_link_summary = "Bananas"

        expect(sub_section).to be_valid
      end

      it "fails if not all of the action link fields are filled in" do
        sub_section.action_link_url = "/bananas"
        sub_section.action_link_content = ""
        sub_section.action_link_summary = nil

        expect(sub_section).not_to be_valid
        expect(sub_section.errors).to have_key(:action_link_content)
        expect(sub_section.errors).to have_key(:action_link_summary)
      end
    end
  end
end
