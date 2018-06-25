require_dependency Rails.root.join('app', 'helpers', 'admin_helper').to_s

module Custom::AdminHelper

  def menu_profiles?
    %w[administrators organizations officials moderators valuators managers users activity animators].include?(controller_name)
  end

end