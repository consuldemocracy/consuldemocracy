module CommonActions

  def sign_up(email='manuela@madrid.es', password='judgementday')
    visit '/'
    click_link 'Sign up'

    fill_in 'user_username',              with: "Manuela Carmena #{rand(99999)}"
    fill_in 'user_email',                 with: email
    fill_in 'user_password',              with: password
    fill_in 'user_password_confirmation', with: password
    fill_in 'user_captcha',               with: correct_captcha_text
    check 'user_terms_of_service'

    click_button 'Sign up'
  end

  def confirm_email
    expect(page).to have_content "A message with a confirmation link has been sent to your email address."

    sent_token = /.*confirmation_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit user_confirmation_path(confirmation_token: sent_token)

    expect(page).to have_content "Your email address has been successfully confirmed"
  end

  def reset_password
    create(:user, email: 'manuela@madrid.es')

    visit '/'
    click_link 'Log in'
    click_link 'Forgot your password?'

    fill_in 'user_email', with: 'manuela@madrid.es'
    click_button 'Send me reset password instructions'
  end

  def comment_on(debate)
    user = create(:user)

    login_as(user)
    visit debate_path(debate)

    fill_in "comment-body-debate_#{debate.id}", with: 'Have you thought about...?'
    click_button 'Publish comment'

    expect(page).to have_content 'Have you thought about...?'
  end

  def reply_to(user)
    manuela = create(:user)
    debate  = create(:debate)
    comment = create(:comment, commentable: debate, user: user)

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
    /\d errors? prohibited this (.*) from being saved:/
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
    select 'Spanish ID', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'
    check 'residence_terms_of_service'

    click_button 'Verify residence'
    expect(page).to have_content 'Residence verified'
  end
end
