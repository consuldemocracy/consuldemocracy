FactoryBot.define do
  factory :poll do
    sequence(:name) { |n| "Poll #{SecureRandom.hex}" }

    slug { "this-is-a-slug" }

    starts_at { 1.month.ago }
    ends_at { 1.month.from_now }
    to_create { |poll| poll.save(validate: false) }

    trait :expired do
      starts_at { 1.month.ago }
      ends_at { 15.days.ago }
    end

    trait :old do
      starts_at { 3.months.ago }
      ends_at { 2.months.ago }
    end

    trait :future do
      starts_at { 1.day.from_now }
    end

    trait :published do
      published { true }
    end

    trait :hidden do
      hidden_at { Time.current }
    end

    trait :for_budget do
      budget
    end

    trait :with_image do
      after(:create) { |poll| create(:image, imageable: poll) }
    end

    trait :with_author do
      author factory: :user
    end

    transient { officers { [] } }

    after(:create) do |poll, evaluator|
      evaluator.officers.each do |officer|
        create(:poll_officer_assignment, poll: poll, officer: officer)
      end
    end

    factory :poll_with_author, traits: [:with_author]
  end

  factory :poll_question, class: "Poll::Question" do
    poll
    author factory: :user
    sequence(:title) { |n| "Question title #{n}" }

    trait :yes_no do
      after(:create) do |question|
        create(:votation_type_unique, questionable: question)
        create(:poll_question_option, question: question, title: "Yes")
        create(:poll_question_option, question: question, title: "No")
      end
    end

    trait :yes_no_open_text do
      after(:create) do |question|
        create(:poll_question_option, question: question, title: "Yes", open_text: true)
        create(:poll_question_option, question: question, title: "No", open_text: true)
      end
    end

    trait :abc do
      after(:create) do |question|
        %w[A B C].each do |letter|
          create(:poll_question_option, question: question, title: "Answer #{letter}")
        end
      end
    end

    trait :abc_open_text do
      after(:create) do |question|
        %w[A B C].each do |letter|
          create(:poll_question_option, question: question, title: "Answer #{letter}", open_text: true)
        end
      end
    end

    trait :abcde do
      after(:create) do |question|
        %w[A B C D E].each do |letter|
          create(:poll_question_option, question: question, title: "Answer #{letter}")
        end
      end
    end

    factory :poll_question_unique do
      after(:create) do |question|
        create(:votation_type_unique, questionable: question)
      end
    end

    factory :poll_question_multiple do
      transient { max_votes { 3 } }

      after(:create) do |question, evaluator|
        create(:votation_type_multiple, questionable: question, max_votes: evaluator.max_votes)
      end
    end

    factory :poll_question_open do
      after(:create) do |question|
        create(:votation_type_open, questionable: question)
      end
    end
  end

  factory :poll_question_option, class: "Poll::Question::Option" do
    sequence(:title) { |n| "Answer title #{n}" }
    sequence(:description) { |n| "Answer description #{n}" }
    sequence(:given_order) { |n| n }

    transient { poll { association(:poll) } }

    question { association(:poll_question, poll: poll) }

    trait :with_image do
      after(:create) { |option| create(:image, imageable: option) }
    end

    trait :with_document do
      after(:create) { |option| create(:document, documentable: option) }
    end

    trait :with_video do
      after(:create) { |option| create(:poll_option_video, option: option) }
    end

    factory :future_poll_question_option do
      poll { association(:poll, :future) }
    end
  end

  factory :poll_option_video, class: "Poll::Question::Option::Video" do
    title { "Sample video title" }
    url { "https://youtu.be/nhuNb0XtRhQ" }

    transient { poll { association(:poll) } }

    option { association(:poll_question_option, poll: poll) }
  end

  factory :poll_booth, class: "Poll::Booth" do
    sequence(:name) { |n| "Booth #{n}" }
    sequence(:location) { |n| "Street #{n}" }
  end

  factory :poll_booth_assignment, class: "Poll::BoothAssignment" do
    poll
    booth factory: :poll_booth
  end

  factory :poll_officer_assignment, class: "Poll::OfficerAssignment" do
    officer factory: :poll_officer
    date { Date.current }

    transient { poll { association(:poll) } }
    transient { booth { association(:poll_booth) } }

    booth_assignment do
      association :poll_booth_assignment, poll: poll, booth: booth
    end

    trait :final do
      final { true }
    end
  end

  factory :poll_shift, class: "Poll::Shift" do
    booth factory: :poll_booth
    officer factory: :poll_officer
    date { Date.current }

    trait :vote_collection_task do
      task { 0 }
    end

    trait :recount_scrutiny_task do
      task { 1 }
    end
  end

  factory :poll_voter, class: "Poll::Voter" do
    user factory: [:user, :level_two]
    from_web

    transient { budget { nil } }

    poll { budget&.poll || association(:poll, budget: budget) }
    trait :from_web do
      origin { "web" }
    end

    trait :from_booth do
      origin { "booth" }

      transient { booth { association(:poll_booth) } }

      booth_assignment do
        association :poll_booth_assignment, poll: poll, booth: booth
      end

      officer_assignment do
        association :poll_officer_assignment,
                    booth_assignment: booth_assignment,
                    officer: officer || association(:poll_officer)
      end
    end

    trait :valid_document do
      document_type   { "1" }
      document_number { "12345678Z" }
    end

    trait :invalid_document do
      document_type   { "1" }
      document_number { "99999999A" }
    end
  end

  factory :poll_answer, class: "Poll::Answer" do
    question factory: [:poll_question, :yes_no]
    author factory: [:user, :level_two]
    option do
      if answer
        question.question_options.find_by(title: answer)
      else
        question.question_options.sample
      end
    end
    after(:build) { |poll_answer| poll_answer.answer ||= poll_answer.option&.title }
  end

  factory :poll_partial_result, class: "Poll::PartialResult" do
    question factory: [:poll_question, :yes_no]
    author factory: :user
    origin { "web" }
    option do
      if answer
        question.question_options.find_by(title: answer)
      else
        question.question_options.sample
      end
    end
    after(:build) { |poll_partial_result| poll_partial_result.answer ||= poll_partial_result.option&.title }
  end

  factory :poll_recount, class: "Poll::Recount" do
    author factory: :user
    origin { "web" }

    trait :from_booth do
      origin { "booth" }

      transient { poll { nil } }

      booth_assignment do
        association :poll_booth_assignment, poll: poll
      end
    end
  end

  factory :poll_ballot_sheet, class: "Poll::BallotSheet" do
    poll
    officer_assignment factory: :poll_officer_assignment
    data { "1234;9876;5678\n1000;2000;3000;9999" }
  end

  factory :poll_ballot, class: "Poll::Ballot" do
    ballot_sheet factory: :poll_ballot_sheet
    data { "1,2,3" }
  end

  factory :officing_residence, class: "Officing::Residence" do
    user
    officer factory: :poll_officer
    document_number
    document_type    { "1" }
    year_of_birth    { "1980" }

    trait :invalid do
      year_of_birth { Time.current.year }
    end
  end

  factory :active_poll
end
