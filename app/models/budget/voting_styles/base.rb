class Budget::VotingStyles::Base
  attr_reader :ballot

  def initialize(ballot)
    @ballot = ballot
  end
end
