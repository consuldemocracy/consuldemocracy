module HumanRightsHelper

  def css_for_human_rights_user(proposal)
    "human-rights" if proposal.author_id == 180346
  end

  def css_for_human_rights_phase(phase)
    "active" if feature?("human_rights.#{phase}")
  end

end