module Taxonomy
  # Copies the parent links to the new field taxon_parents
  class PopulateTaxonParents
    attr_reader :content_id, :taxon_parents

    def initialize(content_id)
      @content_id = content_id
    end

    def self.run(content_id:)
      new(content_id).run
    end

    def run
      if taxon_parents_present?
        Rails.logger.info "skip: [#{content_id}] already has a taxon parents"
        return
      end
      assign_existing_parents_to_taxon_parents

      if taxon_parents.empty?
        Rails.logger.info "skip: [#{content_id}] has no taxon parents to add"
        return
      end
      post_new_taxon_parents

      taxon_parents
    end

  private

    def post_new_taxon_parents
      Services.publishing_api.patch_links(
        content_id,
        links: { taxon_parents: taxon_parents }
      )
    end

    def assign_existing_parents_to_taxon_parents
      @taxon_parents = links.parent if links.present? && links.parent.present?
    end

    def taxon_parents_present?
      links.present? && links.taxon_parents.present?
    end

    def links
      @links ||= Services.publishing_api.get_links(content_id).try(:links)
    end

    def taxon_parents
      @taxon_parents ||= []
    end
  end
end
