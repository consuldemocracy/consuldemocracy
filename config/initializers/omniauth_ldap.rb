require "omniauth"

OmniAuth::Strategies::LDAP.class_eval do
  option :url, Rails.application.secrets.ldap_new_path

  def request_phase
    OmniAuth::LDAP::Adaptor.validate @options
    redirect options[:url]
  end

  def callback_phase
    @adaptor = OmniAuth::LDAP::Adaptor.new @options

    return fail!(:missing_credentials) if missing_credentials?
    begin
      @ldap_user_info = @adaptor.bind_as(:filter => filter(@adaptor), :size => 1, :password => request['password'])

      if !@ldap_user_info
        @user_info = {}
        @user_info['invalid_credentials'] = true
      else
        @user_info = self.class.map_user(@@config, @ldap_user_info)
      end

      super
    rescue Exception => e
      return fail!(:ldap_error, e)
    end
  end
end
