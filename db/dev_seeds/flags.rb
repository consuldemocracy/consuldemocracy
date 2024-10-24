section "Flagging Debates & Comments" do
  40.times do
    debate = Debate.sample
    flagger = User.excluding(debate.author).sample
    Flag.flag(flagger, debate)
  end

  40.times do
    comment = Comment.sample
    flagger = User.excluding(comment.user).sample
    Flag.flag(flagger, comment)
  end

  40.times do
    proposal = Proposal.sample
    flagger = User.excluding(proposal.author).sample
    Flag.flag(flagger, proposal)
  end
end

section "Ignoring flags in Debates, comments & proposals" do
  Debate.flagged.sample(10).each(&:ignore_flag)
  Comment.flagged.sample(30).each(&:ignore_flag)
  Proposal.flagged.sample(10).each(&:ignore_flag)
end
