Rails.application.routes.draw do
  root to: redirect('/sectors', status: 302)

  resources :sectors, only: [:index] do
    put :publish

    resources :lists, only: [:index, :edit, :create, :update, :destroy] do
      resources :contents, only: [:create, :update, :destroy]
    end
  end

  mount GovukAdminTemplate::Engine, at: "/style-guide"
end
