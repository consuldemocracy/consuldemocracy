Dir["./spec/support/common_actions/*.rb"].each { |f| require f }

module CommonActions
  include Budgets
  include Comments
  include Debates
  include Emails
  include Notifications
  include Polls
  include Proposals
  include Tags
  include Users
  include Verifications
  include Votes

  def sign_up_as_organization(email="organization@consul.dev", password='thepeoples')
    visit new_organization_registration_path

    fill_in 'user_organization_attributes_name',  with: 'Greenpeace'
    fill_in 'user_organization_attributes_responsible_name', with: 'Dorothy Stowe'
    fill_in 'user_email',                         with: 'green@peace.com'
    fill_in 'user_password',                      with: 'greenpeace'
    fill_in 'user_password_confirmation',         with: 'greenpeace'
    check 'user_terms_of_service'

    click_button 'Register'
  end

  def fill_in_signup_form(email='manuela@consul.dev', password='judgementday')
    fill_in 'user_username',              with: "Manuela Carmena #{rand(99999)}"
    fill_in 'user_email',                 with: email
    fill_in 'user_password',              with: password
    fill_in 'user_password_confirmation', with: password
    check 'user_terms_of_service'
  end

  def login_as_authenticated_manager
    expected_response = {login: login, user_key: user_key, date: date}.with_indifferent_access
    login, user_key, date = "JJB042", "31415926", Time.current.strftime("%Y%m%d%H%M%S")
    allow_any_instance_of(ManagerAuthenticator).to receive(:auth).and_return(expected_response)
    visit management_sign_in_path(login: login, clave_usuario: user_key, fecha_conexion: date)
  end

  def fill_in_proposal
    fill_in 'proposal_title', with: 'Help refugees'
    fill_in 'proposal_summary', with: 'In summary what we want is...'
    fill_in 'proposal_description', with: 'This is very important because...'
    fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
    fill_in 'proposal_video_url', with: 'https://www.youtube.com/watch?v=yPQfcG-eimk'
    fill_in 'proposal_responsible_name', with: 'Isabel Garcia'
    check 'proposal_terms_of_service'
  end

  def fill_in_debate
    fill_in 'debate_title', with: 'A title for a debate'
    fill_in 'debate_description', with: 'This is very important because...'
    check 'debate_terms_of_service'
  end

  def validate_officer
    allow_any_instance_of(Officing::BaseController).
    to receive(:verify_officer_assignment).and_return(true)
  end

  def set_officing_booth(booth=nil)
    booth = create(:poll_booth) if booth.blank?

    allow_any_instance_of(Officing::BaseController).
    to receive(:current_booth).and_return(booth)
  end

  def vote_for_poll(poll)
    expect(page).to have_content poll.name

    first(".opt.ng-binding").click

    click_button "Continuar"

    if poll.nvotes_poll_id == "128"
      expect(page).to have_content "La opción que seleccionaste es: Sí"
    elsif poll.nvotes_poll_id == "136"
      expect(page).to have_content "La opción que seleccionaste es: A"
    end

    click_button "Enviar el voto"

    expect(page).to have_content "Voto emitido con éxito"
  end

  def valid_authorization_hash(nvote)
    message = "1:AuthEvent:1:RegisterSuccessfulLogin:1"
    signature = Poll::Nvote.generate_hash(message)

    "khmac:///sha-256;#{signature}/#{message}"
  end

  def simulate_nvotes_callback(nvote, poll)
    message = "#{nvote.voter_hash}:AuthEvent:#{poll.nvotes_poll_id}:RegisterSuccessfulLogin:#{Time.now.to_i}"
    signature = Poll::Nvote.generate_hash(message)

    authorization_hash = "khmac:///sha-256;#{signature}/#{message}"

    page.driver.header 'Authorization', authorization_hash
    page.driver.header 'ACCEPT', "application/json"
    page.driver.post polls_nvotes_success_path
  end

  def use_digital_booth
    allow_any_instance_of(Officing::VotersController).
    to receive(:physical_booth?).and_return(false)
  end

  def use_physical_booth
    allow_any_instance_of(Officing::VotersController).
    to receive(:physical_booth?).and_return(true)
  end

  def expect_message_already_voted_in_another_geozone(geozone)
    expect(page).to have_content 'You have already supported other district proposals.'
    expect(page).to have_link(geozone.name, href: spending_proposals_path(geozone: geozone))
    expect(page).to have_selector('.in-favor a', visible: false)
  end

  def expect_message_insufficient_funds
    expect(page).to have_content "This proposal's price is more than the available amount left"
  end

  def expect_message_selecting_not_allowed
    expect(page).to have_content 'No Selecting Allowed'
    expect(page).not_to have_selector('.in-favor a')
  end

  def create_spending_proposal_for(*users)
    users.each do |user|
      create(:spending_proposal, :finished, :feasible, author: user)
    end
  end

  def create_vote_for(*users)
    sp = first_or_create_spending_spending_proposal
    users.each do |user|
      create(:vote, votable: sp, voter: user)
    end
  end

  def create_ballot_for(*users)
    sp = first_or_create_spending_spending_proposal
    users.each do |user|
      create(:ballot, spending_proposals: [sp], user: user)
    end
  end

  def create_delegation_for(*users)
    forum = create(:forum)
    users.each do |user|
      user.update(representative: forum)
    end
  end

  def first_or_create_spending_spending_proposal
    if SpendingProposal.any?
      return SpendingProposal.first
    else
      return create(:spending_proposal, :finished, :feasible)
    end
  end

  def send_user_invite
    visit new_management_user_invite_path

    fill_in "emails", with: "john@example.com, ana@example.com, isable@example.com"
    click_button "Send invitations"

    expect(page).to have_content "3 invitations have been sent."
  end

  def add_spending_proposal_to_ballot(spending_proposal)
    within("#spending_proposal_#{spending_proposal.id}") do
      find('.add a').click
      expect(page).to have_content "Remove"
    end
  end

  def csv_path_for(table)
    "system/api/#{table}.csv"
  end

  def remove_token_from_vote_link
    page.execute_script("$('.js-question-answer')[0]['href'] = $('.js-question-answer')[0]['href'].match(/.+?(?=token)/)[0] + 'token='")
  end

  def fill_in_admin_notification_form(options = {})
    select (options[:segment_recipient] || 'All users'), from: :admin_notification_segment_recipient
    fill_in :admin_notification_title, with: (options[:title] || 'This is the notification title')
    fill_in :admin_notification_body, with: (options[:body] || 'This is the notification body')
    fill_in :admin_notification_link, with: (options[:link] || 'https://www.decide.madrid.es/vota')
  end

end
