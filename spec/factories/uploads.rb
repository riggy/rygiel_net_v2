FactoryBot.define do
  factory :upload do
    after(:build) do |upload|
      upload.file.attach(
        io: StringIO.new("fake png content"),
        filename: "test.png",
        content_type: "image/png"
      )
    end

    trait :non_image do
      after(:build) do |upload|
        upload.file.detach
        upload.file.attach(
          io: StringIO.new("plain text"),
          filename: "doc.txt",
          content_type: "text/plain"
        )
      end
    end

    trait :jpeg do
      after(:build) do |upload|
        upload.file.detach
        upload.file.attach(
          io: StringIO.new("fake jpeg"),
          filename: "photo.jpg",
          content_type: "image/jpeg"
        )
      end
    end

    trait :webp do
      after(:build) do |upload|
        upload.file.detach
        upload.file.attach(
          io: StringIO.new("fake webp"),
          filename: "photo.webp",
          content_type: "image/webp"
        )
      end
    end
  end
end
