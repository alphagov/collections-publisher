require 'rails_helper'
require 'gds_api/test_helpers/publishing_api_v2'

RSpec.describe Taxonomy::TaxonFetcher do
  include GdsApi::TestHelpers::PublishingApiV2
  describe '#taxons' do
    it 'retrieves content items from publishing api and orders by title' do
      linkables = [
        {"title" => "foo", "base_path" => "/foo", "content_id" => SecureRandom.uuid},
        {"title" => "bar", "base_path" => "/bar", "content_id" => SecureRandom.uuid},
        {"title" => "aha", "base_path" => "/aha", "content_id" => SecureRandom.uuid},
      ]

      publishing_api_has_linkables(linkables, document_type: 'taxon')

      result = described_class.new.taxons

      expect(result.first["title"]).to eq("aha")
      expect(result.last["title"]).to eq("foo")
    end
  end
end
