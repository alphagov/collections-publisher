FactoryGirl.define do
  factory :redirect do
    original_topic_base_path "/some/route"
    from_base_path "/some/route"
    to_base_path "/to/some/route"
  end

  factory :user do
    uid { SecureRandom.hex }
    permissions { ["signin"] }
  end

  factory :list do
    tag
  end

  factory :list_item do
    title 'A list item title'
  end

  factory :tag do
    sequence(:title) {|n| "Browse page #{n}" }
    sequence(:slug) {|n| "browse-page-#{n}" }
    description "Example description"

    trait :draft do
      # no-op because initial state is draft
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
