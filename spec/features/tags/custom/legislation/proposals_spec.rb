require 'rails_helper'

feature 'Tags' do

  let(:film_library_process) { create(:legislation_process, film_library: true) }

  scenario 'Index' do
    pulp_fiction     = create(:legislation_proposal, process: film_library_process, tag_list: ["Drama", "Action"])
    the_big_lebowski = create(:legislation_proposal, process: film_library_process, tag_list: ["Comedy"])

    visit legislation_process_proposals_path(film_library_process)

    within "#legislation_proposal_#{pulp_fiction.id}" do
      expect(page).to have_content "Action Drama"
    end

    within "#legislation_proposal_#{the_big_lebowski.id}" do
      expect(page).to have_content "Comedy"
    end
  end

  scenario 'Index shows up to 5 tags per proposal' do
    tag_list = ["Action", "Adventure", "Comedy", "Crime", "Drama", "Epic"]
    create(:legislation_proposal, process: film_library_process, tag_list: tag_list)

    visit legislation_process_proposals_path(film_library_process)

    within('.proposal .tags') do
      expect(page).to have_content '1+'
    end
  end

  scenario 'Index shows 3 tags with no plus link' do
    tag_list = ["Action", "Adventure", "Comedy"]
    create(:legislation_proposal, process: film_library_process, tag_list: tag_list)

    visit legislation_process_proposals_path(film_library_process)

    within('.proposal .tags') do
      tag_list.each do |tag|
        expect(page).to have_content tag
      end
      expect(page).not_to have_content '+'
    end
  end

  scenario 'Show' do
    create(:legislation_proposal, process: film_library_process, tag_list: ["Action", "Adventure"])

    visit legislation_process_proposals_path(film_library_process)

    expect(page).to have_content "Action"
    expect(page).to have_content "Adventure"
  end

  scenario 'Create with custom tags', :js do
    user = create(:user)
    login_as(user)

    visit new_legislation_process_proposal_path(film_library_process)

    expect(page).to have_field("legislation_proposal_tag_list", readonly: true)
  end

  scenario 'Category with category tags', :js do
    user = create(:user)
    login_as(user)

    film_library_process.tag_list_on(:customs).add("Action", "Western")
    film_library_process.save

    visit new_legislation_process_proposal_path(film_library_process)

    fill_in 'legislation_proposal_title', with: 'Pulp Fiction'
    fill_in 'legislation_proposal_summary', with: 'Pulp Fiction is a 1994 American crime film written and directed by Quentin Tarantino.'
    fill_in_ckeditor 'legislation_proposal_description', with: 'Jules Winnfield (Samuel L. Jackson) and Vincent Vega (John Travolta) are two hit men who are out to retrieve a suitcase stolen from their employer....'
    fill_in 'legislation_proposal_video_url', with: 'https://www.imdb.com/title/tt0110912/videoplayer/vi2620371481'
    check 'legislation_proposal_terms_of_service'

    find('.js-add-tag-link', text: 'Action').click
    click_button 'Create proposal'

    expect(page).to have_content "Proposal created successfully"

    within "#tags_legislation_proposal_#{film_library_process.proposals.last.id}" do
      expect(page).to have_content 'Action'
      expect(page).not_to have_content 'Western'
    end
  end

  scenario 'Create with too many tags', :js do
    tag_list = ["Action", "Adventure", "Comedy", "Crime", "Drama", "Musical", "Epic"]

    film_library_process.tag_list_on(:customs).add(tag_list)
    film_library_process.save

    user = create(:user)
    login_as(user)

    visit new_legislation_process_proposal_path(film_library_process)
    fill_in 'legislation_proposal_title', with: 'Title'
    fill_in 'legislation_proposal_summary', with: 'Summary'
    fill_in_ckeditor 'legislation_proposal_description', with: 'Description'
    check 'legislation_proposal_terms_of_service'

    tag_list.each do |tag|
      find('.js-add-tag-link', text: tag).click
    end

    click_button 'Create proposal'

    expect(page).to have_content error_message
    expect(page).to have_content 'must be less than or equal to 6'
  end

  scenario 'Create with errors' do
    tag_list = ["Action", "Adventure"]

    film_library_process.tag_list_on(:customs).add(tag_list)
    film_library_process.save

    user = create(:user)
    login_as(user)

    visit new_legislation_process_proposal_path(film_library_process)
    click_button 'Create proposal'

    within("#category_tags") do
      expect(page).to have_content("Action")
      expect(page).to have_content("Adventure")
    end
  end

  context "Filter" do

    scenario "From index" do
      proposal1 = create(:legislation_proposal, process: film_library_process, tag_list: "Action")
      proposal2 = create(:legislation_proposal, process: film_library_process, tag_list: "Adventure")

      visit legislation_process_proposals_path(film_library_process)

      within "#legislation_proposal_#{proposal1.id}" do
        click_link "Action"
      end

      within(".legislation-proposals") do
        expect(page).to have_css("[data-type='proposal']", count: 1)
        expect(page).to have_content(proposal1.title)
      end
    end

    scenario "From show" do
      proposal1 = create(:legislation_proposal, process: film_library_process, tag_list: "Action")
      proposal2 = create(:legislation_proposal, process: film_library_process, tag_list: "Adventure")

      visit legislation_process_proposal_path(film_library_process, proposal1)

      click_link "Action"

      within(".legislation-proposals") do
        expect(page).to have_css("[data-type='proposal']", count: 1)
        expect(page).to have_content(proposal1.title)
      end
    end
  end

  context 'Tag cloud' do

    scenario 'Display genre tags' do
      tag_list = ["Action", "Adventure"]

      film_library_process.tag_list_on(:customs).add(tag_list)
      film_library_process.save

      visit legislation_process_proposals_path(film_library_process)

      within "#categories" do
        expect(page).to have_content "Action"
        expect(page).to have_content "Adventure"
      end
    end

    scenario "Filter by category tags" do
      tag_list = ["Action", "Adventure"]

      film_library_process.tag_list_on(:customs).add(tag_list)
      film_library_process.save

      proposal1 = create(:legislation_proposal, process: film_library_process, tag_list: "Action")
      proposal2 = create(:legislation_proposal, process: film_library_process, tag_list: "Action")
      proposal3 = create(:legislation_proposal, process: film_library_process, tag_list: "Adventure")

      visit legislation_process_proposals_path(film_library_process)

      within "#categories" do
        click_link "Action"
      end

      expect(page).to have_css("[data-type='proposal']", count: 2)
      expect(page).to have_content proposal1.title
      expect(page).to have_content proposal2.title
      expect(page).not_to have_content proposal3.title
    end
  end

end