class Identity < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  def self.first_or_create_from_oauth(auth, &block)
    lock_id = Zlib.crc32("identities:#{auth.provider}:#{auth.uid}")
    sleep 0.01 until connection.get_advisory_lock(lock_id)

    begin
      identity = where(uid: auth.uid, provider: auth.provider).first_or_create!
      block&.call(identity)
      identity
    ensure
      connection.release_advisory_lock(lock_id)
    end
  end
end
