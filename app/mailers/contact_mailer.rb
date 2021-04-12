class ContactMailer < ApplicationMailer
    default from: proc { "#{Setting["mailer_from_name"]} <#{Setting["mailer_from_address"]}>" }

    def contact_send(params)
        @parameters=params
        mail(to:'innconsul@grupoinnovaris.com', subject:@parameters[:subject])
    end
end
