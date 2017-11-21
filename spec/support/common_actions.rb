module CommonActions

  def sign_up(email = 'manuela@consul.dev', password = 'judgementday')
    visit '/'

    click_link 'Register'

    fill_in 'user_username',              with: "Manuela Carmena #{rand(99999)}"
    fill_in 'user_email',                 with: email
    fill_in 'user_password',              with: password
    fill_in 'user_password_confirmation', with: password
    check 'user_terms_of_service'

    click_button 'Register'
  end

  def login_through_form_as(user)
    visit root_path
    click_link 'Sign in'

    fill_in 'user_login', with: user.email
    fill_in 'user_password', with: user.password

    click_button 'Enter'
  end

  def login_through_form_as_officer(user)
    visit root_path
    click_link 'Sign in'

    fill_in 'user_login', with: user.email
    fill_in 'user_password', with: user.password

    click_button 'Enter'
    visit new_officing_residence_path
  end

  def login_as_authenticated_manager
    expected_response = {login: login, user_key: user_key, date: date}.with_indifferent_access
    login, user_key, date = "JJB042", "31415926", Time.current.strftime("%Y%m%d%H%M%S")
    allow_any_instance_of(ManagerAuthenticator).to receive(:auth).and_return(expected_response)
    visit management_sign_in_path(login: login, clave_usuario: user_key, fecha_conexion: date)
  end

  def login_as_manager
    manager = create(:manager)
    login_as(manager.user)
    visit management_sign_in_path
  end

  def login_managed_user(user)
    allow_any_instance_of(Management::BaseController).to receive(:managed_user).and_return(user)
  end

  def confirm_email
    body = ActionMailer::Base.deliveries.last.try(:body)
    expect(body).to be_present

    sent_token = /.*confirmation_token=(.*)".*/.match(body.to_s)[1]
    visit user_confirmation_path(confirmation_token: sent_token)

    expect(page).to have_content "Your account has been confirmed"
  end

  def reset_password
    create(:user, email: 'manuela@consul.dev')

    visit '/'
    click_link 'Sign in'
    click_link 'Forgotten your password?'

    fill_in 'user_email', with: 'manuela@consul.dev'
    click_button 'Send instructions'
  end

  def comment_on(commentable, user = nil)
    user ||= create(:user)

    login_as(user)
    commentable_path = commentable.is_a?(Proposal) ? proposal_path(commentable) : debate_path(commentable)
    visit commentable_path

    fill_in "comment-body-#{commentable.class.name.underscore}_#{commentable.id}", with: 'Have you thought about...?'
    click_button 'Publish comment'

    expect(page).to have_content 'Have you thought about...?'
  end

  def reply_to(original_user, manuela = nil)
    manuela ||= create(:user)

    debate  = create(:debate)
    comment = create(:comment, commentable: debate, user: original_user)

    login_as(manuela)
    visit debate_path(debate)

    click_link "Reply"
    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "comment-body-comment_#{comment.id}", with: 'It will be done next week.'
      click_button 'Publish reply'
    end
    expect(page).to have_content 'It will be done next week.'
  end

  def avatar(name)
    "img.initialjs-avatar[data-name='#{name}']"
  end

  # Used to fill ckeditor fields
  # @param [String] locator label text for the textarea or textarea id
  def fill_in_ckeditor(locator, params = {})
    # Find out ckeditor id at runtime using its label
    locator = find('label', text: locator)[:for] if page.has_css?('label', text: locator)
    # Fill the editor content
    page.execute_script <<-SCRIPT
        var ckeditor = CKEDITOR.instances.#{locator}
        ckeditor.setData('#{params[:with]}')
        ckeditor.focus()
        ckeditor.updateElement()
    SCRIPT
  end

  def error_message(resource_model = nil)
    resource_model ||= "(.*)"
    /\d errors? prevented this #{resource_model} from being saved:/
  end

  def expect_to_be_signed_in
    expect(find('.top-bar')).to have_content 'My account'
  end

  def expect_to_not_be_signed_in
    expect(find('.top-bar')).to_not have_content 'My account'
  end

  def select_date(values, selector)
    selector = selector[:from]
    day, month, year = values.split("-")
    select day,   from: "#{selector}_3i"
    select month, from: "#{selector}_2i"
    select year,  from: "#{selector}_1i"
  end

  def verify_residence
    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'
    check 'residence_terms_of_service'

    click_button 'Verify residence'
    expect(page).to have_content 'Residence verified'
  end

  def officing_verify_residence
    select 'DNI', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    fill_in 'residence_year_of_birth', with: "1980"

    click_button 'Validate document'

    expect(page).to have_content 'Document verified with Census'
  end

  def confirm_phone(user = nil)
    user ||= User.last

    fill_in 'sms_phone', with: "611111111"
    click_button 'Send'

    expect(page).to have_content 'Enter the confirmation code sent to you by text message'

    fill_in 'sms_confirmation_code', with: user.reload.sms_confirmation_code
    click_button 'Send'

    expect(page).to have_content 'Code correct'
  end

  def expect_message_you_need_to_sign_in
    expect(page).to have_content 'You must Sign in or Sign up to continue'
    expect(page).to have_selector('.in-favor', visible: false)
  end

  def expect_message_you_need_to_sign_in_to_vote_comments
    expect(page).to have_content 'You must Sign in or Sign up to vote'
    expect(page).to have_selector('.participation-allowed', visible: false)
    expect(page).to have_selector('.participation-not-allowed', visible: true)
  end

  def expect_message_to_many_anonymous_votes
    expect(page).to have_content 'Too many anonymous votes to admit vote'
    expect(page).to have_selector('.in-favor a', visible: false)
  end

  def expect_message_only_verified_can_vote_proposals
    expect(page).to have_content 'Only verified users can vote on proposals'
    expect(page).to have_selector('.in-favor', visible: false)
  end

  def expect_message_voting_not_allowed
    expect(page).to have_content 'Voting phase is closed'
    expect(page).to_not have_selector('.in-favor a')
  end

  def expect_message_selecting_not_allowed
    expect(page).to have_content 'No Selecting Allowed'
    expect(page).to_not have_selector('.in-favor a')
  end

  def expect_message_organizations_cannot_vote
    #expect(page).to have_content 'Organisations are not permitted to vote.'
    expect(page).to have_content 'Organization'
    expect(page).to have_selector('.in-favor a', visible: false)
  end

  def create_featured_proposals
    [create(:proposal, :with_confidence_score, cached_votes_up: 100),
     create(:proposal, :with_confidence_score, cached_votes_up: 90),
     create(:proposal, :with_confidence_score, cached_votes_up: 80)]
  end

  def create_featured_debates
    [create(:debate, :with_confidence_score, cached_votes_up: 100),
     create(:debate, :with_confidence_score, cached_votes_up: 90),
     create(:debate, :with_confidence_score, cached_votes_up: 80)]
  end

  def create_successful_proposals
    [create(:proposal, title: "Winter is coming", question: "Do you speak it?", cached_votes_up: Proposal.votes_needed_for_success + 100),
     create(:proposal, title: "Fire and blood", question: "You talking to me?", cached_votes_up: Proposal.votes_needed_for_success + 1)]
  end

  def create_archived_proposals
    months_to_archive_proposals = Setting["months_to_archive_proposals"].to_i
    [
      create(:proposal, title: "This is an expired proposal", created_at: months_to_archive_proposals.months.ago),
      create(:proposal, title: "This is an oldest expired proposal", created_at: (months_to_archive_proposals + 2).months.ago)
    ]
  end

  def tag_names(tag_cloud)
    tag_cloud.tags.map(&:name)
  end

  def create_proposal_notification(proposal)
    login_as(proposal.author)
    visit root_path

    click_link "My activity"

    within("#proposal_#{proposal.id}") do
      click_link "Send notification"
    end

    fill_in 'proposal_notification_title', with: "Thank you for supporting my proposal #{proposal.title}"
    fill_in 'proposal_notification_body', with: "Please share it with others so we can make it happen! #{proposal.summary}"
    click_button "Send message"

    expect(page).to have_content "Your message has been sent correctly."
    Notification.last
  end

  def create_direct_message(sender, receiver)
    login_as(sender)
    visit user_path(receiver)

    click_link "Send private message"

    expect(page).to have_content "Send private message to #{receiver.name}"

    fill_in 'direct_message_title', with: "Hey #{receiver.name}!"
    fill_in 'direct_message_body',  with: "How are you doing? This is #{sender.name}"

    click_button "Send message"

    expect(page).to have_content "You message has been sent successfully."
    DirectMessage.last
  end

  def expect_badge_for(resource_name, resource)
    within("##{resource_name}_#{resource.id}") do
      expect(page).to have_css ".label.round"
      expect(page).to have_content "Employee"
    end
  end

  def expect_no_badge_for(resource_name, resource)
    within("##{resource_name}_#{resource.id}") do
      expect(page).to_not have_css ".label.round"
      expect(page).to_not have_content "Employee"
    end
  end

  def add_to_ballot(budget_investment)
    within("#budget_investment_#{budget_investment.id}") do
      find('.add a').trigger('click')
      expect(page).to have_content "Remove"
    end
  end

  def vote_for_poll_via_web(poll, question, answer)
    visit poll_path(poll)

    within("#poll_question_#{question.id}_answers") do
      click_link answer.to_s
      expect(page).to_not have_link(answer.to_s)
    end
  end

  def vote_for_poll_via_booth
    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content poll.name

    first(:button, "Confirm vote").click
    expect(page).to have_content "Vote introduced!"

    expect(Poll::Voter.count).to eq(1)
  end

end
