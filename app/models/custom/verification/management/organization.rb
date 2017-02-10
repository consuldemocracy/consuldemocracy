# require_dependency Rails.root.join('app', 'models', 'verification', 'management').to_s

class Verification::Management::Organization

  include ActiveModel::Model

  attr_accessor :email

  def user
    u = User.find_by_email(email)
    (u && u.organization?) ? u : nil
  end

end
