ActsAsVotable::Vote.class_eval do
  def self.for_debates(debates)
    where(votable_type: 'Debate', votable_id: debates)
  end

  def self.for_proposals(proposals)
    where(votable_type: 'Proposal', votable_id: proposals)
  end

  def self.for_spending_proposals(spending_proposals)
    where(votable_type: 'SpendingProposal', votable_id: spending_proposals)
  end

  def self.city_wide
    joins(:votable).where("#{votable.table_name}.geozone is null")
  end

  def self.district_wide
    joins(:votable).where("#{votable.table_name}.geozone is not null")
  end

  def value
    vote_flag
  end
end
