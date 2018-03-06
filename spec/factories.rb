FactoryBot.define do
  factory :step_by_step_page do
    title "How to be amazing"
    base_path "how-to-be-the-amazing-1"
    introduction "Find out the steps to become amazing"
    description "How to be amazing - find out the steps to become amazing"
    content_id SecureRandom.uuid

    factory :step_by_step_page_with_steps do
      after(:create) do |step_by_step_page|
        create(:step, step_by_step_page: step_by_step_page)
      end
    end
  end

  factory :step do
    title "Check how awesome you are"
    logic "number"
    step_by_step_page
  end

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
