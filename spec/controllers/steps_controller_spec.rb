require "rails_helper"

RSpec.describe StepsController do
  describe "GET Step edit page" do
    let(:step_by_step_page) { create_step_by_step_page }
    let(:step) { create(:step, step_by_step_page:) }

    it "can only be accessed by users with GDS editor permissions" do
      stub_user.permissions << "GDS Editor"
      get :edit, params: { step_by_step_page_id: step_by_step_page.id, id: step.id }

      expect(response.status).to eq(200)
    end

    it "cannot be accessed by users without GDS editor permissions" do
      stub_user.permissions = %w[signin]
      get :edit, params: { step_by_step_page_id: step_by_step_page.id, id: step.id }

      expect(response.status).to eq(403)
    end
  end

  def create_step_by_step_page
    build(:step_by_step_page_with_steps).tap do |step_page|
      step_page.save(validate: false)
    end
  end
end
