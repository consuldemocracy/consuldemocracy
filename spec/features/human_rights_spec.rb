require 'rails_helper'

feature 'Human Rights' do

  background do
    Setting['feature.human_rights.voting'] = true
  end

  context 'Navigation' do

    scenario 'Home' do
      visit "/"
      first(:link, "Processes").click
      click_link "Past"

      within("#dd-hh") do
        click_link "Más información"
      end

      expect(page).to have_content "El Ayuntamiento de Madrid quiere reforzar su compromiso con los Derechos Humanos"
      expect(current_path).to eq("/derechos-humanos")
    end

    scenario 'Proposals' do
      visit "derechos-humanos"
      click_link "Ver medidas"

      expect(current_path).to eq("/derechos-humanos/medidas")
    end

    scenario 'Legislation' do
      visit "derechos-humanos"
      click_link "Ver borrador"

      expect(page).to have_content "Borrador del Plan de Derechos Humanos del Ayuntamiento"
      expect(current_path).to eq("/derechos-humanos/plan")
    end

  end

  context 'Proposals' do

    context 'Index' do

      scenario 'Index' do
        proposal1 = create(:proposal, :human_rights)
        proposal2 = create(:proposal, :human_rights)
        proposal3 = create(:proposal, :human_rights)

        visit human_rights_proposals_path

        expect(page).to have_css(".proposal", count: 3)
        expect(page).to have_content proposal1.title
        expect(page).to have_content proposal2.title
        expect(page).to have_content proposal3.title
      end

      scenario 'Search by title' do
        proposal1 = create(:proposal, :human_rights, title: "Get Schwifty")
        proposal2 = create(:proposal, :human_rights, title: "Schwifty Hello")
        proposal3 = create(:proposal, :human_rights, title: "Do not show me")
        proposal4 = create(:proposal, title: "Get super Schwifty")

        visit human_rights_proposals_path

        within(".expanded #search_form") do
          fill_in "search", with: "Schwifty"
          click_button "Search"
        end

        within("#proposals") do
          expect(page).to have_css('.proposal', count: 2)

          expect(page).to have_content(proposal1.title)
          expect(page).to have_content(proposal2.title)
          expect(page).to_not have_content(proposal3.title)
          expect(page).to_not have_content(proposal4.title)
        end
      end

      scenario 'Search by subproceeding' do
        proposal1 = create(:proposal, title: "Get Schwifty",   proceeding: "Derechos Humanos", sub_proceeding: "Derecho a la educación")
        proposal2 = create(:proposal, title: "Schwifty Hello", proceeding: "Derechos Humanos", sub_proceeding: "Derecho a la vivienda")
        proposal3 = create(:proposal, title: "Do not show me", proceeding: "Derechos Humanos", sub_proceeding: "Derecho al trabajo")

        visit human_rights_proposals_path

        within(".expanded #search_form") do
          fill_in "search", with: "educación"
          click_button "Search"
        end

        within("#proposals") do
          expect(page).to have_css('.proposal', count: 1)

          expect(page).to have_content(proposal1.title)
          expect(page).to_not have_content(proposal2.title)
          expect(page).to_not have_content(proposal3.title)
        end
      end

      scenario 'Search by official position', :js do
        ana  = create :user, official_level: 2
        john = create :user, official_level: 3

        proposal1 = create(:proposal, :human_rights, author: ana)
        proposal2 = create(:proposal, :human_rights, author: ana)
        proposal3 = create(:proposal, :human_rights, author: john)
        proposal4 = create(:proposal, author: ana)

        visit human_rights_proposals_path

        click_link "Advanced search"
        select Setting['official_level_2_name'], from: "advanced_search_official_level"
        click_button "Filter"

        expect(page).to have_content("There are 2 citizen proposals")

        within("#proposals") do
          expect(page).to have_content(proposal1.title)
          expect(page).to have_content(proposal2.title)
          expect(page).to_not have_content(proposal3.title)
          expect(page).to_not have_content(proposal4.title)
        end
      end

      scenario 'Order by random by default' do
        per_page = Kaminari.config.default_per_page
        (per_page + 2).times { create(:proposal, :human_rights) }

        visit human_rights_proposals_path
        order = all(".proposal h3").collect {|i| i.text }

        visit human_rights_proposals_path
        new_order = eq(all(".proposal h3").collect {|i| i.text })

        expect(order).to_not eq(new_order)
      end

      scenario 'Order by most voted' do
        create(:proposal, :human_rights, title: 'Best').update_column(:confidence_score, 10)
        create(:proposal, :human_rights, title: 'Worst').update_column(:confidence_score, 2)
        create(:proposal, :human_rights, title: 'Medium').update_column(:confidence_score, 5)

        visit human_rights_proposals_path

        click_link 'highest rated'

        expect(page).to have_selector('a.active', text: 'highest rated')
        expect('Best').to appear_before('Medium')
        expect('Medium').to appear_before('Worst')
      end

      scenario 'No vote', :js do
        user = create(:user, :level_two)
        proposal = create(:proposal,  :human_rights)

        login_as(user)
        visit human_rights_proposals_path

        within("#proposal_#{proposal.id}") do
          expect(page).to_not have_css('.in-favor a')
        end
      end

      scenario 'Filter by sub process' do
        proposal1 = create(:proposal, proceeding: "Derechos Humanos", sub_proceeding: "Derecho a la educación")
        proposal2 = create(:proposal, proceeding: "Derechos Humanos", sub_proceeding: "Derecho a la vivienda")

        visit human_rights_proposals_path

        within "#categories" do
          click_link "Derecho a la educación"
        end

        within("#proposals") do
          expect(page).to have_css('.proposal', count: 1)
          expect(page).to have_content(proposal1.title)
        end
      end

      scenario "Highlight human right's user" do
        human_rights_user = create(:user, id: 180346)
        proposal1 = create(:proposal, :human_rights, author: human_rights_user)
        proposal2 = create(:proposal, :human_rights)

        visit human_rights_proposals_path

        expect(page).to     have_css("#proposal_#{proposal1.id}.human-rights")
        expect(page).to_not have_css("#proposal_#{proposal2.id}.human-rights")
      end

      scenario 'Do not display tag cloud' do
        earth = create(:proposal, tag_list: 'Medio Ambiente')
        money = create(:proposal, tag_list: 'Economía')
        proposal1 = create(:proposal, :human_rights, tag_list: 'Libros')
        proposal2 = create(:proposal, :human_rights, tag_list:  'Casas')

        visit human_rights_proposals_path

        expect(page).to_not have_css("#tag-cloud")
      end

      scenario 'Do not display create proposal button' do
        visit human_rights_proposals_path

        expect(page).to_not have_link "Create proposal"
      end

      scenario 'Only display official sub proceedings' do
        proposal1 = create(:proposal, proceeding: "Derechos Humanos", sub_proceeding: "Derecho a la educación")
        proposal2 = create(:proposal, proceeding: "Derechos Humanos", sub_proceeding: "Derecho a ser feliz")

        visit human_rights_proposals_path

        within "#categories" do
          expect(page).to     have_link "Derecho a la educación"
          expect(page).to_not have_link "Derecho a ser feliz"
        end
      end

      scenario 'Do not display number of votes required' do
        proposal = create(:proposal, :human_rights)

        visit human_rights_proposals_path

        within("#proposal_#{proposal.id}") do
          expect(page).to_not have_content "supports needed"
        end
      end

    end

    context 'Show' do

      scenario 'Proceeding attributes' do
        proposal = create(:proposal, proceeding: "Derechos Humanos", sub_proceeding: "Derecho a la educación")

        visit human_rights_proposal_path(proposal)

        expect(page).to have_content "Derechos Humanos"
        expect(page).to have_content "Derecho a la educación"
      end

      scenario 'No vote', :js do
        user = create(:user, :level_two)
        proposal = create(:proposal, :human_rights)

        login_as(user)
        visit human_rights_proposal_path(proposal)

        within("#proposal_#{proposal.id}") do
          expect(page).to_not have_css('.in-favor a')
        end
      end

      scenario 'Do not display number of votes required' do
        proposal = create(:proposal, :human_rights)

        visit human_rights_proposal_path(proposal)

        within("#proposal_#{proposal.id}") do
          expect(page).to_not have_content "supports needed"
        end
      end

    end

  end

  context 'Legislation' do

    scenario 'Comment' do
    end

  end

  context 'Closed' do

    scenario 'Home' do
    end

    scenario 'proposals' do
    end

    scenario 'Legislation' do
    end

  end

end