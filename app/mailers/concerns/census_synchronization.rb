module CensusSynchronization
  extend ActiveSupport::Concern

  class_methods do


    def email_removed_from_census(user, recipient, document_type)
      @user = user
      @recipient = recipient
      @document_type = document_type

      with_user(user) do
        mail(to: @recipient, subject: t('mailers.email_removed_from_census.subject', site_name: Setting['org_name']))
      end
    end

  end
end
