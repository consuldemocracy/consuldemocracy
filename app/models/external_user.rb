class ExternalUser < ApplicationRecord
  def get(uuid)
    # Recuperamos el usuario por identificdor
    @eu = ExternalUser.where(uuid: uuid, created_at: 3.minutes.ago).find(1);

    # Eliminamos este registro.
    unless @eu == nil
      @eu.delete
    end

    # Eliminamos registros obsoletos de usuarios
    ExternalUser.where(created_at: 3.minutes.since).delete_all
    return @eu
  end
end
