module UserRole
  extend ActiveSupport::Concern

  included do
    belongs_to :user, touch: true
    delegate :name, :email, :name_and_email, to: :user

    validates :user_id, presence: true, uniqueness: true
  end
end
