FactoryBot.define do
  factory :vote do
    votable factory: :debate
    voter factory: :user
    vote_flag { true }
    after(:create) do |vote, _|
      vote.votable.update_cached_votes
    end
  end
end
