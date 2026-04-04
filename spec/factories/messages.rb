FactoryBot.define do
  factory :message do
    association :conversation
    role    { "user" }
    content { "Hello, how are you?" }

    trait :user do
      role    { "user" }
      content { "Hello, how are you?" }
    end

    trait :assistant do
      role    { "assistant" }
      content { "I am doing well, thanks!" }
    end
  end
end
