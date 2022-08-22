shared_examples "relationable" do |relationable_model_name|
  let(:relationable) { create(relationable_model_name.name.parameterize(separator: "_").to_sym) }
  let(:related1) { create([:proposal, :debate, :budget_investment].sample) }
  let(:related2) { create([:proposal, :debate, :budget_investment].sample) }
  let(:user) { create(:user) }
  before { Setting["url"] = Capybara.app_host }

  scenario "related contents are listed" do
    create(:related_content, parent_relationable: relationable, child_relationable: related1, author: build(:user))

    visit polymorphic_path(relationable)
    within("#related-content-list") do
      expect(page).to have_content related1.title
    end

    visit polymorphic_path(related1)
    within("#related-content-list") do
      expect(page).to have_content relationable.title
    end
  end

  scenario "related contents list is not rendered if there are no relations" do
    visit polymorphic_path(relationable)
    expect(page).not_to have_css "#related-content-list"
  end

  scenario "related contents can be added" do
    login_as(user)
    visit polymorphic_path(relationable)

    expect(page).not_to have_css "#related_content"
    expect(page).to have_css ".add-related-content[aria-expanded='false']"

    click_button "Add related content"

    expect(page).to have_css ".add-related-content[aria-expanded='true']"

    within("#related_content") do
      fill_in "Link to related content", with: polymorphic_url(related1)
      click_button "Add"
    end

    within("#related-content-list") do
      expect(page).to have_content related1.title
    end

    visit polymorphic_path(related1)

    within("#related-content-list") do
      expect(page).to have_content relationable.title
    end

    click_button "Add related content"

    within("#related_content") do
      fill_in "Link to related content", with: polymorphic_url(related2)
      click_button "Add"
    end

    within("#related-content-list") do
      expect(page).to have_content related2.title
    end
  end

  scenario "if related content URL is invalid returns error" do
    login_as(user)
    visit polymorphic_path(relationable)

    click_button "Add related content"

    within("#related_content") do
      fill_in "Link to related content", with: "http://invalidurl.com"
      click_button "Add"
    end

    expect(page).to have_content "Link not valid. Remember to start with #{Capybara.app_host}."
  end

  scenario "returns error when relating content URL to itself" do
    login_as(user)
    visit polymorphic_path(relationable)

    click_button "Add related content"

    within("#related_content") do
      fill_in "Link to related content", with: polymorphic_url(relationable)
      click_button "Add"
    end

    expect(page).to have_content "Link not valid. You cannot relate a content to itself"
  end

  context "custom URLs" do
    before do
      custom_route = proc { get "/mypath/:id" => "debates#show" }
      Rails.application.routes.send(:eval_block, custom_route)
    end

    after { Rails.application.reload_routes! }

    scenario "finds relationable with custom URLs" do
      related = create(:debate, title: "My path is the only one I've walked")

      login_as(user)
      visit polymorphic_path(relationable)

      click_button "Add related content"

      within("#related_content") do
        fill_in "Link to related content", with: "#{Capybara.app_host}/mypath/#{related.id}"
        click_button "Add"
      end

      within("#related-content-list") do
        expect(page).to have_content "My path is the only one I've walked"
      end
    end
  end

  scenario "returns an error when the related content already exists" do
    create(:related_content, parent_relationable: relationable, child_relationable: related1)
    login_as(user)
    visit polymorphic_path(relationable)

    click_button "Add related content"

    within("#related_content") do
      fill_in "url", with: polymorphic_url(related1)
      click_button "Add"
    end

    expect(page).to have_content "The related content you are adding already exists."
  end

  scenario "related content can be scored positively" do
    related_content = create(:related_content, parent_relationable: relationable, child_relationable: related1, author: build(:user))

    login_as(user)
    visit polymorphic_path(relationable)

    within("#related-content-list") do
      click_link "Yes"

      expect(page).not_to have_link "Yes"
      expect(page).not_to have_link "No"
    end

    expect(related_content.related_content_scores.find_by(user_id: user.id, related_content_id: related_content.id).value).to eq(1)
    expect(related_content.opposite_related_content.related_content_scores.find_by(user_id: user.id, related_content_id: related_content.opposite_related_content.id).value).to eq(1)
  end

  scenario "related content can be scored negatively" do
    related_content = create(:related_content, parent_relationable: relationable, child_relationable: related1, author: build(:user))

    login_as(user)
    visit polymorphic_path(relationable)

    within("#related-content-list") do
      click_link "No"

      expect(page).not_to have_link "Yes"
      expect(page).not_to have_link "No"
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

    visit polymorphic_path(relationable)

    expect(page).not_to have_css "#related-content-list"
  end
end
