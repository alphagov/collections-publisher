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
    post :republish

    resources :lists, only: [:index, :edit, :create, :update, :destroy] do
      resources :list_items, only: [:create, :update, :destroy]
    end
  end

  # Legacy route, may have been bookmarked by user.
  get '/topics/:tag_id/lists', to: redirect { |params, _request|
    "/tags/#{params[:tag_id]}/lists"
  }

  mount GovukAdminTemplate::Engine, at: "/style-guide"
end
