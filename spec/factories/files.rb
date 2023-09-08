FactoryBot.define do
  factory :image do
    attachment { Rack::Test::UploadedFile.new("spec/fixtures/files/clippy.jpg") }
    title { "Lorem ipsum dolor sit amet" }
    user

    trait :proposal_image do
      imageable factory: :proposal
    end

    trait :budget_image do
      imageable factory: :budget
    end

    trait :budget_investment_image do
      imageable factory: :budget_investment
    end
  end

  factory :document do
    sequence(:title) { |n| "Document title #{n}" }
    user
    attachment { Rack::Test::UploadedFile.new("spec/fixtures/files/empty.pdf") }

    trait :proposal_document do
      documentable factory: :proposal
    end

    trait :budget_investment_document do
      documentable factory: :budget_investment
    end

    trait :poll_question_document do
      documentable factory: :poll_question
    end

    trait :admin do
      admin { true }
    end
  end

  factory :direct_upload do
    user

    trait :proposal do
      resource_type { "Proposal" }
    end
    trait :budget_investment do
      resource_type { "Budget::Investment" }
    end

    trait :documents do
      resource_relation { "documents" }
      attachment { Rack::Test::UploadedFile.new("spec/fixtures/files/empty.pdf") }
    end
    trait :image do
      resource_relation { "image" }
      attachment { Rack::Test::UploadedFile.new("spec/fixtures/files/clippy.jpg") }
    end
    initialize_with { new(attributes) }
  end

  factory :active_storage_blob, class: "ActiveStorage::Blob" do
    filename { "sample.pdf" }
    byte_size { 3000 }
    checksum { SecureRandom.hex(32) }
  end
end
