class TaxonPresenter
  def initialize(content_id:, base_path:, title:)
    @content_id = content_id
    @base_path = base_path
    @title = title
  end

  def payload
    {
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
    }
  end

private

  attr_reader :content_id, :base_path, :title
end
