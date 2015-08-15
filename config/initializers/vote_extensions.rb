ActsAsVotable::Vote.class_eval do
  def self.for_debates
    where(votable_type: 'Debate')
  end

  def self.in(debates)
    where(votable_id: debates)
  end

  def value
    vote_flag
  end
end