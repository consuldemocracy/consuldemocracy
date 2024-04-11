class Comments::AvatarComponent < ApplicationComponent
  attr_reader :comment

  def initialize(comment)
    @comment = comment
  end

  private

    def avatar
      if comment.as_administrator?
        special_avatar("avatar_admin.png", class: "admin-avatar")
      elsif comment.as_moderator?
        special_avatar("avatar_moderator.png", class: "moderator-avatar")
      elsif comment.user.hidden? || comment.user.erased?
        tag.span(class: "icon-deleted user-deleted")
      elsif comment.user.organization?
        special_avatar("avatar_collective.png", class: "avatar")
      else
        render Shared::AvatarComponent.new(comment.user, size: 32)
      end
    end

    def special_avatar(image_name, options = {})
      image_tag(image_name, { size: 32, alt: "" }.merge(options))
    end
end
