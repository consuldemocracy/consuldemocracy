class Poll
  class Nvote < ApplicationRecord

  acts_as_paranoid

  belongs_to :user
  belongs_to :poll
  belongs_to :officer_assignment
  belongs_to :booth_assignment

  validates :user_id, :poll_id, :voter_hash, presence: true
  validates :voter_hash, uniqueness: {scope: :user_id}

  before_validation :save_voter_hash, on: :create
  before_validation :set_denormalized_booth_assignment_id

  def generate_voter_hash
    Digest::SHA256.hexdigest("#{Rails.application.secrets.secret_key_base}:#{self.user_id}:#{self.poll_id}:#{self.nvotes_poll_id}")
  end

  def generate_message
    "#{self.voter_hash}:AuthEvent:#{self.nvotes_poll_id}:vote:#{Time.now.to_i}"
  end

  def self.generate_hash(message)
    key = Poll.server_shared_key
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new('sha256'), key, message)
  end

  def nvotes_poll_id
    self.poll.nvotes_poll_id
  end

  def url
    key = Poll.server_shared_key
    message =  self.generate_message
    hash = Poll::Nvote.generate_hash(message)
    "#{Poll.server_url}booth/#{self.nvotes_poll_id}/vote/#{hash}/#{message}"
  end

  def self.store_voter(authorization_hash)
    authorization_hash.gsub!("khmac:///sha-256;", "")
    signature, message = authorization_hash.split("/")

    if signature_valid?(signature, message)
      nvote, poll = parse_authorization(message)
      Poll::Voter.create(user: nvote.user,
                         poll: poll,
                         officer_assignment: nvote.officer_assignment,
                         booth_assignment: nvote.booth_assignment,
                         origin: "web")
    end
  end

  def self.signature_valid?(signature, message)
    signature == generate_hash(message)
  end

  def self.parse_authorization(message)
    message_parts = message.split(":")
    voter_hash = message_parts[0]
    nvotes_poll_id = message_parts[2]

    nvote = Poll::Nvote.where(voter_hash: voter_hash).first
    poll = Poll.where(nvotes_poll_id: nvotes_poll_id).first

    return nvote, poll
  end

  private

    def set_denormalized_booth_assignment_id
      self.booth_assignment_id ||= officer_assignment.try(:booth_assignment_id)
    end

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
