class TaxonForm
  attr_accessor :title, :parent, :content_id, :base_path
  include ActiveModel::Model

  def self.build(content_id:)
    content_item = Services.publishing_api.get_content(content_id)
    links = Services.publishing_api.get_links(content_id).try(:links)
    form = new(
      content_id: content_id,
      title: content_item.title,
      base_path: content_item.base_path,
    )

    if links.present? && links.parent.present?
      form.parent = links.parent.to_a.first
    end

    form
  end

  def create!
    self.content_id ||= SecureRandom.uuid
    self.base_path ||= '/alpha-taxonomy/' + title.parameterize

    Services.publishing_api.put_content(
      content_id,
      base_path: base_path,
      format: 'taxon',
      title: title,
      content_id: content_id,
      publishing_app: 'collections-publisher',
      rendering_app: 'collections',
      public_updated_at: Time.now,
      routes: [
        { path: base_path, type: "exact" },
      ]
    )

    Services.publishing_api.publish(content_id, "major")

    Services.publishing_api.put_links(
      content_id,
      links: { parent: parent_ids }
    )
  end

  def parent_ids
    parent.present? ? [parent] : []
  end
end
