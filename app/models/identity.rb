class Identity < ActiveRecord::Base
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  def self.first_or_create_from_oauth(auth)
    where(uid: auth.uid, provider: auth.provider).first_or_create
  end

  def update_user(new_user)
    return unless user != new_user

    self.user = new_user
    save!
  end
end
