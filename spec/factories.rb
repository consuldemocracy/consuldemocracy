FactoryGirl.define do
  sequence(:document_number) { |n| "#{n.to_s.rjust(8, '0')}X" }

  factory :user do
    sequence(:username) { |n| "Manuela#{n}" }
    sequence(:email)    { |n| "manuela#{n}@consul.dev" }

    password            'judgmentday'
    terms_of_service     '1'
    confirmed_at        { Time.now }

    trait :incomplete_verification do
      after :create do |user|
        create(:failed_census_call, user: user)
      end
    end

    trait :level_two do
      residence_verified_at Time.now
      unconfirmed_phone "611111111"
      confirmed_phone "611111111"
      sms_confirmation_code "1234"
      document_type "1"
      document_number
    end

    trait :level_three do
      verified_at Time.now
      document_type "1"
      document_number
    end

    trait :hidden do
      hidden_at Time.now
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.now
    end
  end

  factory :identity do
    user nil
    provider "Twitter"
    uid "MyString"
  end

  factory :activity do
    user
    action "hide"
    association :actionable, factory: :proposal
  end

  factory :verification_residence, class: Verification::Residence do
    user
    document_number
    document_type    "1"
    date_of_birth    Date.new(1980, 12, 31)
    postal_code      "28013"
    terms_of_service '1'

    trait :invalid do
      postal_code "28001"
    end
  end

  factory :failed_census_call do
    user
    document_number
    document_type 1
    date_of_birth Date.new(1900, 1, 1)
    postal_code '28000'
  end

  factory :verification_sms, class: Verification::Sms do
    phone "699999999"
  end

  factory :verification_letter, class: Verification::Letter do
    user
    email 'user@consul.dev'
    password '1234'
    verification_code '5555'
  end

  factory :lock do
    user
    tries 0
    locked_until Time.now
  end

  factory :verified_user do
    document_number
    document_type    'dni'
  end

  factory :debate do
    sequence(:title)     { |n| "Debate #{n} title" }
    description          'Debate description'
    terms_of_service     '1'
    association :author, factory: :user

    trait :hidden do
      hidden_at Time.now
    end

    trait :with_ignored_flag do
      ignored_flag_at Time.now
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.now
    end

    trait :flagged do
      after :create do |debate|
        Flag.flag(FactoryGirl.create(:user), debate)
      end
    end

    trait :with_hot_score do
      before(:save) { |d| d.calculate_hot_score }
    end

    trait :with_confidence_score do
      before(:save) { |d| d.calculate_confidence_score }
    end

    trait :conflictive do
      after :create do |debate|
        Flag.flag(FactoryGirl.create(:user), debate)
        4.times { create(:vote, votable: debate) }
      end
    end
  end

  factory :proposal do
    sequence(:title)     { |n| "Proposal #{n} title" }
    sequence(:summary)   { |n| "In summary, what we want is... #{n}" }
    description          'Proposal description'
    question             'Proposal question'
    external_url         'http://external_documention.es'
    video_url            'http://video_link.com'
    responsible_name     'John Snow'
    terms_of_service     '1'
    association :author, factory: :user

    trait :hidden do
      hidden_at Time.now
    end

    trait :with_ignored_flag do
      ignored_flag_at Time.now
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.now
    end

    trait :flagged do
      after :create do |debate|
        Flag.flag(FactoryGirl.create(:user), debate)
      end
    end

    trait :archived do
      created_at 25.months.ago
    end

    trait :with_hot_score do
      before(:save) { |d| d.calculate_hot_score }
    end

    trait :with_confidence_score do
      before(:save) { |d| d.calculate_confidence_score }
    end

    trait :conflictive do
      after :create do |debate|
        Flag.flag(FactoryGirl.create(:user), debate)
        4.times { create(:vote, votable: debate) }
      end
    end
  end

  factory :spending_proposal do
    sequence(:title)     { |n| "Spending Proposal #{n} title" }
    description          'Spend money on this'
    feasible_explanation 'This proposal is not viable because...'
    external_url         'http://external_documention.org'
    terms_of_service     '1'
    association :author, factory: :user
  end

  factory :vote do
    association :votable, factory: :debate
    association :voter,   factory: :user
    vote_flag true
    after(:create) do |vote, _|
      vote.votable.update_cached_votes
    end
  end

  factory :flag do
    association :flaggable, factory: :debate
    association :user, factory: :user
  end

  factory :comment do
    association :commentable, factory: :debate
    user
    sequence(:body) { |n| "Comment body #{n}" }

    trait :hidden do
      hidden_at Time.now
    end

    trait :with_ignored_flag do
      ignored_flag_at Time.now
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.now
    end

    trait :flagged do
      after :create do |debate|
        Flag.flag(FactoryGirl.create(:user), debate)
      end
    end

    trait :with_confidence_score do
      before(:save) { |d| d.calculate_confidence_score }
    end
  end

  factory :legacy_legislation do
    sequence(:title) { |n| "Legacy Legislation #{n}" }
    body "In order to achieve this..."
  end

  factory :annotation do
    quote "ipsum"
    text "Loremp ipsum dolor"
    ranges [{"start"=>"/div[1]", "startOffset"=>5, "end"=>"/div[1]", "endOffset"=>10}]
    legacy_legislation
    user
  end

  factory :administrator do
    user
  end

  factory :moderator do
    user
  end

  factory :valuator do
    user
  end

  factory :manager do
    user
  end

  factory :organization do
    user
    responsible_name "Johnny Utah"
    sequence(:name) { |n| "org#{n}" }

    trait :verified do
      verified_at Time.now
    end

    trait :rejected do
      rejected_at Time.now
    end
  end

  factory :tag, class: 'ActsAsTaggableOn::Tag' do
    sequence(:name) { |n| "Tag #{n} name" }

    trait :featured do
      featured true
    end

    trait :unfeatured do
      featured false
    end
  end

  factory :setting do
    sequence(:key) { |n| "Setting Key #{n}" }
    sequence(:value) { |n| "Setting #{n} Value" }
  end

  factory :ahoy_event, :class => Ahoy::Event do
    id { SecureRandom.uuid }
    time DateTime.now
    sequence(:name) {|n| "Event #{n} type"}
  end

  factory :visit  do
    id { SecureRandom.uuid }
    started_at DateTime.now
  end

  factory :campaign do
    sequence(:name) { |n| "Campaign #{n}" }
    sequence(:track_id) { |n| "#{n}" }
  end

  factory :notification do
    user
    association :notifiable, factory: :proposal
  end

  factory :geozone do
    sequence(:name) { |n| "District #{n}" }
    census_code { '01' }
  end

  factory :banner do
    sequence(:title) { |n| "Banner title #{n}" }
    sequence(:description)  { |n| "This is the text of Banner #{n}" }
    style {["banner-style-one", "banner-style-two", "banner-style-three"].sample}
    image {["banner.banner-img-one", "banner.banner-img-two", "banner.banner-img-three"].sample}
    target_url {["/proposals", "/debates" ].sample}
    post_started_at Time.now - 7.days
    post_ended_at Time.now + 7.days
  end

  factory :proposal_notification do
    sequence(:title) { |n| "Thank you for supporting my proposal #{n}" }
    sequence(:body) { |n| "Please let others know so we can make it happen #{n}" }
    proposal
  end

  factory :direct_message do
    title    "Hey"
    body     "How are You doing?"
    association :sender,   factory: :user
    association :receiver, factory: :user
  end
end
