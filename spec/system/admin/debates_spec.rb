require "rails_helper"

describe "Admin debates", :admin do
  it_behaves_like "flaggable", :debate, admin: true

  scenario "Index" do
    create(:debate, title: "Best beaches")

    visit admin_root_path
    within("#side_menu") { click_link "Debates" }

    expect(page).to have_content "Best beaches"
  end

  scenario "Show debate" do
    debate = create(:debate)
    visit admin_debate_path(debate)

    expect(page).to have_content(debate.title)
    expect(page).to have_content(debate.description)
  end

  scenario "Comments link" do
    debate = create(:debate)
    comment = create(:comment, commentable: debate)

    visit admin_debate_path(debate)
    click_link "1 comment"

    expect(page).to have_content(comment.body)
  end

  context "Selecting csv", :no_js do
    scenario "Downloading CSV file" do
      first_debate = create(:debate, title: "Should Pluto be a planet?",
                                     created_at: Time.zone.local(2026, 6, 1, 14, 56, 10))
      second_debate = create(:debate, title: "Best approach for public transport",
                                      created_at: Time.zone.local(2026, 6, 1, 14, 58, 20))
      third_debate = create(:debate, title: "Green spaces in the city",
                                     created_at: Time.zone.local(2026, 6, 1, 15, 00, 30))

      visit admin_debates_path

      click_link "Download current selection"

      header = page.response_headers["Content-Disposition"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="debates.csv"/)

      csv_contents = <<~CSV
        ID,Title,Author,Created at
        #{third_debate.id},#{third_debate.title},\
        #{third_debate.author.email},2026-06-01 15:00:30
        #{second_debate.id},#{second_debate.title},\
        #{second_debate.author.email},2026-06-01 14:58:20
        #{first_debate.id},#{first_debate.title},\
        #{first_debate.author.email},2026-06-01 14:56:10
      CSV

      expect(page.body).to eq(csv_contents)
    end

    scenario "Downloading CSV file with applied filter" do
      create(:debate, title: "Should Pluto be a planet?")
      create(:debate, title: "Best approach for public transport")

      visit admin_debates_path
      fill_in "search", with: "Pluto"
      click_button "Search"

      expect(page).to have_content "Should Pluto be a planet?"
      expect(page).not_to have_content "Best approach for public transport"

      click_link "Download current selection"

      expect(page.body).to have_content "ID,Title,Author,Created at"
      expect(page.body).to have_content "Should Pluto be a planet?"
      expect(page.body).not_to have_content "Best approach for public transport"
    end
  end
end
