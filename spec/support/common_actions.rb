module CommonActions

  def sign_up
    visit '/'
    click_link 'Sign up'

    fill_in 'user_username',              with: 'Manuela Carmena'
    fill_in 'user_email',                 with: 'manuela@madrid.es'
    fill_in 'user_password',              with: 'judgementday'
    fill_in 'user_password_confirmation', with: 'judgementday'
    fill_in 'user_captcha',               with: correct_captcha_text

    click_button 'Sign up'
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
    user2 = create(:user)

    login_as(user2)
    visit debate_path(debate)

    fill_in 'comment_body', with: 'Have you thought about...?'
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
      fill_in 'comment_body', with: 'It will be done next week.'
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
end
