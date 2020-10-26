shared_examples "relationable" do |relationable_model_name|
  let(:relationable) { create(relationable_model_name.name.parameterize(separator: "_").to_sym) }
  let(:related1) { create([:proposal, :debate, :budget_investment].sample) }
  let(:related2) { create([:proposal, :debate, :budget_investment].sample) }
  let(:user) { create(:user) }

  scenario "related contents are listed" do
    create(:related_content, parent_relationable: relationable, child_relationable: related1, author: build(:user))

    visit relationable.url
    within("#related-content-list") do
      expect(page).to have_content(related1.title)
    end

    visit related1.url
    within("#related-content-list") do
      expect(page).to have_content(relationable.title)
    end
  end

  scenario "related contents list is not rendered if there are no relations" do
    visit relationable.url
    expect(page).not_to have_css("#related-content-list")
  end

  scenario "related contents can be added", :js do
    login_as(user)
    visit relationable.url

    expect(page).not_to have_selector("#related_content")

    click_on("Add related content")

    within("#related_content") do
      fill_in "url", with: "#{Setting["url"] + related1.url}"
      click_button "Add"
    end

    within("#related-content-list") do
      expect(page).to have_content(related1.title)
    end

    visit related1.url

    within("#related-content-list") do
      expect(page).to have_content(relationable.title)
    end

    click_on("Add related content")

    within("#related_content") do
      fill_in "url", with: "#{Setting["url"] + related2.url}"
      click_button "Add"
    end

    within("#related-content-list") do
      expect(page).to have_content(related2.title)
    end
  end

  scenario "if related content URL is invalid returns error" do
    login_as(user)
    visit relationable.url

    click_on("Add related content")

    within("#related_content") do
      fill_in "url", with: "http://invalidurl.com"
      click_button "Add"
    end

    expect(page).to have_content("Link not valid. Remember to start with #{Setting[:url]}.")
  end

  scenario "returns error when relating content URL to itself" do
    login_as(user)
    visit relationable.url

    click_on("Add related content")

    within("#related_content") do
      fill_in "url", with: Setting[:url] + relationable.url.to_s
      click_button "Add"
    end

    expect(page).to have_content("Link not valid. You cannot relate a content to itself")
  end

  scenario "related content can be scored positively", :js do
    related_content = create(:related_content, parent_relationable: relationable, child_relationable: related1, author: build(:user))

    login_as(user)
    visit relationable.url

    within("#related-content-list") do
      find("#related-content-#{related_content.opposite_related_content.id}").hover
      find("#score-positive-related-#{related_content.opposite_related_content.id}").click
      expect(page).not_to have_css("#score-positive-related-#{related_content.opposite_related_content.id}")
    end

    expect(related_content.related_content_scores.find_by(user_id: user.id, related_content_id: related_content.id).value).to eq(1)
    expect(related_content.opposite_related_content.related_content_scores.find_by(user_id: user.id, related_content_id: related_content.opposite_related_content.id).value).to eq(1)
  end

  scenario "related content can be scored negatively", :js do
    related_content = create(:related_content, parent_relationable: relationable, child_relationable: related1, author: build(:user))

    login_as(user)
    visit relationable.url

    within("#related-content-list") do
      find("#related-content-#{related_content.opposite_related_content.id}").hover
      find("#score-negative-related-#{related_content.opposite_related_content.id}").click
      expect(page).not_to have_css("#score-negative-related-#{related_content.opposite_related_content.id}")
    end

    expect(related_content.related_content_scores.find_by(user_id: user.id, related_content_id: related_content.id).value).to eq(-1)
    expect(related_content.opposite_related_content.related_content_scores.find_by(user_id: user.id, related_content_id: related_content.opposite_related_content.id).value).to eq(-1)
  end

  scenario "if related content has negative score it will be hidden" do
    related_content = create(:related_content, parent_relationable: relationable, child_relationable: related1, author: build(:user))

    2.times do
      related_content.send("score_positive", build(:user))
    end

    6.times do
      related_content.send("score_negative", build(:user))
    end

    login_as(user)

    visit relationable.url

    expect(page).not_to have_css("#related-content-list")
  end
end
