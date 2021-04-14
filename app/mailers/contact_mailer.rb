class ContactMailer < ApplicationMailer
    def contact_send(params)
        @parameters=params
        mail(to:'innconsul@grupoinnovaris.com', subject:@parameters[:subject])
    end
end
