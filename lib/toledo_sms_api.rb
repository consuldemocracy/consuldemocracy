require 'open-uri'
require_dependency Rails.root.join('lib', 'sms_api').to_s

# Custom Ayto.Toledo SMS service implementation.
# SOAP
class ToledoSMSApi
  attr_accessor :client

  def initialize
    ssl_verification_mode = Rails.application.secrets.sms_ssl_verification
    ssl_verification_mode ||= :peer

    @client = Savon.client(wsdl: url,
                           ssl_verify_mode: ssl_verification_mode.to_sym,
                           convert_request_keys_to: :camelcase)
  end

  def url
    return '' unless end_point_available?
    Rails.root.join(Rails.application.secrets.sms_wsdl_path).to_s
  end

  def authorization
    Base64.encode64("#{Rails.application.secrets.sms_username}:#{Rails.application.secrets.sms_password}")
  end

  def sms_deliver(phone, code)
    return stubbed_response unless end_point_available?

    response = client.call(:sms_text_submit, message: request(phone, code))
    success?(response)
  end

  def request(phone, code)
    {
      version: Rails.application.secrets.sms_api_version,
      authorization:  authorization,
      sender: Rails.application.secrets.sms_api_sender,
      recipients: [{ to: phone }],
      SMSText: I18n.t('verification.sms.message_payload', code: code)
    }
  end

  def success?(response)
    response.body[:submit_res][:status][:status_text] == 'Success'
  end

  def end_point_available?
    Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
  end

  def stubbed_response
    { submit_res: { version: '1.0',
                    message_id: 'vasadpt1-is@3090@20171025162450455@02012397',
                    status: { status_code: '1000',
                             status_text: 'Success',
                             details: 'Request processed succesfully'
                            }
                  }
    }
  end

  def stubbed_invalid_response
    { submit_res: { version: '1.0',
                    status: { status_code: '4000',
                              status_text: 'Error',
                              details: 'Error'
                            }
                  }
    }
  end
end
