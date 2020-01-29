class Dashboard::Mailer < ApplicationMailer
  layout "mailer"
  after_action :check_deliverability, except: [:forward]

  def forward(proposal)
    @proposal = proposal
    mail to: proposal.author.email, subject: proposal.title
  end

  def new_actions_notification_rake_published(proposal, new_actions_ids)
    @proposal = proposal
    @new_actions = get_new_actions(new_actions_ids)
    mail to: proposal.author.email,
         subject: I18n.t("mailers.new_actions_notification_rake_published.subject")
  end

  def new_actions_notification_rake_created(proposal, new_actions_ids)
    @proposal = proposal
    @new_actions = get_new_actions(new_actions_ids)
    mail to: proposal.author.email,
         subject: I18n.t("mailers.new_actions_notification_rake_created.subject")
  end

  def new_actions_notification_on_create(proposal)
    @proposal = proposal
    mail to: proposal.author.email,
         subject: I18n.t("mailers.new_actions_notification_on_create.subject")
  end

  def new_actions_notification_on_published(proposal, new_actions_ids)
    @proposal = proposal
    @new_actions = get_new_actions(new_actions_ids)
    mail to: proposal.author.email,
         subject: I18n.t("mailers.new_actions_notification_on_published.subject")
  end

  private

    def get_new_actions(new_actions_ids)
      Dashboard::Action.where(id: new_actions_ids)
    end

    def check_deliverability
      mail.perform_deliveries = false unless Setting["feature.dashboard.notification_emails"]
    end
end
