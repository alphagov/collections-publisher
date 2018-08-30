require 'rails_helper'

RSpec.describe StepByStepPagesController do
  describe "GET Step by step index page" do
    it "can only be accessed by users with GDS editor permissions" do
      stub_user.permissions << "GDS Editor"
      get :index

      expect(response.status).to eq(200)
    end

    it "cannot be accessed by users without GDS editor permissions" do
      stub_user.permissions = %w(signin)
      get :index

      expect(response.status).to eq(403)
    end
  end
end
