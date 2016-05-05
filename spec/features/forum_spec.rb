require 'rails_helper'

feature "Forum" do

  scenario "Index" do
    forum1 = create(:forum)
    forum2 = create(:forum)
    forum3 = create(:forum)
    user = create(:user, :level_two)
    login_as(user)

    visit forums_path

    expect(page).to have_css(".forum", count: 3)

    within("#forum_#{forum1.id}") do
      expect(page).to have_content(forum1.name)
    end
  end

  context "Show" do

    scenario "Forum info" do
      forum = create(:forum)

      user = create(:user, :level_two)
      login_as(user)
      visit forum_path(forum)

      expect(page).to have_content forum.name
    end

    scenario "Forum votes" do
      forum = create(:forum)
      geozone = create(:geozone)

      spending_proposal1 = create(:spending_proposal, geozone: nil, title: "Save the city")
      spending_proposal2 = create(:spending_proposal, geozone: nil, title: "Reduce traffic")
      spending_proposal3 = create(:spending_proposal, geozone: geozone, title: "Save my district")
      spending_proposal4 = create(:spending_proposal, geozone: geozone, title: "Fix a hole in my street")

      spending_proposal5 = create(:spending_proposal, geozone: nil, title: "Do not save nothing")
      spending_proposal6 = create(:spending_proposal, geozone: geozone, title: "Save less")

      create(:vote, voter: forum.user, votable: spending_proposal1, vote_flag: true)
      create(:vote, voter: forum.user, votable: spending_proposal2, vote_flag: true)
      create(:vote, voter: forum.user, votable: spending_proposal3, vote_flag: true)
      create(:vote, voter: forum.user, votable: spending_proposal4, vote_flag: true)

      user = create(:user, :level_two)
      login_as(user)
      visit forum_path(forum)

      within("#city") do
        expect(page).to have_css(".forum_vote", count: 2)
        expect(page).to have_content spending_proposal1.title
        expect(page).to have_content spending_proposal2.title
      end

      within("#district") do
        expect(page).to have_css(".forum_vote", count: 2)
        expect(page).to have_content spending_proposal3.title
        expect(page).to have_content spending_proposal4.title
      end
    end

    scenario "No votes" do
      forum = create(:forum)
      visit forum_path(forum)

      expect(page).to_not have_css("#city")
      expect(page).to have_content "This Forum has not supported any investment proposals"
    end

  end

end