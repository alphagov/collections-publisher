require 'rails_helper'

RSpec.describe TaxonPresenter do
  describe "#payload" do
    it "generates a valid payload" do
      presenter = TaxonPresenter.new(
        title: "My Title",
        base_path: "/taxons/my-taxon"
      )

      payload = presenter.payload

      expect(payload).to be_valid_against_schema('taxon')
    end
  end
end
