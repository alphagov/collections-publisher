require "rails_helper"

RSpec.describe CoronavirusPagesController, type: :controller do
  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:coronavirus_page) { create :coronavirus_page, :of_known_type }

  describe 'GET /coronavirus' do
    it 'renders page successfully' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /coronavirus/:slug/prepare' do
    it 'renders page successfuly' do
      get :prepare, params: { slug: coronavirus_page.slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /coronavirus/:slug' do
    it 'renders page successfuly' do
      get :show, params: { slug: coronavirus_page.slug }
      expect(response).to have_http_status(:success)
    end
  end
end
