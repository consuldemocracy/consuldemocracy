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
      first_debate = create(:debate, title: "First debate title")
      second_debate = create(:debate, title: "Second debate title")
      third_debate = create(:debate, title: "Third debate title")

      visit admin_debates_path

      click_link "Download current selection"

      header = page.response_headers["Content-Disposition"]
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename="debates.csv"/)

      csv_contents = <<~CSV
        ID,Debate,Author
        #{third_debate.id},#{third_debate.title},#{third_debate.author.email}
        #{second_debate.id},#{second_debate.title},#{second_debate.author.email}
        #{first_debate.id},#{first_debate.title},#{first_debate.author.email}
      CSV

      expect(page.body).to eq(csv_contents)
    end

    scenario "Downloading CSV file with applied filter" do
      create(:debate, title: "Unique Pluto debate")
      create(:debate, title: "Other topic")

      visit admin_debates_path
      fill_in "search", with: "Pluto"
      click_button "Search"

      expect(page).to have_content "Unique Pluto debate"
      expect(page).not_to have_content "Other topic"

      click_link "Download current selection"

      expect(page.body).to have_content "ID,Debate,Author"
      expect(page.body).to have_content "Unique Pluto debate"
      expect(page.body).not_to have_content "Other topic"
    end
  end
end
