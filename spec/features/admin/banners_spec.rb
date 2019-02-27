require "rails_helper"

feature "Admin banners magement" do

  background do
    login_as(create(:administrator).user)
  end

  it_behaves_like "translatable",
                  "banner",
                  "edit_admin_banner_path",
                  %w[title description]

  context "Index" do
    background do
      @banner1 = create(:banner, title: "Banner number one",
                  description:  "This is the text of banner number one and is not active yet",
                  target_url:  "http://www.url.com",
                  post_started_at: (Time.current + 4.days),
                  post_ended_at:   (Time.current + 10.days),
                  background_color: "#FF0000",
                  font_color: "#FFFFFF")

      @banner2 = create(:banner, title: "Banner number two",
                  description:  "This is the text of banner number two and is not longer active",
                  target_url:  "http://www.url.com",
                  post_started_at: (Time.current - 10.days),
                  post_ended_at:   (Time.current - 3.days),
                  background_color: "#00FF00",
                  font_color: "#FFFFFF")

      @banner3 = create(:banner, title: "Banner number three",
                  description:  "This is the text of banner number three and has style banner-three",
                  target_url:  "http://www.url.com",
                  post_started_at: (Time.current - 1.day),
                  post_ended_at:   (Time.current + 10.days),
                  background_color: "#0000FF",
                  font_color: "#FFFFFF")

      @banner4 = create(:banner, title: "Banner number four",
                  description:  "This is the text of banner number four and has style banner-one",
                  target_url:  "http://www.url.com",
                  post_started_at: (DateTime.current - 10.days),
                  post_ended_at:   (DateTime.current + 10.days),
                  background_color: "#FFF000",
                  font_color: "#FFFFFF")

      @banner5 = create(:banner, title: "Banner number five",
                  description:  "This is the text of banner number five and has style banner-two",
                  target_url:  "http://www.url.com",
                  post_started_at: (DateTime.current - 10.days),
                  post_ended_at:   (DateTime.current + 10.days),
                  background_color: "#FFFF00",
                  font_color: "#FFFFFF")
    end

    scenario "Index show active banners" do
      visit admin_banners_path(filter: "with_active")
      expect(page).to have_content("There are 3 banners")
    end

    scenario "Index show inactive banners" do
      visit admin_banners_path(filter: "with_inactive")
      expect(page).to have_content("There are 2 banners")
    end

    scenario "Index show all banners" do
      visit admin_banners_path
      expect(page).to have_content("There are 5 banners")
    end
  end

  scenario "Banners publication is listed on admin menu" do
    visit admin_root_path

    within("#side_menu") do
      expect(page).to have_link "Manage banners"
    end
  end

  scenario "Publish a banner" do
    section = create(:web_section, name: "proposals")

    visit admin_root_path

    within("#side_menu") do
      click_link "Manage banners"
    end

    click_link "Create banner"

    fill_in "Title", with: "Such banner"
    fill_in "Description", with: "many text wow link"
    fill_in "banner_target_url", with: "https://www.url.com"
    last_week = Time.current - 7.days
    next_week = Time.current + 7.days
    fill_in "post_started_at", with: last_week.strftime("%d/%m/%Y")
    fill_in "post_ended_at", with: next_week.strftime("%d/%m/%Y")
    fill_in "banner_background_color", with: "#850000"
    fill_in "banner_font_color", with: "#ffb2b2"
    check "banner_web_section_ids_#{section.id}"

    click_button "Save changes"

    expect(page).to have_content "Such banner"

    visit proposals_path

    expect(page).to have_content "Such banner"
    expect(page).to have_link "Such banner many text wow link", href: "https://www.url.com"
  end

  scenario "Publish a banner with a translation different than the current locale", :js do
    visit new_admin_banner_path

    expect(page).to have_link "English"

    click_link "Remove language"
    select "Français", from: "translation_locale"

    fill_in "Title", with: "En Français"
    fill_in "Description", with: "Link en Français"

    fill_in "Link", with: "https://www.url.com"

    last_week = Time.current - 1.week
    next_week = Time.current + 1.week

    fill_in "Post started at", with: last_week.strftime("%d/%m/%Y")
    fill_in "Post ended at", with: next_week.strftime("%d/%m/%Y")

    click_button "Save changes"
    click_link "Edit banner"

    expect(page).to have_link "Français"
    expect(page).not_to have_link "English"
    expect(page).to have_field "Title", with: "En Français"
  end

  scenario "Update banner color when changing from color picker or text_field", :js do
    visit new_admin_banner_path

    fill_in "banner_background_color", with: "#850000"
    fill_in "banner_font_color", with: "#ffb2b2"
    fill_in "Title", with: "Fun with flags"

    # This last step simulates the blur event on the page. The color pickers and the text_fields
    # has onChange events that update each one when the other changes, but this is only fired when
    # the text_field loses the focus (color picker update when text_field changes). The first one
    # works because when the test fills in the second one, the first loses the focus
    # (so the onChange is fired). The second one never loses the focus, so the onChange is not been fired.
    # The `fill_in` action clicks out of the text_field and makes the field to lose the focus.

    expect(find("#banner_background_color_picker").value).to eq("#850000")
    expect(find("#banner_font_color_picker").value).to eq("#ffb2b2")
  end

  scenario "Edit banner with live refresh", :js do
    banner1 = create(:banner, title: "Hello",
                              description: "Wrong text",
                              target_url:  "http://www.url.com",
                              post_started_at: (Time.current + 4.days),
                              post_ended_at:   (Time.current + 10.days),
                              background_color: "#FF0000",
                              font_color: "#FFFFFF")

    visit admin_root_path

    within("#side_menu") do
      click_link "Site content"
      click_link "Manage banners"
    end

    click_link "Edit banner"

    fill_in "Title", with: "Modified title"
    fill_in "Description", with: "Edited text"

    page.find("body").click

    within("div#js-banner-background") do
      expect(page).to have_selector("h2", text: "Modified title")
      expect(page).to have_selector("h3", text: "Edited text")
    end

    click_button "Save changes"

    visit admin_banners_path
    expect(page).to have_content "Modified title"
    expect(page).to have_content "Edited text"

    expect(page).not_to have_content "Hello"
    expect(page).not_to have_content "Wrong text"
  end

  scenario "Delete a banner" do
    create(:banner, title: "Ugly banner",
                    description: "Bad text",
                    target_url:  "http://www.url.com",
                    post_started_at: (Time.current + 4.days),
                    post_ended_at:   (Time.current + 10.days),
                    background_color: "#FF0000",
                    font_color: "#FFFFFF")

    visit admin_root_path

    within("#side_menu") do
      click_link "Manage banners"
    end

    expect(page).to have_content "Ugly banner"

    click_link "Delete banner"

    visit admin_root_path
    expect(page).not_to have_content "Ugly banner"
  end
end
