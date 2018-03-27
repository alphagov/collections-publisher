Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: redirect('/topics', status: 302)

  resources :step_by_step_pages, path: 'step-by-step-pages' do
    get :reorder, to: 'step_by_step_pages#reorder'
    post :reorder, to: 'step_by_step_pages#reorder'

    get :unpublish, to: 'step_by_step_pages#unpublish'
    post :unpublish, to: 'step_by_step_pages#unpublish'

    resources :steps
  end

  resources :mainstream_browse_pages, path: 'mainstream-browse-pages',
                                      except: :destroy do
    member do
      post :publish
      get :propose_archive
      post :archive
      get :"manage-child-ordering"
    end
  end

  resources :topics, except: :destroy do
    member do
      post :publish
      get :propose_archive
      post :archive
    end
  end

  resources :tags, only: [] do
    post :publish_lists

    resources :lists, only: [:index, :edit, :create, :update, :destroy] do
      resources :list_items, only: [:create, :update, :destroy]
    end
  end

  # Legacy route, may have been bookmarked by user.
  get '/topics/:tag_id/lists', to: redirect { |params, _request|
    "/tags/#{params[:tag_id]}/lists"
  }

  mount GovukAdminTemplate::Engine, at: "/style-guide"

  class SidekiqAccessContraint
    def matches?(request)
      user = request.env['warden'].user
      user && user.has_permission?("Sidekiq Monitoring")
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web,
    at: '/sidekiq',
    constraints: SidekiqAccessContraint.new
end
