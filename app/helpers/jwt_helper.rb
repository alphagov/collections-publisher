module JwtHelper
  # Create a deterministic, but unique token that will be used to give one-time
  # access to a piece of draft content.
  # This token is created by using an id that should be unique so that there is
  # little chance of the same token being created to view another piece of content.
  # The code to create the token has been "borrowed" from SecureRandom.uuid,
  # See: http://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html#uuid-method
  def auth_bypass_token(id)
    @_auth_bypass_id ||= begin
      ary = Digest::SHA256.hexdigest(id.to_s).unpack('NnnnnN')
      ary[2] = (ary[2] & 0x0fff) | 0x4000
      ary[3] = (ary[3] & 0x3fff) | 0x8000
      "%08x-%04x-%04x-%04x-%04x%08x" % ary
    end
  end
end
