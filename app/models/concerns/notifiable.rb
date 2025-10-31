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

  def notifiable_body
    body if attribute_names.include?("body")
  end

  def notifiable_available?
    notifiable_resource.present? &&
      !(notifiable_resource.respond_to?(:hidden?) && notifiable_resource.hidden?) &&
      !(notifiable_resource.respond_to?(:retired?) && notifiable_resource.retired?)
  end

  def notifiable_resource
    case self.class.name
    when "ProposalNotification"
      proposal
    when "Comment"
      commentable
    else
      self
    end
  end

  def linkable_resource
    is_a?(ProposalNotification) ? proposal : self
  end
end
