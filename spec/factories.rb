FactoryGirl.define do
  factory :user do
    permissions { ["signin"] }
  end

  factory :list
end
