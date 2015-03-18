Given(/^I am logged in as GDS Editor$/) do
  user = FactoryGirl.create(:user)
  user.permissions << "GDS Editor"
  GDS::SSO.test_user = user
end
