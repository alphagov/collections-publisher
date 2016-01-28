module Taxonomy
  # Return a list of taxons from the publishing API with links included.
  class TaxonFetcher
    def taxons
      Services.publishing_api.get_content_items(
        content_format: 'taxon',
        fields: %i[title base_path content_id]
      ).sort_by { |taxon| taxon["title"] }
    end

    def taxons_for_select
      taxons.map { |taxon| [taxon['title'], taxon['content_id']] }
    end
  end
end
