require 'rails_helper'

feature 'Tracking' do

  context 'User data' do

    context 'User ID' do

      scenario 'Anonymous' do
        visit "/"

        expect(page).not_to have_css("span[data-track-user-id]")
      end

      scenario 'Logged in' do
        user = create(:user)

        login_as(user)
        visit "/"

        expect(page).to have_css("span[data-track-user-id='#{user.id}']")
      end

    end

    context 'Verification level' do

      scenario 'Anonymous' do
        visit "/"

        expect(page).not_to have_css("span[data-track-verification-level]")
      end

      scenario 'Level 1' do
        login_as(create(:user))
        visit "/"

        expect(page).to have_css("span[data-track-verification-level='Nivel 1']")
      end

      scenario 'Level 2' do
        login_as(create(:user, :level_two))
        visit "/"

        expect(page).to have_css("span[data-track-verification-level='Nivel 2']")
      end

      scenario 'Level 3' do
        login_as(create(:user, :level_three))
        visit "/"

        expect(page).to have_css("span[data-track-verification-level='Nivel 3']")
      end

    end

    context 'Demographics' do

      scenario 'Age' do
        user = create(:user, date_of_birth: 18.years.ago)

        login_as(user)
        visit "/"

        expect(page).to have_css("span[data-track-age='18']")
      end

      scenario 'Gender' do
        male   = create(:user, gender: 'Male')
        female = create(:user, gender: 'Female')

        login_as(male)
        visit "/"

        expect(page).to have_css("span[data-track-gender='Hombre']")

        login_as(female)
        visit "/"

        expect(page).to have_css("span[data-track-gender='Mujer']")
      end

      scenario 'District' do
        new_york = create(:geozone, name: "New York")
        user = create(:user, geozone: new_york)

        login_as(user)
        visit "/"

        expect(page).to have_css("span[data-track-district='New York']")
      end
    end

  end

  context 'Events' do

    scenario 'Login' do
      user = create(:user)
      login_through_form_as(user)

      expect(page).to have_css("span[data-track-event-category='Login']")
      expect(page).to have_css("span[data-track-event-action='Entrar']")
    end

    scenario 'Registration' do
      sign_up

      expect(page).to have_css("span[data-track-event-category='Registro']")
      expect(page).to have_css("span[data-track-event-action='Registrar']")
    end

    scenario 'Register as organization' do
      sign_up_as_organization

      expect(page).to have_css("span[data-track-event-category='Registro']")
      expect(page).to have_css("span[data-track-event-action='Registrar']")
    end

    scenario 'Upvote a debate', :js do
      user   = create(:user)
      debate = create(:debate)

      login_as(user)
      visit debate_path(debate)

      find('.in-favor a').click
      expect(page).to have_css("span[data-track-event-category='Debate']", visible: false)
      expect(page).to have_css("span[data-track-event-action='Votar']", visible: false)
      expect(page).to have_css("span[data-track-event-name='Positivo']", visible: false)
    end

    scenario 'Downvote a debate', :js do
      user   = create(:user)
      debate = create(:debate)

      login_as(user)
      visit debate_path(debate)

      find('.against a').click
      expect(page).to have_css("span[data-track-event-category='Debate']", visible: false)
      expect(page).to have_css("span[data-track-event-action='Votar']", visible: false)
      expect(page).to have_css("span[data-track-event-name='Negativo']", visible: false)
    end

    scenario 'Support a proposal', :js do
      user     = create(:user, :level_two)
      proposal = create(:proposal)

      login_as(user)
      visit proposal_path(proposal)

      find('.in-favor a').click
      expect(page).to have_css("span[data-track-event-category='Propuesta']", visible: false)
      expect(page).to have_css("span[data-track-event-action='Apoyar']", visible: false)
      expect(page).to have_css("span[data-track-event-name='#{proposal.id}']", visible: false)
    end

    scenario 'Proposal ranking', :js do
      user = create(:user, :level_two)

      medium = create(:proposal, title: 'Medium proposal')
      best   = create(:proposal, title: 'Best proposal')
      worst  = create(:proposal, title: 'Worst proposal')

      10.times { create(:vote, votable: best)   }
      5.times  { create(:vote, votable: medium) }
      2.times  { create(:vote, votable: worst)  }

      login_as(user)

      visit proposals_path
      click_link 'Best proposal'
      within("aside") do
        find('.in-favor a').click
      end

      expect(page).to have_css("span[data-track-event-category='Propuesta']", visible: false)
      expect(page).to have_css("span[data-track-event-action='Apoyar']", visible: false)
      expect(page).to have_css("span[data-track-event-custom-value='1']", visible: false)
      expect(page).to have_css("span[data-track-event-dimension='6']", visible: false)
      expect(page).to have_css("span[data-track-event-dimension-value='1']", visible: false)

      visit proposals_path
      click_link 'Medium proposal'
      within("aside") do
        find('.in-favor a').click
      end

      expect(page).to have_css("span[data-track-event-custom-value='2']", visible: false)
      expect(page).to have_css("span[data-track-event-dimension-value='2']", visible: false)

      visit proposals_path
      click_link 'Worst proposal'
      within("aside") do
        find('.in-favor a').click
      end

      expect(page).to have_css("span[data-track-event-custom-value='3']", visible: false)
      expect(page).to have_css("span[data-track-event-dimension-value='3']", visible: false)
    end

    scenario 'Create a proposal' do
      author = create(:user)
      login_as(author)

      visit new_proposal_path
      fill_in_proposal
      click_button 'Create proposal'

      expect(page).to have_content 'Proposal created successfully.'
      expect(page).to have_css("span[data-track-event-category='Propuesta']")
      expect(page).to have_css("span[data-track-event-action='Crear']")
    end

    scenario 'Comment a proposal', :js do
      user     = create(:user)
      proposal = create(:proposal)

      login_as(user)
      visit proposal_path(proposal)

      fill_in "comment-body-proposal_#{proposal.id}", with: 'Have you thought about...?'
      click_button 'Publish comment'

      expect(page).to have_css("span[data-track-event-category='Propuesta']", visible: false)
      expect(page).to have_css("span[data-track-event-action='Comentar']", visible: false)
    end

    scenario 'Vote a poll', :js do
      user = create(:user, :level_two)
      poll = create(:poll)

      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, question: question, title: 'Han Solo')
      answer2 = create(:poll_question_answer, question: question, title: 'Chewbacca')

      login_as user
      visit poll_path(poll)

      click_link 'Han Solo'

      expect(page).not_to have_link('Han Solo')

      expect(page).to have_css("span[data-track-event-category]", visible: false)
      expect(page).to have_css("span[data-track-event-category='Votación']", visible: false)
      expect(page).to have_css("span[data-track-event-action='Votar']", visible: false)
    end

    scenario 'Verify census' do
      user = create(:user)
      login_as(user)

      visit verification_path
      verify_residence

      expect(page).to have_css("span[data-track-event-category='Verificación']")
      expect(page).to have_css("span[data-track-event-action='Censo']")
    end

    scenario 'Verify sms' do
      user = create(:user, residence_verified_at: Time.now)
      login_as(user)

      visit verification_path
      confirm_phone

      expect(page).to have_css("span[data-track-event-category='Verificación']")
      expect(page).to have_css("span[data-track-event-action='SMS']")
    end

    scenario 'Delete account' do
      user = create(:user)
      login_as(user)

      visit users_registrations_delete_form_path
      click_button 'Erase my account'

      expect(page).to have_css("span[data-track-event-category='Baja']")
      expect(page).to have_css("span[data-track-event-action='Dar de baja']")
    end
  end

  #Requires testing outgoing _paq.push call from track.js.coffee
  xscenario 'Track events on ajax call'

  #Requires testing outgoing _paq.push call from track.js.coffee
  xcontext 'Page view' do
    scenario 'Url'
    scenario 'Referer'
    scenario 'Title'
  end

  #Requires testing social network registrations
  xscenario 'Register with social network'

  #Requires testing method track_proposal from track.js.coffee
  xcontext 'Proposals' do
    scenario 'show' do
    end
  end

  context "Tracking pages" do

    background do
      Setting['per_page_code_head'] = '<script type="text/javascript">function weboConv(idConv){}</script>'
    end

    context "Codes", :js do
      scenario "root_path" do
        visit root_path
        expect(page.html).to have_content "weboConv(23);"
      end

      scenario "users/sign_up" do
        visit "users/sign_up"
        expect(page.html).to have_content "weboConv(24);"
      end

      scenario "users/sign_up/success" do
        visit "users/sign_up/success"
        expect(page.html).to have_content "weboConv(26);"
      end

      scenario "debates" do
        visit "debates"
        expect(page.html).to have_content "weboConv(27);"
      end
    end

    context "Codes after login", :js do

      background do
        user = create(:user, :level_two)
        login_as(user)
      end

      scenario "debates/new" do
        visit "debates/new"
        expect(page.html).to have_content "weboConv(28);"
      end

      scenario "proposals" do
        visit "proposals"
        expect(page.html).to have_content "weboConv(29);"
      end

      scenario "proposals/new" do
        visit "proposals/new"
        expect(page.html).to have_content "weboConv(30);"
      end

      scenario "procesos" do
        visit "procesos"
        expect(page.html).to have_content "weboConv(32);"
      end

      scenario "presupuestos" do
        budget = create(:budget)
        visit "presupuestos"
        expect(page.html).to have_content "weboConv(33);"
      end

      scenario "help_path" do
        visit help_path
        expect(page.html).to have_content "weboConv(34);"
      end
    end

    scenario "codes with turbolinks", :js do
      visit "debates"
      expect(page.html).to have_content "weboConv(27);"

      first(:link, "Proposals").click
      expect(page).to have_content "Create a proposal"
      expect(page.html).to have_content "weboConv(29);"
    end

  end
end
