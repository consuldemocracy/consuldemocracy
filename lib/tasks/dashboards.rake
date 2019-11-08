namespace :dashboards do
  desc "Send to user notifications from new actions availability on dashboard"
  task send_notifications: :environment do
    Proposal.not_archived.each do |proposal|
      new_actions_ids = Dashboard::Action.detect_new_actions_since(Date.yesterday, proposal)

      if new_actions_ids.present?
        if proposal.published?
          Dashboard::Mailer.delay.new_actions_notification_rake_published(proposal,
                                                                    new_actions_ids)
        else
          Dashboard::Mailer.delay.new_actions_notification_rake_created(proposal,
                                                                  new_actions_ids)
        end
      end
    end
  end
end
