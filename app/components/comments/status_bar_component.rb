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

    def comment_link_text(parent_id)
      parent_id.present? ? t("comments_helper.reply_link") : t("comments_helper.comment_link")
    end
end
