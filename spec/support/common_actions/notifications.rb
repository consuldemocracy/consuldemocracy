module Notifications
  def click_notifications_icon
    find("#notifications a").click
  end

  def model_name(described_class)
    return :proposal_notification if described_class == ProposalNotification

    described_class.name.gsub("::", "_").downcase.to_sym
  end

  def comment_body(resource)
    "comment-body-#{resource.class.name.parameterize('_').to_sym}_#{resource.id}"
  end

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

  def path_for(resource)
    nested_path_for(resource) || url_for([resource, only_path: true])
  end

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

  def error_message(resource_model = nil)
    resource_model ||= "(.*)"
    field_check_message = 'Please check the marked fields to know how to correct them:'
    /\d errors? prevented this #{resource_model} from being saved. #{field_check_message}/
  end

  def fill_in_admin_notification_form(options = {})
    select (options[:segment_recipient] || 'All users'), from: :admin_notification_segment_recipient
    fill_in :admin_notification_title, with: (options[:title] || 'This is the notification title')
    fill_in :admin_notification_body, with: (options[:body] || 'This is the notification body')
    fill_in :admin_notification_link, with: (options[:link] || 'https://www.decide.madrid.es/vota')
  end
end
