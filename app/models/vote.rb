class Vote < ActsAsVotable::Vote
end

# == Schema Information
#
# Table name: votes
#
#  id           :integer          not null, primary key
#  votable_id   :integer
#  votable_type :string
#  voter_id     :integer
#  voter_type   :string
#  vote_flag    :boolean
#  vote_scope   :string
#  vote_weight  :integer
#  created_at   :datetime
#  updated_at   :datetime
#  signature_id :integer
#
