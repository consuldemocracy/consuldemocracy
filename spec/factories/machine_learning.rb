FactoryBot.define do
  factory :machine_learning_job do
    script { "proposal_tags" }
    user
    started_at { Time.current }
    dry_run { false }
    config { {} }

    trait :active do
      started_at { Time.current }
      finished_at { nil }
      error { nil }
    end

    trait :finished do
      finished_at { Time.current }
    end

    trait :errored do
      error { "StandardError: Something went wrong" }
    end
  end

  factory :machine_learning_info do
    kind { "comments_summary" }
    script { "proposal_tags" }
    generated_at { Time.current }
    updated_at { Time.current }
  end

  factory :ml_summary_comment do
    commentable factory: :proposal
    body { "Sample summary" }
  end
end
