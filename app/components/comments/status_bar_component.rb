class Comments::StatusBarComponent < ApplicationComponent
  attr_reader :comment, :valuation
  delegate :comments_closed_for_commentable?, :require_verified_resident_for_commentable?, to: :helpers

  def initialize(comment, valuation:)
    @comment = comment
    @valuation = valuation
  end

  private

    def button_text
      if comment.present?
        t("comments_helper.reply_link")
      else
        t("comments_helper.comment_link")
      end
    end

    def button_attributes
      {
        type: "button",
        class: "add-comment",
        "aria-expanded": false,
        data: { id: dom_id(comment) }
      }
    end

    def can_comment?
      current_user &&
        !comments_closed_for_commentable?(comment.commentable) &&
        !require_verified_resident_for_commentable?(comment.commentable, current_user)
    end
end
