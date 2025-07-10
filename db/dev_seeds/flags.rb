section "Flagging Debates & Comments" do
  40.times do
    debate = Debate.all.sample
    flagger = User.where(["users.id <> ?", debate.author_id]).all.sample
    Flag.flag(flagger, debate)
  end

  40.times do
    comment = Comment.all.sample
    flagger = User.where(["users.id <> ?", comment.user_id]).all.sample
    Flag.flag(flagger, comment)
  end

  40.times do
    proposal = Proposal.all.sample
    flagger = User.where(["users.id <> ?", proposal.author_id]).all.sample
    Flag.flag(flagger, proposal)
  end
end

section "Ignoring flags in Debates, comments & proposals" do
  Debate.flagged.reorder("RANDOM()").limit(10).each(&:ignore_flag)
  Comment.flagged.reorder("RANDOM()").limit(30).each(&:ignore_flag)
  Proposal.flagged.reorder("RANDOM()").limit(10).each(&:ignore_flag)
end
