require_dependency Rails.root.join("app", "mailers", "mailer").to_s

class Mailer

  def commentForOfficial(comment, official)
    @comment = comment
    @commentable = comment.commentable
    @official = official
    @email_to = official.email

    with_user(official) do
      subject = t("mailers.comment.subject", commentable: t("activerecord.models.#{@commentable.class.name.underscore}", count: 1).downcase)
      mail(to: @email_to, subject: subject) if @commentable.present? && official.present?
    end
  end

  def proposal_created(proposal, official)
    @proposal = proposal
    @official = official
    @email_to = official.email

    with_user(official) do
      subject = t("mailers.proposal_created.subject")
      mail(to: @email_to, subject: subject) if @proposal.present? && official.present?
    end
  end

end
