require_dependency Rails.root.join("app", "models", "proposal").to_s

class Proposal < ApplicationRecord
    # Queremos evitar que los usuarios autenticados de participacion sean rechequeados
    def skip_user_verification?
       author.origin_participacion || Setting["feature.user.skip_verification"].present?
    end
end
