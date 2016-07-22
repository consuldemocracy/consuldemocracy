require 'rails_helper'

feature 'Town Planning - Benches' do

  scenario "Results published: Voting not allowed" do
    user = create(:user, :level_two)
    login_as(user)

    bench1 = create(:bench, cached_votes_up: 5)
    bench2 = create(:bench, cached_votes_up: 50)

    visit processes_path
    click_link "See the results"

    expect(bench2.name).to appear_before(bench1.name)
    expect(page).to_not have_content "Enviar voto"
  end

  scenario "Permissions user not logged in" do
    visit town_planning_thanks_path
    expect(current_path).to eq(town_planning_path)
  end

end
