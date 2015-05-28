require "rails_helper"

RSpec.describe List do

  describe "validations" do
    let(:list) { FactoryGirl.build(:list) }

    it "requires a tag" do
      list.tag = nil
      expect(list).not_to be_valid
    end
  end

  describe "#delete" do
    it "deletes list items" do
      list = create(:list)
      item = create(:list_item, list: list)

      list.delete

      expect { item.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
