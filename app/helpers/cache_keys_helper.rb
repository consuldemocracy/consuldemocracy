module CacheKeysHelper
  def locale_and_user_status
    @cache_key_user ||= calculate_user_status
    "#{I18n.locale}/user:#{@cache_key_user}"
  end

  def calculate_user_status
    user_status = if user_signed_in? && current_user.verified_at.present?
      "verified"
    elsif user_signed_in?
      "signed"
    else
      "visitor"
    end
  end
end