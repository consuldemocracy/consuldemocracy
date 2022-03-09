section "Flagging Debates & Comments" do
  40.times do
    debate = Debate.all.sample
    flagger = User.where.not(id: debate.author_id).all.sample
    Flag.flag(flagger, debate)
  end

  40.times do
    comment = Comment.all.sample
    flagger = User.where.not(id: comment.user_id).all.sample
    Flag.flag(flagger, comment)
  end

  40.times do
    proposal = Proposal.all.sample
    flagger = User.where.not(id: proposal.author_id).all.sample
    Flag.flag(flagger, proposal)
  end
end

section "Ignoring flags in Debates, comments & proposals" do
  Debate.flagged.sample(10).each(&:ignore_flag)
  Comment.flagged.sample(30).each(&:ignore_flag)
  Proposal.flagged.sample(10).each(&:ignore_flag)
end
