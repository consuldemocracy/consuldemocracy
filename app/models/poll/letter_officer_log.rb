class Poll
  class LetterOfficerLog < ApplicationRecord
    VALID_MESSAGES = { ok: "Voto VÁLIDO",
                       has_voted: "Voto REFORMULADO",
                       census_failed: "Voto NO VÁLIDO",
                       no_postal_code: "Verifica EL NOMBRE" }

    belongs_to :user

    validates :message, presence: true
    validates :message, inclusion: {in: VALID_MESSAGES.values}
    validates :user_id, presence: true

    def self.log(user, document, postal_code, msg, census_name=nil, census_postal_code=nil)
      attrs = {
        user: user,
        document_number: document,
        postal_code: postal_code,
        message: VALID_MESSAGES[msg],
        census_name: census_name,
        census_postal_code: census_postal_code
      }
      ::Poll::LetterOfficerLog.create(attrs)
    end

  end
end

