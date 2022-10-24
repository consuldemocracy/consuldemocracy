FactoryBot.define do
  factory :comment do
    association :commentable, factory: :debate
    user
    sequence(:body) { |n| "Comment body #{n}" }

    %i[budget_investment debate legislation_annotation legislation_question legislation_proposal
       poll proposal topic_with_community].each do |model|
      factory :"#{model}_comment" do
        association :commentable, factory: model
      end
    end

    trait :hidden do
      hidden_at { Time.current }
    end

    trait :with_ignored_flag do
      ignored_flag_at { Time.current }
    end

    trait :with_confirmed_hide do
      confirmed_hide_at { Time.current }
    end

    trait :flagged do
      after :create do |debate|
        Flag.flag(create(:user), debate)
      end
    end

    trait :with_confidence_score do
      before(:save, &:calculate_confidence_score)
    end

    trait :valuation do
      valuation { true }
      association :commentable, factory: :budget_investment
      before :create do |valuation|
        valuator = create(:valuator)
        valuation.author = valuator.user
        valuation.commentable.valuators << valuator
      end
    end

    transient { voters { [] } }

    after(:create) do |comment, evaluator|
      evaluator.voters.each { |voter| create(:vote, votable: comment, voter: voter) }
    end
  end
end
