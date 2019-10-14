require "xmlrpc/client"

class SMSApiCustom
  attr_accessor :client

  def initialize
    @client = XMLRPC::Client.new(server_api_host, server_api_path, server_api_port)
  end

  def server_api_host
    return "" unless end_point_available?
    return Rails.application.secrets.sms_server_host
  end

  def server_api_path
    return "" unless end_point_available?
    return Rails.application.secrets.sms_server_path
  end

  def server_api_port
    return "" unless end_point_available?
    return Rails.application.secrets.sms_server_port.to_i
  end

  def server_api_user
    Rails.application.secrets.sms_username
  end

  def server_api_passwd
    Rails.application.secrets.sms_password
  end

  def sms_sender_name
    Rails.application.secrets.sms_server_name
  end

  def server_api_send_action
    "MensajeriaNegocios.enviarSMS"
  end

  def sms_deliver(phone, code)
    return stubbed_response unless end_point_available?
    payload = [sms_as_param(phone, code)]

    response = @client.call(
      server_api_send_action,
      server_api_user,
      server_api_passwd,
      payload)

    success?(response)
  end

  def ballot_confirm_sms_deliver(phone, message)
    return stubbed_response unless end_point_available?
    payload = [sms_as_param_with_message(phone, message)]

    response = @client.call(
        server_api_send_action,
        server_api_user,
        server_api_passwd,
        payload)

    success?(response)
  end

  def sms_as_param(phone, code)
    [phone, I18n.t('sms_body', code: code), sms_sender_name]
  end

  def sms_as_param_with_message(phone, message)
    [phone, message, sms_sender_name]
  end

  def success?(response)
    response == [0] #XML-RPC with one message
  end

  def end_point_available?
    Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
  end

  def stubbed_response
    [0] # Success 
  end

end
