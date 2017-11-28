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
        expect(page).to have_content 'First Option'
        expect(page).to have_content 'Second Option'
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

  context 'Plaza' do

    background do
      @probe = Probe.create(codename: 'plaza')
      @probe_option_1 = @probe.probe_options.create(code: 'PL1' , name: 'Plaza Option 1')
      @probe_option_2 = @probe.probe_options.create(code: 'PL2' , name: 'Plaza Option II')
      @user = create(:user, :level_two)
      logout
      login_as(@user)
    end

    context 'Selecting is allowed' do

      scenario 'Index' do
        visit probe_path(id: @probe.codename)

        expect(page).to have_css(".probe_option", count: 2)
        expect(page).to have_content @probe_option_1.name
        expect(page).to have_content @probe_option_2.name

        within("#probe_option_#{@probe_option_1.id}") do
          expect(page).to have_content "(REF. #{@probe_option_1.code})"

          expect(page).to have_css("a", :text => /Memoria/)
          expect(page).to have_css("a", :text => /Imágenes/)

          expect(page).to have_link @probe_option_1.name, href: plaza_probe_option_path(@probe_option_1)
          expect(page).to have_link "Ver detalles del proyecto",  href: plaza_probe_option_path(@probe_option_1)
          expect(page).to have_css(".project-thumbnail[href='#{plaza_probe_option_path(@probe_option_1)}']")
        end
      end

      scenario 'Random order maintained when going back from show' do
        10.times { |i| @probe.probe_options.create(code: "PL#{i + 2}" , name: "Plaza Option #{i + 2}") }

        visit probe_path(id: @probe.codename)

        order = all(".probe_option h4").collect {|i| i.text }

        click_link @probe_option_1.name
        click_link "Back to list"

        new_order = all(".probe_option h4").collect {|i| i.text }
        expect(order).to eq(new_order)
      end

      scenario 'User needs permission to select' do
        logout

        visit probe_path(id: @probe.codename)

        expect(page).to have_content 'You must Sign in or Sign up to participate'
        expect(page).to have_content 'Plaza Option 1'
        expect(page).to have_content 'Plaza Option II'
        expect(page).to_not have_css("#probe_option_#{@probe_option_1.id}_form")
        expect(page).to_not have_css("#probe_option_#{@probe_option_2.id}_form")

        login_as(create(:user))

        visit probe_path(id: @probe.codename)

        expect(page).to have_content 'To participate in this process you need to verify your account'
        expect(page).to have_content 'Plaza Option 1'
        expect(page).to have_content 'Plaza Option II'
        expect(page).to_not have_css("#probe_option_#{@probe_option_1.id}_form")
        expect(page).to_not have_css("#probe_option_#{@probe_option_2.id}_form")
      end

      scenario 'User selects an option' do
        visit probe_path(id: @probe.codename)

        within("#probe_option_#{@probe_option_2.id}_form") do
          click_button "Votar"
        end
        expect(page).to have_content "Tu voto ha sido recibido"
        expect(page).to have_content "Has votado el proyecto: #{@probe_option_2.name}"

        visit probe_path(id: @probe.codename)

        within("#probe_option_#{@probe_option_1.id}_form") do
          click_button "Votar"
        end

        expect(page).to have_content "Tu voto ha sido recibido"
        expect(page).to have_content "Has votado el proyecto: #{@probe_option_1.name}"
      end
    end

    context "Debate" do

      scenario "Each probe option should link to a debate" do
        @probe.probe_options.each do |probe_option|
          debate = create(:debate)
          probe_option.update(debate: debate)
        end

        visit probe_path(id: @probe.codename)

        @probe.probe_options.each do |probe_option|
          within("#probe_option_#{probe_option.id}") do
            expect(page).to have_link "Ver detalles del proyecto", href: plaza_probe_option_path(probe_option)
          end
        end
      end

      scenario 'do not show in index' do
        @probe_option_1.update(debate: create(:debate))
        @probe_option_2.update(debate: create(:debate))

        visit debates_path

        expect(page).to_not have_content @probe_option_1.debate.title
        expect(page).to_not have_content @probe_option_2.debate.title
      end
    end

  end
end
