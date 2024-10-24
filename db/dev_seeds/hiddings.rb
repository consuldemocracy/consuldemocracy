section "Hiding debates, comments & proposals" do
  Comment.with_hidden.flagged.sample(30).each(&:hide)
  Debate.with_hidden.flagged.sample(5).each(&:hide)
  Proposal.with_hidden.flagged.sample(10).each(&:hide)
end

section "Confirming hiding in debates, comments & proposals" do
  Comment.only_hidden.flagged.sample(10).each(&:confirm_hide)
  Debate.only_hidden.flagged.sample(5).each(&:confirm_hide)
  Proposal.only_hidden.flagged.sample(5).each(&:confirm_hide)
end
