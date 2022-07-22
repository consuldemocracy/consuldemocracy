FactoryBot.define do
  factory :notification do
    user
    association :notifiable, factory: :proposal

    trait :read do
      read_at { Time.current }
    end

    trait :for_proposal_notification do
      association :notifiable, factory: :proposal_notification
    end

    trait :for_comment do
      association :notifiable, factory: :comment
    end

    trait :for_poll_question do
      association :notifiable, factory: :poll_question
    end
  end

  factory :admin_notification do
    sequence(:title)  { |n| "Admin Notification title #{n}" }
    sequence(:body)   { |n| "Admin Notification body #{n}" }
    link              { nil }
    segment_recipient { UserSegments.segments.sample }
    recipients_count  { nil }
    sent_at           { nil }

    trait :sent do
      recipients_count { 1 }
      sent_at { Time.current }
    end
  end
end
