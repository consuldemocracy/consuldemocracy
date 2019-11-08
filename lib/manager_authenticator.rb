class ManagerAuthenticator
  def initialize(data = {})
    @manager = { login: data[:login], user_key: data[:clave_usuario], date: data[:fecha_conexion] }.with_indifferent_access
  end

  def auth
    return false unless [@manager[:login], @manager[:user_key], @manager[:date]].all?(&:present?)
    return @manager if manager_exists? && application_authorized?

    false
  end

  private

    def manager_exists?
      response = client.call(:get_status_user_data, message: { ub: { user_key: @manager[:user_key], date: @manager[:date] }}).body
      parsed_response = parser.parse((response[:get_status_user_data_response][:get_status_user_data_return]))
      @manager[:login] == parsed_response["USUARIO"]["LOGIN"]
    rescue
      false
    end

    def application_authorized?
      response = client.call(:get_applications_user_list, message: { ub: { user_key: @manager[:user_key] }}).body
      parsed_response = parser.parse((response[:get_applications_user_list_response][:get_applications_user_list_return]))
      aplication_value = parsed_response["APLICACIONES"]["APLICACION"]
      # aplication_value from UWEB can be an array of hashes or a hash
      aplication_value.include?("CLAVE_APLICACION" => application_key) || aplication_value["CLAVE_APLICACION"] == application_key
    rescue
      false
    end

    def client
      @client ||= Savon.client(wsdl: Rails.application.secrets.managers_url)
    end

    def parser
      @parser ||= Nori.new
    end

    def application_key
      Rails.application.secrets.managers_application_key.to_s
    end
end
