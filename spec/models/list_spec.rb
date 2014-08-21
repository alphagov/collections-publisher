require "spec_helper"

RSpec.describe List do
  let(:list) { FactoryGirl.create(:list, dirty: true) }

  describe "#mark_as_published" do
    it "sets #dirty? to false without saving" do
      list.mark_as_published

      expect(list).not_to be_dirty

      list.reload
      expect(list).to be_dirty
    end
  end

  describe "#mark_as_published!" do
    it "sets #dirty? to false and saves" do
      list.mark_as_published!

      expect(list).not_to be_dirty

      list.reload
      expect(list).not_to be_dirty
    end
  end
end
