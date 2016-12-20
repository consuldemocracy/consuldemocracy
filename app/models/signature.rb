class Signature < ActiveRecord::Base
  belongs_to :signature_sheet
  belongs_to :user

  validate :in_census
  validate :not_already_voted

  scope :valid,   -> { where(status: 'verified') }
  scope :invalid, -> { where.not(status: 'verified') }

  def in_census
    return true if user_exists?
    errors.add(:document_number, :not_in_census) unless in_census?
  end

  def not_already_voted
    errors.add(:document_number, :already_voted) if already_voted?
  end

  def verify
    if valid?
      assign_vote
      update_attribute(:status, 'verified')
    else
      error = errors.messages[:document_number].first
      update_attribute(:status, error)
    end
  end

  private

    def assign_vote
      if user_exists?
        assign_vote_to_user
      else
        create_user
        assign_vote_to_user
      end
    end

    def assign_vote_to_user
      signable.register_vote(user, "yes", "signature")
      #Vote.create(votable: signable, voter: user, signature: self)
    end

    def user_exists?
      user = User.where(document_number: document_number).exists?
    end

    def create_user
      user = User.where(document_number: document_number, erased_at: Time.now).create
    end

    def in_census?
      document_types.any? do |document_type|
        CensusApi.new.call(document_type, document_number).valid?
      end
    end

    def already_voted?
      signable.voters.where(document_number: document_number).exists?
    end

    def signable
      signature_sheet.signable
    end

    def document_types
      %w(1 2 3 4)
    end

end