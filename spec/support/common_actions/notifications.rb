module Notifications
  # spec/features/notifications_spec.rb
  def click_notifications_icon
    find("#notifications a").click
  end

  # spec/models/proposal_notification_spec.rb
  # spec/shared/features/followable.rb
  # spec/shared/features/notifiable_in_app.rb
  # spec/shared/features/relationable.rb
  # spec/shared/models/map_validations.rb
  # spec/shared/models/notifiable.rb
  def model_name(described_class)
    return :proposal_notification if described_class == ProposalNotification

    described_class.name.gsub("::", "_").downcase.to_sym
  end

  # spec/shared/features/notifiable_in_app.rb
  def comment_body(resource)
    "comment-body-#{resource.class.name.parameterize('_').to_sym}_#{resource.id}"
  end

  # spec/features/emails_spec.rb
  # spec/features/proposal_notifications_spec.rb
  def create_proposal_notification(proposal)
    login_as(proposal.author)
    visit root_path

    click_link "My activity"

    within("#proposal_#{proposal.id}") do
      click_link "Send notification"
    end

    fill_in 'proposal_notification_title', with: "Thanks for supporting proposal: #{proposal.title}"
    fill_in 'proposal_notification_body', with: "Please share it with others! #{proposal.summary}"
    click_button "Send message"

    expect(page).to have_content "Your message has been sent correctly."
    Notification.last
  end

  # spec/shared/features/notifiable_in_app.rb
  def path_for(resource)
    nested_path_for(resource) || url_for([resource, only_path: true])
  end

  # Used locally by method 'path_for'
  def nested_path_for(resource)
    case resource.class.name
    when "Legislation::Question"
      legislation_process_question_path(resource.process, resource)
    when "Legislation::Proposal"
      legislation_process_proposal_path(resource.process, resource)
    when "Budget::Investment"
      budget_investment_path(resource.budget, resource)
    else
      false
    end
  end

  # spec/features/account_spec.rb
  # spec/features/admin/emails/newsletters_spec.rb
  # spec/features/admin/signature_sheets_spec.rb
  # spec/features/budgets/investments_spec.rb
  # spec/features/debates_spec.rb
  # spec/features/direct_messages_spec.rb
  # spec/features/organizations_spec.rb
  # spec/features/proposal_notifications_spec.rb
  # spec/features/proposals_spec.rb
  # spec/features/tags_spec.rb
  # spec/features/tags/budget_investments_spec.rb
  # spec/features/tags/debates_spec.rb
  # spec/features/tags/proposals_spec.rb
  # spec/features/users_auth_spec.rb
  # spec/features/verification/sms_spec.rb
  # spec/shared/models/document_validations.rb
  def error_message(resource_model = nil)
    resource_model ||= "(.*)"
    field_check_message = 'Please check the marked fields to know how to correct them:'
    /\d errors? prevented this #{resource_model} from being saved. #{field_check_message}/
  end
end
