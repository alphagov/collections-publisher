Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: redirect('/topics', status: 302)

  resources :step_by_step_pages, path: 'step-by-step-pages' do
    get 'navigation-rules', to: 'navigation_rules#edit'
    put 'navigation-rules', to: 'navigation_rules#update'
    get :publish
    post :publish
    get :reorder
    post :reorder
    get :unpublish
    post :unpublish

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

    resources :lists, only: %i[index edit create update destroy] do
      resources :list_items, only: %i[create update destroy]
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
