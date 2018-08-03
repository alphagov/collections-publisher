class JwtHelper
  def self.access_limited_preview_url(url, auth_bypass_id)
    token = jwt_token(auth_bypass_id)
    "#{url}?token=#{token}"
  end

  def self.jwt_token(auth_bypass_id)
    JWT.encode({ 'sub' => auth_bypass_id }, jwt_auth_secret, 'HS256')
  end

  def self.jwt_auth_secret
    ENV['JWT_AUTH_SECRET']
  end
end
