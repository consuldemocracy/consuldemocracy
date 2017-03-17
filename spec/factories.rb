FactoryGirl.define do
  sequence(:document_number) { |n| "#{n.to_s.rjust(8, '0')}X" }

  factory :user do
    sequence(:username) { |n| "Manuela#{n}" }
    sequence(:email)    { |n| "manuela#{n}@consul.dev" }

    password            'judgmentday'
    terms_of_service     '1'
    confirmed_at        { Time.current }

    trait :incomplete_verification do
      after :create do |user|
        create(:failed_census_call, user: user)
      end
    end

    trait :level_two do
      residence_verified_at Time.current
      unconfirmed_phone "611111111"
      confirmed_phone "611111111"
      sms_confirmation_code "1234"
      document_type "1"
      document_number
    end

    trait :level_three do
      verified_at Time.current
      document_type "1"
      document_number
    end

    trait :hidden do
      hidden_at Time.current
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.current
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
    locked_until Time.current
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
      hidden_at Time.current
    end

    trait :with_ignored_flag do
      ignored_flag_at Time.current
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.current
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
      hidden_at Time.current
    end

    trait :with_ignored_flag do
      ignored_flag_at Time.current
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.current
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

  factory :budget do
    sequence(:name) { |n| "Budget #{n}" }
    currency_symbol "€"
    phase 'accepting'
    description_accepting "This budget is accepting"
    description_reviewing "This budget is reviewing"
    description_selecting "This budget is selecting"
    description_valuating "This budget is valuating"
    description_balloting "This budget is balloting"
    description_reviewing_ballots "This budget is reviewing ballots"
    description_finished "This budget is finished"

    trait :accepting do
      phase 'accepting'
    end

    trait :reviewing do
      phase 'reviewing'
    end

    trait :selecting do
      phase 'selecting'
    end

    trait :valuating do
      phase 'valuating'
    end

    trait :balloting do
      phase 'balloting'
    end

    trait :reviewing_ballots do
      phase 'reviewing_ballots'
    end

    trait :finished do
      phase 'finished'
    end
  end

  factory :budget_group, class: 'Budget::Group' do
    budget
    sequence(:name) { |n| "Group #{n}" }
  end

  factory :budget_heading, class: 'Budget::Heading' do
    association :group, factory: :budget_group
    sequence(:name) { |n| "Heading #{n}" }
    price 1000000
  end

  factory :budget_investment, class: 'Budget::Investment' do
    sequence(:title)     { |n| "Budget Investment #{n} title" }
    association :heading, factory: :budget_heading
    association :author, factory: :user
    description          'Spend money on this'
    price                10
    unfeasibility_explanation ''
    external_url         'http://external_documention.org'
    terms_of_service     '1'

    trait :with_confidence_score do
      before(:save) { |i| i.calculate_confidence_score }
    end

    trait :feasible do
      feasibility "feasible"
    end

    trait :unfeasible do
      feasibility "unfeasible"
      unfeasibility_explanation "set to unfeasible on creation"
    end

    trait :finished do
      valuation_finished true
    end

    trait :selected do
      selected true
      feasibility "feasible"
      valuation_finished true
    end
  end

  factory :budget_ballot, class: 'Budget::Ballot' do
    association :user, factory: :user
    budget
  end

  factory :budget_ballot_line, class: 'Budget::Ballot::Line' do
    association :ballot, factory: :budget_ballot
    association :investment, factory: :budget_investment
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
      hidden_at Time.current
    end

    trait :with_ignored_flag do
      ignored_flag_at Time.current
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.current
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

  factory :legislation do
    sequence(:title) { |n| "Legislation #{n}" }
    body "In order to achieve this..."
  end

  factory :annotation do
    quote "ipsum"
    text "Loremp ipsum dolor"
    ranges [{"start"=>"/div[1]", "startOffset"=>5, "end"=>"/div[1]", "endOffset"=>10}]
    legislation
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
      verified_at Time.current
    end

    trait :rejected do
      rejected_at Time.current
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
    time DateTime.current
    sequence(:name) {|n| "Event #{n} type"}
  end

  factory :visit  do
    id { SecureRandom.uuid }
    started_at DateTime.current
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
    sequence(:external_code) { |n| "#{n}" }
    sequence(:census_code) { |n| "#{n}" }
  end

  factory :banner do
    sequence(:title) { |n| "Banner title #{n}" }
    sequence(:description)  { |n| "This is the text of Banner #{n}" }
    style {["banner-style-one", "banner-style-two", "banner-style-three"].sample}
    image {["banner.banner-img-one", "banner.banner-img-two", "banner.banner-img-three"].sample}
    target_url {["/proposals", "/debates" ].sample}
    post_started_at Time.current - 7.days
    post_ended_at Time.current + 7.days
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

  factory :signature_sheet do
    association :signable, factory: :proposal
    association :author, factory: :user
    document_numbers "123A, 456B, 789C"
  end

  factory :signature do
    signature_sheet
    sequence(:document_number) { |n| "#{n}A" }
  end

  factory :site_customization_page, class: 'SiteCustomization::Page' do
    slug "example-page"
    title "Example page"
    subtitle "About an example"
    content "This page is about..."
    more_info_flag false
    print_content_flag false
    status 'draft'

    trait :published do
      status "published"
    end

    trait :display_in_more_info do
      more_info_flag true
    end
  end
end
