class CreateTaxon
  attr_accessor :title, :parent, :content_id, :base_path
  include ActiveModel::Model

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

    Services.publishing_api.put_links(
      content_id,
      links: { parent: parent_ids }
    )
  end

  def parent_ids
    parent.present? ? [parent] : []
  end
end
