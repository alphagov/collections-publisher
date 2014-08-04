Rails.application.routes.draw do
  root to: redirect('/sectors', status: 302)

  resources :sectors, only: [:index] do
    resources :lists, only: [:index, :create] do
      resources :contents, only: [:create, :update]
    end
  end
end
