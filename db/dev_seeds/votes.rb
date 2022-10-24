section "Voting Debates, Proposals & Comments" do
  not_org_users = User.where.not(id: User.organizations)
  100.times do
    voter  = not_org_users.level_two_or_three_verified.all.sample
    vote   = [true, false].sample
    debate = Debate.all.sample
    debate.vote_by(voter: voter, vote: vote)
  end

  100.times do
    voter  = not_org_users.all.sample
    vote   = [true, false].sample
    comment = Comment.all.sample
    comment.vote_by(voter: voter, vote: vote)
  end

  100.times do
    voter = not_org_users.level_two_or_three_verified.all.sample
    proposal = Proposal.all.sample
    proposal.vote_by(voter: voter, vote: true)
  end
end
