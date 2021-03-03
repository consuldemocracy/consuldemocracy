require_dependency Rails.root.join("app", "models", "setting").to_s

class Setting
  class << self
    alias_method :consul_defaults, :defaults

    def defaults
      response_path = "get_habita_datos_response.get_habita_datos_result"
      residence_path = "datos_vivienda.item"
      citizen_path = "datos_habitante.item"
      consul_defaults.merge({
        "mailer_from_address": "participa@lorca.es",
        "remote_census.general.endpoint": Rails.application.secrets.census_api_end_point,
        "remote_census.request.date_of_birth": nil,
        "remote_census.request.document_number": "request.documento",
        "remote_census.request.document_type": "request.tipo_documento",
        "remote_census.request.method_name": "get_habita_datos",
        "remote_census.request.postal_code": nil,
        "remote_census.request.structure": %Q({ "request":
          {
            "codigo_institucion": "#{Rails.application.secrets.census_api_institution_code}",
            "codigo_portal": "#{Rails.application.secrets.census_api_portal_name}",
            "codigo_usuario": "#{Rails.application.secrets.census_api_user_code}",
            "documento": "null",
            "tipo_documento": "null",
            "codigo_idioma": 102,
            "nivel": 3
          }
        }),
        "remote_census.response.date_of_birth": "#{response_path}.#{citizen_path}.fecha_nacimiento_string",
        "remote_census.response.district": "#{response_path}.#{residence_path}.codigo_distrito",
        "remote_census.response.postal_code": "#{response_path}.#{residence_path}.codigo_postal",
        "remote_census.response.gender": "#{response_path}.#{citizen_path}.descripcion_sexo",
        "remote_census.response.name": "#{response_path}.#{citizen_path}.nombre",
        "remote_census.response.surname": "#{response_path}.#{citizen_path}.apellido1",
        "remote_census.response.valid": "#{response_path}.#{citizen_path}"
      })
    end
  end
end
