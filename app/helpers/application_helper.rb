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
      token = jwt_token(auth_bypass_id)
      url << "?token=#{token}"
    end

    url
  end

private

  def jwt_token(auth_bypass_id)
    JWT.encode({ 'sub' => auth_bypass_id }, jwt_auth_secret, 'HS256')
  end

  def jwt_auth_secret
    Rails.application.config.jwt_auth_secret
  end
end
