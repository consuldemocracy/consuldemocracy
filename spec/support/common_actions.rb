module CommonActions

  def sign_up(email='manuela@madrid.es', password='judgementday')
    visit '/'

    click_link 'Register'

    fill_in 'user_username',              with: "Manuela Carmena #{rand(99999)}"
    fill_in 'user_email',                 with: email
    fill_in 'user_password',              with: password
    fill_in 'user_password_confirmation', with: password
    fill_in 'user_captcha',               with: correct_captcha_text
    check 'user_terms_of_service'

    click_button 'Register'
  end

  def login_through_form_as(user)
    visit root_path
    click_link 'Sign in'

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password

    click_button 'Enter'
  end

  def login_as_manager
    login, user_key, date = "JJB042", "31415926", Time.now.strftime("%Y%m%d%H%M%S")
    allow_any_instance_of(ManagerAuthenticator).to receive(:auth).and_return({login: login, user_key: user_key, date: date})
    visit management_sign_in_path(login: login, clave_usuario: user_key, fecha_conexion: date)
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
    create(:user, email: 'manuela@madrid.es')

    visit '/'
    click_link 'Sign in'
    click_link 'Forgotten your password?'

    fill_in 'user_email', with: 'manuela@madrid.es'
    click_button 'Send instructions'
  end

  def comment_on(commentable, user = nil)
    user ||= create(:user)

    login_as(user)
    commentable_path = commentable.is_a?(Proposal) ? proposal_path(commentable) : debate_path(commentable)
    visit commentable_path

    fill_in "comment-body-#{commentable.class.name.downcase}_#{commentable.id}", with: 'Have you thought about...?'
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

  def correct_captcha_text
    SimpleCaptcha::SimpleCaptchaData.last.value
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

  def error_message
    /\d errors? prevented this (.*) from being saved:/
  end

  def expect_to_be_signed_in
    expect(find('.top-bar')).to have_content 'My account'
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

  def confirm_phone
    fill_in 'sms_phone', with: "611111111"
    click_button 'Send'

    expect(page).to have_content 'Enter the confirmation code sent to you by text message'

    user = User.last.reload
    fill_in 'sms_confirmation_code', with: user.sms_confirmation_code
    click_button 'Send'

    expect(page).to have_content 'Code correct'
  end

  def expect_message_you_need_to_sign_in
    expect(page).to have_content 'You must Sign in or Sign up to continue'
    expect(page).to have_selector('.in-favor a', visible: false)
  end

  def expect_message_to_many_anonymous_votes
    expect(page).to have_content 'Too many anonymous votes to admit vote'
    expect(page).to have_selector('.in-favor a', visible: false)
  end

  def expect_message_only_verified_can_vote_proposals
    expect(page).to have_content 'Only verified users can vote on proposals'
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

  def tag_names(tag_cloud)
    tag_cloud.tags.map(&:name)
  end

end
