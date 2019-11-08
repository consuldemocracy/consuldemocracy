module CacheKeysHelper
  def locale_and_user_status(authorable = nil)
    @cache_key_user ||= calculate_user_status(authorable)
    "#{I18n.locale}/#{@cache_key_user}"
  end

  def calculate_user_status(authorable = nil)
    user_status = "user"

    if user_signed_in?
      user_status += ":signed"
      user_status += ":verified" if current_user.level_two_or_three_verified?
      user_status += ":org" if current_user.organization?
      user_status += ":admin" if current_user.administrator?
      user_status += ":moderator" if current_user.moderator?
      user_status += ":author" if authorable && authorable.author == current_user
    else
      user_status += ":visitor"
    end

    user_status
  end

  # when commentable id and type are used but no need to update cache on updated_at changes
  def commentable_cache_key(commentable)
    "#{commentable.class.name}-#{commentable.id}"
  end
end
