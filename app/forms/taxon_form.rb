class TaxonForm
  attr_accessor :title, :taxon_parents, :content_id, :base_path
  include ActiveModel::Model

  def self.build(content_id:)
    content_item = Services.publishing_api.get_content(content_id)
    links = Services.publishing_api.get_links(content_id).try(:links)
    form = new(
      content_id: content_id,
      title: content_item.title,
      base_path: content_item.base_path,
    )

    form.taxon_parents = links.parent if links.present? && links.parent.any?
    form
  end

  def taxon_parents
    @taxon_parents ||= []
  end

  def create!
    self.content_id ||= SecureRandom.uuid
    self.base_path ||= '/alpha-taxonomy/' + title.parameterize

    presenter = TaxonPresenter.new(
      base_path: base_path,
      title: title,
    )

    Services.publishing_api.put_content(
      content_id,
      presenter.payload
    )

    Services.publishing_api.publish(content_id, "minor")

    Services.publishing_api.patch_links(
      content_id,
      links: { parent: taxon_parents.select(&:present?) }
    )
  end
end
