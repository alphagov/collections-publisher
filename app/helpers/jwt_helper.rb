module JwtHelper
  def access_limited_preview_url(slug, auth_bypass_id)
    token = jwt_token(auth_bypass_id)
    "#{Services.draft_origin}/#{slug.sub(/^\//, '')}?token=#{token}"
  end

private

  def jwt_token(auth_bypass_id)
    JWT.encode({ 'sub' => auth_bypass_id }, jwt_auth_secret, 'HS256')
  end

  def jwt_auth_secret
    ENV['JWT_AUTH_SECRET']
  end
end
