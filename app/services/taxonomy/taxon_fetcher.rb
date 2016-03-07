module Taxonomy
  # Return a list of taxons from the publishing API with links included.
  class TaxonFetcher
    def taxons
      Services.publishing_api.get_linkables(
        document_type: 'taxon'
      ).sort_by { |taxon| taxon["title"] }
    end

    def taxons_for_select
      taxons.map { |taxon| [taxon['title'], taxon['content_id']] }
    end
  end
end
