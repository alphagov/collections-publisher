require "rails_helper"

RSpec.describe Coronavirus::ContentGroup, type: :model do
  let(:content_group) { create :coronavirus_content_group }

  describe "validations" do
    it "should belong to a sub section" do
      should validate_presence_of(:sub_section)
    end

    it "fails if sub section does not exist" do
      content_group.sub_section = nil

      expect(content_group).not_to be_valid
    end

    it "is created with valid attributes" do
      expect(content_group).to be_valid
      expect(content_group.save).to eql true
      expect(content_group).to be_persisted
    end
  end
end
