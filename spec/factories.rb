FactoryGirl.define do
  factory :user do
    permissions { ["signin"] }
  end

  factory :list

  factory :content

  factory :tag do
    sequence(:title) {|n| "Browse page #{n}" }
    sequence(:slug) {|n| "browse-page-#{n}" }
    description "Example description"

    factory :mainstream_browse_page
  end
end
