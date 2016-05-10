class TaxonPresenter
  def initialize(base_path:, title:)
    @base_path = base_path
    @title = title
  end

  def payload
    {
      base_path: base_path,
      document_type: 'taxon',
      schema_name: 'taxon',
      title: title,
      publishing_app: 'collections-publisher',
      rendering_app: 'collections',
      public_updated_at: Time.now.iso8601,
      locale: 'en',
      routes: [
        { path: base_path, type: "exact" },
      ]
    }
  end

private

  attr_reader :base_path, :title
end
