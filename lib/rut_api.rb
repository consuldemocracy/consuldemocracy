class RutApi
  def initialize(u, p)
    @auth = {:email => u, :password => p}
    @token = ''
  end

  def authenticate()
    response = HTTParty.post(Rails.application.secrets.rut_api_end_point + '/authenticate', headers: {"Content-Type" => "application/json"}, :body => @auth.to_json)
    @token = response['auth_token']
    @token
  end


  def validate(document_number)
    response = HTTParty.post(Rails.application.secrets.rut_api_end_point + '/validate', headers: {"Authorization" => @token, "Content-Type" => "application/json"}, :body => {:rut => document_number}.to_json)
    response['validated']
  end

end

# rut_api = RutApi.new(config['email'], config['password'])
# pp twitter.timeline
