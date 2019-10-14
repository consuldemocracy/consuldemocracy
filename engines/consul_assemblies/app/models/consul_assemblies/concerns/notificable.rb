module ConsulAssemblies
  module Concerns
    module  Notificable
      extend ActiveSupport::Concern

        def notify_to_followers
          followers.find_each do |follower|
            Mailer.send_mail_to_followers(self, follower).deliver_later
          end
        end
    end
  end
end
