class EvaluationCommentEmail
  attr_reader :comment

  def initialize(comment)
    @comment = comment
  end

  def commentable
    comment.commentable
  end

  def to
    @to ||= related_users
  end

  def subject
    I18n.t("mailers.evaluation_comment.subject")
  end

  def can_be_sent?
    commentable.present? && to.any?
  end

  private

    def related_users
      return [] if comment.commentable.nil?

      comment.commentable
             .admin_and_valuator_users_associated
             .reject { |associated_user| associated_user.user == comment.author }
    end
end
