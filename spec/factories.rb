FactoryGirl.define do
  factory :redirect_item do
    content_id SecureRandom.uuid
    from_base_path "/from/foo"
    to_base_path "/to/bar"
  end

  factory :redirect_route do
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
    sequence(:title) { |n| "Browse page #{n}" }
    sequence(:slug) { |n| "browse-page-#{n}" }
    description "Example description"

    trait :draft do
      # no-op because initial state is draft
    end

    trait :published do
      after :create do |tag|
        tag.publish!
      end
    end

    trait :archived do
      after :create do |tag|
        tag.publish!
        tag.move_to_archive!
      end
    end

    factory :topic, class: Topic
    factory :mainstream_browse_page, class: MainstreamBrowsePage
  end
end
