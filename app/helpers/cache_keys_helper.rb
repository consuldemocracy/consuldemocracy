module CacheKeysHelper
  def locale_and_user_status
    @cache_key_user ||= calculate_user_status
    "#{I18n.locale}/#{@cache_key_user}"
  end

  def calculate_user_status
    user_status = "user"

    if user_signed_in?
      user_status += ":signed"
      user_status += ":verified" if current_user.verified_at.present?
      user_status += ":org" if current_user.organization?
    else
      user_status += ":visitor"
    end

    user_status
  end
end