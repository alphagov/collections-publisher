module ApplicationHelper
  def website_url(base_path)
    Plek.new.website_root + base_path
  end

  def content_tagger_url
    Plek.new.external_url_for('content-tagger')
  end
end
