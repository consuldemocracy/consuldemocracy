require_dependency Rails.root.join('app', 'models', 'verification', 'management', 'managed_user').to_s

class Verification::Management::ManagedUser
  include ActiveModel::Model

  def self.find_organization_user(email)
    User.find_by_email(email)
  end

end
