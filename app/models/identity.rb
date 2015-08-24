class Identity < ActiveRecord::Base
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  def self.find_for_oauth(auth)
    where(uid: auth.uid, provider: auth.provider).first_or_create
  end
end
