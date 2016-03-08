module SpendingProposalsHelper

  def spending_proposal_tags_select_options
    ActsAsTaggableOn::Tag.spending_proposal_tags.pluck(:name)
  end
end