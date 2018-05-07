module CustomHelper

  def user_genders_select_options
    User::GENDERS.map { |g| [ t("users.gender.#{g}"), g ] }
  end

end
