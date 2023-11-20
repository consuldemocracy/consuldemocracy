section "Voting Debates, Proposals & Comments" do
  not_org_users = User.where.not(id: User.organizations)
  100.times do
    voter  = not_org_users.level_two_or_three_verified.sample
    vote   = [true, false].sample
    debate = Debate.sample
    debate.vote_by(voter: voter, vote: vote)
  end

  100.times do
    voter  = not_org_users.sample
    vote   = [true, false].sample
    comment = Comment.sample
    comment.vote_by(voter: voter, vote: vote)
  end

  100.times do
    voter = not_org_users.level_two_or_three_verified.sample
    proposal = Proposal.sample
    proposal.vote_by(voter: voter, vote: true)
  end
end
