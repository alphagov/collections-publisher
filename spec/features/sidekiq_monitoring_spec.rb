require 'rails_helper'

RSpec.describe "Sidekiq monitoring" do
  it "allows users with the correct permissions to monitor Sidekiq" do
    user = create(:user, permissions: ["signin", "Sidekiq Monitoring"])
    allow_any_instance_of(Warden::Proxy).to receive(:user).and_return(user)

    visit '/sidekiq'

    expect(page).to have_content 'Sidekiq'
  end

  it "does not allow unauthenticated users to monitor Sidekiq" do
    allow_any_instance_of(Warden::Proxy).to receive(:user).and_return(nil)

    expect {
      visit '/sidekiq'
    }.to raise_error(ActionController::RoutingError)
  end

  it "does not allow users without permissions to monitor Sidekiq" do
    user = create(:user, permissions: ["signin"])
    allow_any_instance_of(Warden::Proxy).to receive(:user).and_return(user)

    expect {
      visit '/sidekiq'
    }.to raise_error(ActionController::RoutingError)
  end
end
