class ContentItem
  def self.find!(base_path)
    response = Services.content_store.content_item(base_path)
    new(response.to_h)
  end

  attr_reader :data

  def initialize(data)
    @data = data
  end

  %w[base_path title content_id description document_type].each do |field|
    define_method(field.to_sym) { data[field] }
  end

  def subroutes
    []
  end
end
