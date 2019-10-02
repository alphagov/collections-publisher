FactoryBot.define do
  factory :link_report do
    batch_id { 1 }
    completed { "2018-08-07 10:35:38" }
    step { nil }
  end
  factory :step_by_step_page do
    title { "How to be amazing" }
    slug { "how-to-be-the-amazing-1" }
    content_id { SecureRandom.uuid }
    introduction { "Find out the steps to become amazing" }
    description { "How to be amazing - find out the steps to become amazing" }
    status { "draft" }
    draft_updated_at { 3.hours.ago }

    factory :step_by_step_page_with_steps, aliases: [:draft_step_by_step_page] do
      after(:create) do |step_by_step_page|
        create(:step, step_by_step_page: step_by_step_page)
        create(:or_step, step_by_step_page: step_by_step_page)
      end
    end
  end

  factory :published_step_by_step_page, parent: :step_by_step_page_with_steps do
    published_at { 3.hours.ago }
    status { "published" }
  end

  factory :step_by_step_with_unpublished_changes, parent: :step_by_step_page_with_steps do
    published_at { 3.hours.ago }
    draft_updated_at { 2.hours.ago }
    status { "draft" }
  end

  factory :scheduled_step_by_step_page, parent: :step_by_step_page_with_steps do
    scheduled_at { 3.hours.from_now }
    status { "scheduled" }
  end

  factory :step_by_step_page_with_navigation_rules, parent: :step_by_step_page_with_steps do
    after(:create) do |step_by_step_page|
      create(:navigation_rule, step_by_step_page: step_by_step_page)
      create(:navigation_rule, step_by_step_page: step_by_step_page, title: "Also good stuff", base_path: "/also/good/stuff")
    end
  end

  factory :step_by_step_page_with_smartanswer_navigation_rules, parent: :step_by_step_page do
    after(:create) do |step_by_step_page|
      create(:navigation_rule, step_by_step_page: step_by_step_page)
      create(:smartanswer_step, step_by_step_page: step_by_step_page)
      create(:smartanswer_navigation_rule, step_by_step_page: step_by_step_page)
    end
  end

  factory :step_by_step_page_with_secondary_content, parent: :step_by_step_page_with_steps do
    after(:create) do |step_by_step_page|
      create(:secondary_content_link, step_by_step_page: step_by_step_page)
    end
  end

  factory :step_by_step_page_with_secondary_content_and_navigation_rules, parent: :step_by_step_page_with_steps do
    after(:create) do |step_by_step_page|
      create(:secondary_content_link, step_by_step_page: step_by_step_page)
      create(:navigation_rule, step_by_step_page: step_by_step_page)
      create(:navigation_rule, step_by_step_page: step_by_step_page, title: "Also good stuff", base_path: "/also/good/stuff")
    end
  end

  factory :step_by_step_page_submitted_for_2i, parent: :step_by_step_page_with_steps do
    status { "submitted_for_2i" }
  end

  factory :step_by_step_page_claimed_for_2i, parent: :step_by_step_page_submitted_for_2i do
    status { "submitted_for_2i" }
    review_requester_id { SecureRandom.uuid }

    after(:create) do |step_by_step_page|
      step_by_step_page.update_attributes!(status: "in_review")
    end
  end

  factory :step do
    title { "Check how awesome you are" }
    logic { "number" }
    position { 1 }
    contents {
      <<~CONTENT
        This is a great step

        - [Good stuff](/good/stuff)
        - [Also good stuff](/also/good/stuff)

        * [Not as great](/not/as/great)£25
        * [But good nonetheless](http://example.com/good)
      CONTENT
    }
    step_by_step_page

    factory :or_step do
      title { "Dress like the Fonz" }
      logic { "or" }
      position { 2 }
      contents {
        <<~CONTENT
          This is another great step
        CONTENT
      }
      step_by_step_page
    end

    factory :smartanswer_step do
      title { "This step has a smartanswer in it" }
      logic { "number" }
      position { 1 }
      contents {
        <<~CONTENT
          This is a step with a smartanswer

          [A smartanswer](/a-smartanswer)
        CONTENT
      }
      step_by_step_page
    end
  end

  factory :navigation_rule do
    title { "Good stuff" }
    base_path { "/good/stuff" }
    content_id { SecureRandom.uuid }
    publishing_app { "publisher" }
    schema_name { "guide" }
    include_in_links { "always" }
  end

  factory :smartanswer_navigation_rule, parent: :navigation_rule do
    title { "A smartanswer" }
    base_path { "/a-smartanswer" }
    content_id { SecureRandom.uuid }
    publishing_app { "smartanswers" }
    schema_name { "transaction" }
    include_in_links { "always" }
  end

  factory :secondary_content_link do
    title { "Secondary Good stuff" }
    base_path { "/secondary/good/stuff" }
    content_id { SecureRandom.uuid }
    publishing_app { "publisher" }
    schema_name { "guide" }
    step_by_step_page
  end

  factory :redirect_item do
    content_id { SecureRandom.uuid }
    from_base_path { "/from/foo" }
    to_base_path { "/to/bar" }
  end

  factory :redirect_route do
    from_base_path { "/some/route" }
    to_base_path { "/to/some/route" }
  end

  factory :user do
    uid { SecureRandom.hex }
    permissions { %w(signin) }
  end

  factory :list do
    tag
  end

  factory :list_item do
    title { "A list item title" }
  end

  factory :tag do
    sequence(:title) { |n| "Browse page #{n}" }
    sequence(:slug) { |n| "browse-page-#{n}" }
    description { "Example description" }

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

  factory :internal_change_note do
    step_by_step_page_id { 0 }
    author { "Test Author" }
    headline { "Some change" }
    description { "Description of the changes I made" }
    created_at { "2018-08-07 10:35:38" }
  end
end
