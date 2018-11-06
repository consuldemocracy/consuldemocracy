module Notifiable
  extend ActiveSupport::Concern

  def notifiable_title
    case self.class.name
    when "ProposalNotification"
      proposal.title
    when "Comment"
      commentable.title
    else
      title
    end
  end

  def notifiable_available?
    case self.class.name
    when "ProposalNotification"
      check_availability(proposal)
    when "Comment"
      check_availability(commentable)
    else
      check_availability(self)
    end
  end

  def check_availability(resource)
    resource.present? &&
      resource.try(:hidden_at).nil? &&
      resource.try(:retired_at).nil?
  end

  def linkable_resource
    is_a?(ProposalNotification) ? proposal : self
  end
end
