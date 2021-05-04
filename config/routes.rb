Rails.application.routes.draw do
  root to: redirect("/step-by-step-pages", status: 302)

  namespace :coronavirus do
    resources :pages,
              path: "",
              only: %i[index show],
              param: :slug do
      get "discard", on: :member
      post "publish", to: "pages#publish", on: :member

      get "github_changes", to: "github_changes#index", on: :member
      post "github_changes/update", to: "github_changes#update", on: :member
      post "github_changes/publish", to: "github_changes#publish", on: :member

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

      resources :timeline_entries, only: %i[new create edit update destroy] do
        collection do
          get "reorder", to: "reorder_timeline_entries#index"
          put "reorder", to: "reorder_timeline_entries#update"
        end
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

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::ActiveRecord,
    GovukHealthcheck::SidekiqRedis,
  )

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
