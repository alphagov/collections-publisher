module ApplicationHelper
  def website_url(base_path)
    Plek.new.website_root + base_path
  end
end
