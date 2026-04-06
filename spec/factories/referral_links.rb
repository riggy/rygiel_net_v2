FactoryBot.define do
  factory :referral_link do
    sequence(:slug) { |n| "link-#{n}" }
    name        { "LinkedIn Profile" }
    target_path { "/cv" }
    clicks      { 0 }
    active      { true }

    trait :inactive do
      active { false }
    end

    trait :with_clicks do
      clicks { 42 }
    end
  end
end
