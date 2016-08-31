module ApplicationHelper
  def website_url(base_path)
    Plek.new.website_root + base_path
  end

  def content_tagger_url
    Plek.new.find('content-tagger')
  end
end
