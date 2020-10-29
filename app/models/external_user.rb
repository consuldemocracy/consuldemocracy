class ExternalUser < ApplicationRecord
  def self.get(uuid)
    # Recuperamos el usuario por UUID seguro y fecha de creacion
    eu = nil
    begin
      eu = ExternalUser.find_by("uuid = ? AND created_at >= ?",uuid, 3.minutes.ago)
    rescue ActiveRecord::RecordNotFound
    end

    # Eliminamos este registro.
    unless eu == nil
      eu.destroy
    end

    # Eliminamos registros obsoletos de usuarios
    ExternalUser.where("created_at <= ?", 3.minutes.ago).destroy_all
    return eu
  end
end
