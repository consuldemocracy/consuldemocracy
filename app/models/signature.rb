class Signature < ApplicationRecord
  belongs_to :signature_sheet
  belongs_to :user

  validates :document_number, presence: true
  validates :date_of_birth, presence: true, if: -> { Setting.force_presence_date_of_birth? }
  validates :postal_code, presence: true, if: -> { Setting.force_presence_postal_code? }
  validates :signature_sheet, presence: true

  normalizes :document_number, with: DocumentNumberNormalizer

  scope :verified,   -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  delegate :signable, to: :signature_sheet

  def verify
    document_owner = User.with_hidden.find_by(document_number: document_number)

    if document_owner.present?
      assign_user_and_vote(user: document_owner)
    else
      response, document_type = census_response_and_document_type

      if response
        assign_user_and_vote(user: create_user(response, document_type))
      end
    end
  end

  def assign_vote_to_user
    if signable.is_a? Budget::Investment
      user.with_lock do
        if [nil, :no_selecting_allowed].include?(signable.reason_for_not_being_selectable_by(user))
          signable.vote_by(voter: user, vote: "yes")
          assign_signature_to_vote
        end
      end
    else
      signable.register_vote(user, "yes")
      assign_signature_to_vote
    end
  end

  def assign_signature_to_vote
    vote = Vote.find_by(votable: signable, voter: user)
    vote&.update!(signature: self)
  end

  def create_user(census_response, document_type)
    User.create_from_census_response!(census_response,
                                      document_number: document_number,
                                      document_type: document_type,
                                      created_from_signature: true)
  end

  def document_types
    %w[1 2 3 4]
  end

  private

    def census_response_and_document_type
      document_types.each do |document_type|
        response = CensusCaller.new.call(document_type, document_number, date_of_birth, postal_code)
        return [response, document_type] if response.valid?
      end

      nil
    end

    def assign_user_and_vote(user:)
      transaction do
        update(user: user, verified: true)
        assign_vote_to_user
      end
    end
end
