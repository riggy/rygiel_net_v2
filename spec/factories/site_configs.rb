FactoryBot.define do
  factory :site_config do
    sequence(:key) { |n| "config_key_#{n}" }
    value { "config value" }

    factory :site_config_hero_tagline do
      key   { "hero_tagline" }
      value { "Hi, I'm Krzysztof Rygielski." }
    end

    factory :site_config_about_text do
      key   { "about_text" }
      value { "About me text." }
    end

    factory :site_config_skills do
      key   { "skills" }
      value { "Ruby, Rails, JavaScript" }
    end
  end
end
