include ApplicationHelper
class RutApi

  def call(document_number)
    abre_log
    validate(document_number) if authenticate
  end

  def initialize()
    abre_log
    @auth = {:email => Rails.application.secrets.rut_api_user, :password => Rails.application.secrets.rut_api_password}
    @token = ''
  end

  def authenticate()
    abre_log
    abre_log Rails.application.secrets.rut_api_end_point
    begin
      response = HTTParty.post(Rails.application.secrets.rut_api_end_point + '/authenticate', headers: {"Content-Type" => "application/json"}, :body => @auth.to_json)
      @token = response['auth_token']
    rescue HTTParty::Error
      abre_log 'HTTParty exception'
    rescue StandardError => e
      abre_log 'StandardError exception'=> e
      abre_log e
      # @token = ''
    end
    @token == '' ? false : true
  end


  def validate(document_number)
    abre_log
    response = HTTParty.post(Rails.application.secrets.rut_api_end_point + '/validate', headers: {"Authorization" => @token, "Content-Type" => "application/json"}, :body => {:rut => document_number}.to_json)
    p response
    response['validated']
  end

end

# rut_api = RutApi.new(config['email'], config['password'])
# pp twitter.timeline
