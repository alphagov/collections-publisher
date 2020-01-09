module AuthenticationControllerHelpers
  def login_as(user)
    request.env["warden"] = double(
      authenticate!: true,
      authenticated?: true,
      user: user,
    )
  end

  def stub_user
    @stub_user ||= FactoryBot.create(:user)
  end

  def login_as_stub_user
    login_as stub_user
  end
end

module AuthenticationFeatureHelpers
  def stub_user
    @stub_user ||= FactoryBot.create(:user)
  end

  def login_as_user(user = stub_user)
    GDS::SSO.test_user = user
  end
end

RSpec.configure do |config|
  config.include AuthenticationControllerHelpers, type: :controller
  config.before(:each, type: :controller) do
    login_as_stub_user
  end

  config.include AuthenticationFeatureHelpers, type: :feature
  config.before(:each, type: :feature) do
    login_as_user
  end
end
