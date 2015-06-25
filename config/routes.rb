Rails.application.routes.draw do
  root to: redirect('/topics', status: 302)

  resources :mainstream_browse_pages, path: 'mainstream-browse-pages',
                                      except: :destroy do
    member do
      post :publish
    end
  end

  resources :topics, except: :destroy do
    member do
      post :publish
    end
  end

  resources :tags, only: [] do
    post :publish_lists

    # FIXME: Legacy route, may have been shown to user before deploying.
    post '/republish', action: :publish_lists

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
