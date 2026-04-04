FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    description { "A sample project." }
    tech_tags   { "Ruby, Rails" }
    url         { "https://example.com" }
    featured    { false }

    trait :featured do
      featured { true }
    end
  end
end
