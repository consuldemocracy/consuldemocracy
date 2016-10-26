require 'rails_helper'

feature 'Probe options' do

  context 'Plaza probe' do
    background do
      @probe = Probe.where(codename: 'plaza').first_or_create
      @probe_option = @probe.probe_options.create(code: 'PL1' , name: 'Plaza Option 1')
      logout
    end

    context 'Show' do
      scenario 'Option info is visble' do
        visit probe_probe_option_path(probe_id: 'plaza', id: @probe_option.id)

        expect(page).to have_content 'Plaza Option 1'
        expect(page).to have_content "(REF. #{@probe_option.code})"

        expect(page).to have_link('Memoria ()')
        expect(page).to have_link('Imágenes ()')
      end

      scenario 'User needs permission to select' do
        visit probe_probe_option_path(probe_id: 'plaza', id: @probe_option.id)

        expect(page).to have_content 'You must Sign in or Sign up to participate'
        expect(page).to have_content 'Plaza Option 1'
        expect(page).to_not have_css("#probe_option_#{@probe_option.id}_form")

        login_as(create(:user))

        visit probe_path(id: @probe.codename)

        expect(page).to have_content 'To participate in this process you need to verify your account'
        expect(page).to have_content 'Plaza Option 1'
        expect(page).to_not have_css("#probe_option_#{@probe_option.id}_form")
      end

      scenario 'User selects this option' do
        login_as(create(:user, :level_two))
        visit probe_probe_option_path(probe_id: 'plaza', id: @probe_option.id)

        within("#probe_option_#{@probe_option.id}_form") do
          click_button "Vote"
        end

        expect(page).to have_content "Tu voto ha sido recibido"
        expect(page).to have_content "Has votado el proyecto: #{@probe_option.name}"
      end

      scenario 'User has voted for this options' do
        user = create(:user, :level_two)
        ProbeSelection.create!(user: user, probe_option: @probe_option, probe: @probe)

        login_as(user)
        visit probe_probe_option_path(probe_id: 'plaza', id: @probe_option.id)

        expect(page).to have_content "Has votado este proyecto"
        expect(page).to_not have_button "Vote"
      end

      scenario 'User has voted for another option' do
        user = create(:user, :level_two)
        @probe_option1 = @probe.probe_options.create(code: 'PL1' , name: 'Plaza Option 1')
        @probe_option2 = @probe.probe_options.create(code: 'PL2' , name: 'Plaza Option 2')

        ProbeSelection.create!(user: user, probe_option: @probe_option1, probe: @probe)

        login_as(user)
        visit probe_probe_option_path(probe_id: 'plaza', id: @probe_option2.id)

        expect(page).to have_content "Has votado el proyecto #{@probe_option1.name}"
        expect(page).to have_button "Vote"
      end

      scenario 'Discard option' do
      end

      scenario 'Display all discarded options' do
      end

      scenario 'Do not display link if there are no discarded options' do
      end

    end
  end
end
