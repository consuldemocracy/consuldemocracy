class Poll
  class Nvote < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :user
  belongs_to :poll

  validates :user_id, :poll_id, :voter_hash, presence: true
  validates :voter_hash, uniqueness: {scope: :user_id}

  before_validation :save_voter_hash, on: :create

  def generate_voter_hash
    Digest::SHA256.hexdigest("#{Rails.application.secrets.secret_key_base}:#{self.user_id}:#{self.poll_id}:#{self.nvotes_poll_id}")
  end

  def generate_message
    "#{self.voter_hash}:AuthEvent:#{self.nvotes_poll_id}:vote:#{Time.now.to_i}"
  end

  def generate_hash(message)
    key = self.poll.server_shared_key
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new('sha256'), key, message)
  end

  def nvotes_poll_id
    self.poll.nvotes_poll_id
  end

  def url
    key = self.poll.server_shared_key
    message =  self.generate_message
    hash = self.generate_hash message
    "#{self.poll.server_url}booth/#{self.nvotes_poll_id}/vote/#{hash}/#{message}"
  end

  private

    def save_voter_hash
      if self.poll and self.user
        self.update_attribute(:nvotes_poll_id, self.poll.nvotes_poll_id)
        self.update_attribute(:voter_hash, generate_voter_hash)
      else
        self.errors.add(:voter_hash, "No se pudo generar")
      end
    end

  end
end