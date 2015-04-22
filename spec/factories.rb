FactoryGirl.define do
  factory :user do
    uid { SecureRandom.hex }
    permissions { ["signin"] }
  end

  factory :list do
    association :topic
  end

  factory :list_item

  factory :tag do
    sequence(:title) {|n| "Browse page #{n}" }
    sequence(:slug) {|n| "browse-page-#{n}" }
    description "Example description"

    trait :draft do
      state 'draft'
    end

    trait :published do
      after :create do |tag|
        tag.publish!
      end
    end

    factory :topic, class: Topic
    factory :mainstream_browse_page, class: MainstreamBrowsePage
  end
end
