FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "Post Title #{n}" }
    body      { "Post body content." }
    published { false }

    trait :published do
      published    { true }
      published_at { 1.day.ago }
    end
  end
end
