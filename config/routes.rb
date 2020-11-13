Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  class RoleConstraint
    def initialize(role)
      @role = role
    end

    def matches?(request)
      user = request.env["warden"].user
      user && user.has_permission?(@role)
    end
  end

  root to: "live_stream#index", constraints: RoleConstraint.new("Livestream editor"), as: nil
  root to: redirect("/step-by-step-pages", status: 302)

  resources :live_stream, only: %i[index update] do
    post "publish", to: "live_stream#publish"
  end

  resources :coronavirus_pages, path: "coronavirus", only: %i[index show update], param: :slug do
    get "prepare", on: :member
    get "discard", on: :member
    post "publish", to: "coronavirus_pages#publish"
    get "timeline", to: "coronavirus_pages#timeline"
    resources :sub_sections do
      collection do
        get "reorder", to: "reorder_sub_sections#index"
        put "reorder", to: "reorder_sub_sections#update"
      end
    end

    resources :announcements do
      collection do
        get "reorder", to: "reorder_announcements#index"
        put "reorder", to: "reorder_announcements#update"
      end
    end
  end

  resources :step_by_step_pages, path: "step-by-step-pages" do
    get "approve-2i-review", to: "review#show_approve_2i_review_form"
    post "approve-2i-review", to: "review#approve_2i_review"
    post :check_links
    post "claim-2i-review", to: "review#claim_2i_review"
    get :guidance
    get "internal-change-notes"
    post "internal-change-notes", to: "internal_change_notes#create"
    get "navigation-rules", to: "navigation_rules#edit"
    put "navigation-rules", to: "navigation_rules#update"
    get :publish
    post :publish
    get :publish_without_2i_review
    post :publish_without_2i_review
    get :reorder
    post :reorder
    get "request-change-2i-review", to: "review#show_request_change_2i_review_form"
    post "request-change-2i-review", to: "review#request_change_2i_review"
    post :revert
    post "revert-to-draft", to: "review#revert_to_draft"
    get :schedule
    post :schedule
    post "schedule-datetime"
    get "submit-for-2i", to: "review#submit_for_2i"
    post "submit-for-2i", to: "review#submit_for_2i"
    get :unpublish
    post :unpublish
    post :unschedule

    resources :secondary_content_links, path: "secondary-content-links"
    resources :steps
  end

  resources :mainstream_browse_pages, path: "mainstream-browse-pages",
                                      except: :destroy do
    member do
      post :publish
      get :propose_archive
      post :archive
      get :"manage-child-ordering"
    end
  end

  resources :topics, path: "specialist-sector-pages", except: :destroy do
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
  get "/topics/:tag_id/lists", to: redirect { |params, _request|
    "/tags/#{params[:tag_id]}/lists"
  }

  post "/link_report", to: "link_report#update"

  mount GovukAdminTemplate::Engine, at: "/style-guide"
  mount GovukPublishingComponents::Engine, at: "/component-guide"

  class SidekiqAccessContraint
    def matches?(request)
      user = request.env["warden"].user
      user && user.has_permission?("Sidekiq Monitoring")
    end
  end

  require "sidekiq/web"
  mount Sidekiq::Web,
        at: "/sidekiq",
        constraints: SidekiqAccessContraint.new
end
