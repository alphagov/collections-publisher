module AuthenticationControllerHelpers
  def login_as(user)
    request.env['warden'] = double(
      :authenticate! => true,
      :authenticated? => true,
      :user => user
    )
  end

  def stub_user
    @stub_user ||= FactoryGirl.create(:user)
  end

  def login_as_stub_user
    login_as stub_user
  end
end

module AuthenticationFeatureHelpers
  def stub_user
    @stub_user ||= FactoryGirl.create(:user)
  end

  def login_as_stub_user
    GDS::SSO.test_user = stub_user
  end
end

RSpec.configuration.include AuthenticationControllerHelpers, :type => :controller
RSpec.configuration.include AuthenticationFeatureHelpers, :type => :feature
