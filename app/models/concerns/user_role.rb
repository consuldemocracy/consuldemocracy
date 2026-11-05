module UserRole
  extend ActiveSupport::Concern

  included do
    belongs_to :user, touch: true
    delegate :name, :email, :name_and_email, to: :user

    validates :user_id, presence: true, uniqueness: true
  end

  class_methods do
    def find_or_create_by_user_id(user_id)
      User.find(user_id).with_lock do
        find_by(user_id: user_id) || create!(user_id: user_id)
      end
    end
  end
end
