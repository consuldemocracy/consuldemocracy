require 'rails_helper'

feature 'Probes' do

  context 'Town Planning' do

    background do
      @probe = Probe.create(codename: 'town_planning')
      @probe_option_1 = @probe.probe_options.create(code: '01' , name: 'First Option')
      @probe_option_2 = @probe.probe_options.create(code: '02' , name: 'Second Option')
      @user = create(:user, :level_two)
      login_as(@user)
    end

    context 'Selecting is allowed' do
      scenario 'User needs permission to select' do
        logout

        visit probe_path(id: @probe.codename)

        expect(page).to have_content 'Selecciona el proyecto que quieres votar'
        expect(page).to have_content('First Option')
        expect(page).to have_content('Second Option')
        expect(page).to_not have_content 'Enviar voto'
      end

      scenario 'User selects an option' do
        visit probe_path(id: @probe.codename)

        choose "option_id_#{@probe_option_2.id}"
        click_button "Enviar voto"

        expect(page).to have_content "Tu voto ha sido recibido"
        expect(page).to have_content "Has votado el proyecto: #{@probe_option_2.name}"

        visit probe_path(id: @probe.codename)

        choose "option_id_#{@probe_option_1.id}"
        click_button "Enviar voto"

        expect(page).to have_content "Tu voto ha sido recibido"
        expect(page).to have_content "Has votado el proyecto: #{@probe_option_1.name}"
      end
    end

    scenario 'Selecting not allowed: Results published' do
      @probe.update(selecting_allowed: false)
      ProbeSelection.create(probe: @probe, probe_option: @probe_option_2, user: create(:user, :level_two))

      visit probe_path(id: @probe.codename)

      expect(@probe_option_2.name).to appear_before(@probe_option_1.name)
      expect(page).to_not have_content 'Enviar voto'
    end
  end

end
