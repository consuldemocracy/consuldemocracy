ActsAsVotable::Vote.class_eval do
  belongs_to :signature
  belongs_to :budget_investment, foreign_key: 'votable_id', class_name: 'Budget::Investment'

  def self.for_debates(debates)
    where(votable_type: 'Debate', votable_id: debates)
  end

  def self.for_proposals(proposals)
    where(votable_type: 'Proposal', votable_id: proposals)
  end

  def self.for_spending_proposals(spending_proposals)
    where(votable_type: 'SpendingProposal', votable_id: spending_proposals)
  end

  def self.representative_votes
    where(votable_type: 'SpendingProposal', voter_id: User.forums.pluck(:id))
  end

  def self.city_wide
    joins(:votable).where("#{votable.table_name}.geozone is null")
  end

  def self.district_wide
    joins(:votable).where("#{votable.table_name}.geozone is not null")
  end

  def self.for_budget_investments(budget_investments)
    where(votable_type: 'Budget::Investment', votable_id: budget_investments)
  end

  def value
    vote_flag
  end

end
