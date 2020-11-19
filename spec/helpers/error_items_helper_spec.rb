require "rails_helper"
RSpec.describe ErrorItemsHelper do
  describe "#error_items" do
    let(:empty_error_messages) { {} }
    let(:error_messages) { { title: ["can't be blank"], path: ["must be a valid path starting with a /"] } }
    let(:multiple_error_messages) { { title: ["can't be blank", "invalid"] } }

    it "does not format error messages when there are no errors" do
      expect(error_items(empty_error_messages, :title)).to eq(nil)
    end

    it "formats the error message for a blank title field" do
      expect(error_items(error_messages, :title)).to eq("Title can't be blank")
    end

    it "formats the error message for an invalid path field" do
      expect(error_items(error_messages, :path)).to eq("Path must be a valid path starting with a /")
    end

    it "formats the error message when there are multiple errors on a field" do
      expect(error_items(multiple_error_messages, :title)).to eq("Title can't be blank\nTitle invalid")
    end
  end
end
