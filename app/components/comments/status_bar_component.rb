class Comments::StatusBarComponent < ApplicationComponent
  attr_reader :comment, :valuation
  use_helpers :current_user, :can?,
              :comments_closed_for_commentable?,
              :require_verified_resident_for_commentable?

  def initialize(comment, valuation:)
    @comment = comment
    @valuation = valuation
  end

  private

    def link_text
      if comment.present?
        t("comments_helper.reply_link")
      else
        t("comments_helper.comment_link")
      end
    end

    def can_comment?
      current_user &&
        !comments_closed_for_commentable?(comment.commentable) &&
        !require_verified_resident_for_commentable?(comment.commentable, current_user)
    end
end
