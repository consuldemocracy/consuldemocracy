class Poll
  class LetterOfficerLog < ActiveRecord::Base
    VALID_MESSAGES = { ok: "Document OK",
                       has_voted: "Document already voted",
                       census_failed: "Document not in census" }

    belongs_to :user

    validates :document_number, presence: true
    validates :message, presence: true
    validates :message, inclusion: {in: VALID_MESSAGES.values}
    validates :user_id, presence: true

    def self.log(user, document, msg)
      ::Poll::LetterOfficerLog.create(user: user, document_number: document, message: VALID_MESSAGES[msg])
    end

  end
end

