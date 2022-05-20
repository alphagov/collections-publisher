require "rails_helper"

RSpec.describe RedirectItemPresenter do
  describe "#render_for_publishing_api" do
    it "is valid against the schema" do
      item = create(:redirect_item)

      rendered = RedirectItemPresenter.new(item).render_for_publishing_api

      expect(rendered).to be_valid_against_publisher_schema("redirect")
    end
  end
end
