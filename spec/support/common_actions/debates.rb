module Debates
  # spec/features/debates_spec.rb
  # spec/features/tags/debates_spec.rb
  def create_featured_debates
    [create(:debate, :with_confidence_score, cached_votes_up: 100),
     create(:debate, :with_confidence_score, cached_votes_up: 90),
     create(:debate, :with_confidence_score, cached_votes_up: 80)]
  end
end
