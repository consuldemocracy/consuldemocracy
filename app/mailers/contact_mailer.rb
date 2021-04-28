class ContactMailer < ApplicationMailer
    def contact_send(params)
        @parameters=params
        mail(to:'innconsul@grupoinnovaris.com', subject:@parameters[:subject])
    end

    def phone_contact(params)
        @parameters=params
        @country=params[:contact_mailer]
        @date=params[:date]
        mail(to:'innconsul@grupoinnovaris.com', subject:'Te llamamos')
    end
end
