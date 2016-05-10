require 'rails_helper'

RSpec.describe TaxonPresenter do
  describe "#payload" do
    it "generates a valid payload" do
      presenter = TaxonPresenter.new(
        title: "My Title",
        content_id: "e8d62d8c-22d2-4890-9d5c-805da489d16f",
        base_path: "/taxons/my-taxon"
      )

      payload = presenter.payload

      expect(payload).to be_valid_against_schema('taxon')
    end
  end
end
