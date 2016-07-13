module Taxonomy
  # Return a list of taxons from the publishing API with links included.
  class TaxonFetcher
    def taxons
      @taxons ||=
        Services.publishing_api.get_linkables(
          document_type: 'taxon'
        ).sort_by { |taxon| taxon["title"] }
    end

    def taxons_for_select
      taxons.map { |taxon| [taxon['title'], taxon['content_id']] }
    end

    def parents_for_taxon_form(taxon_form)
      taxons.select do |taxon|
        taxon_form.parents.include?(taxon['content_id'])
      end
    end
  end
end
