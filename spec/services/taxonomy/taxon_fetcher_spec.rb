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

  describe '#parents_for_taxon_form' do
    let(:taxon_id_1) { SecureRandom.uuid }
    let(:taxon_id_2) { SecureRandom.uuid }
    let(:taxon_form) do
      instance_double(TaxonForm, taxon_parents: [taxon_id_1, taxon_id_2])
    end
    let(:link_1) do
      {"title" => "foo", "base_path" => "/foo", "content_id" => taxon_id_1 }
    end
    let(:link_2) do
      {"title" => "bar", "base_path" => "/bar", "content_id" => taxon_id_2}
    end
    let(:link_3) do
      {"title" => "aha", "base_path" => "/aha", "content_id" => SecureRandom.uuid}
    end
    let(:linkables) { [link_1, link_2, link_3] }

    it 'returns the parent taxons for a given taxon' do
      publishing_api_has_linkables(linkables, document_type: 'taxon')
      result = described_class.new.parents_for_taxon_form(taxon_form)

      expect(result.count).to eq(2)
      expect(result).to include(link_1)
      expect(result).to include(link_2)
    end
  end
end
