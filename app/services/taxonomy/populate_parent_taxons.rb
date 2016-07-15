module Taxonomy
  # Copies the parent links to the new field parent_taxons
  class PopulateParentTaxons
    attr_reader :content_id, :parent_taxons

    def initialize(content_id)
      @content_id = content_id
    end

    def self.run(content_id:)
      new(content_id).run
    end

    def run
      if parent_taxons_present?
        Rails.logger.info "skip: [#{content_id}] already has a taxon parents"
        return
      end
      assign_existing_parents_to_parent_taxons

      if parent_taxons.empty?
        Rails.logger.info "skip: [#{content_id}] has no taxon parents to add"
        return
      end
      post_new_parent_taxons

      parent_taxons
    end

  private

    def post_new_parent_taxons
      Services.publishing_api.patch_links(
        content_id,
        links: { parent_taxons: parent_taxons }
      )
    end

    def assign_existing_parents_to_parent_taxons
      @parent_taxons = links.parent if links.present? && links.parent.present?
    end

    def parent_taxons_present?
      links.present? && links.parent_taxons.present?
    end

    def links
      @links ||= Services.publishing_api.get_links(content_id).try(:links)
    end

    def parent_taxons
      @parent_taxons ||= []
    end
  end
end
