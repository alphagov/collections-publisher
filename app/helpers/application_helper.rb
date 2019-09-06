module ApplicationHelper
  def website_url(base_path)
    Plek.new.website_root + base_path
  end

  def content_tagger_url
    Plek.new.external_url_for('content-tagger')
  end

  def preview_url(slug, auth_bypass_id: nil)
    url = "#{Plek.new.external_url_for('draft-origin')}/#{slug.sub(/^\//, '')}"

    if auth_bypass_id.present?
      url = JwtHelper.access_limited_preview_url(url, auth_bypass_id)
    end

    url
  end

  def published_url(slug)
    "#{Plek.new.website_root}/#{slug}"
  end
end
