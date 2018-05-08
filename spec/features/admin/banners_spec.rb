require 'rails_helper'

feature 'Admin banners magement' do

  background do
    login_as(create(:administrator).user)
  end

  context "Index" do
    background do
      @banner1 = create(:banner, title: "Banner number one",
                  description:  "This is the text of banner number one and is not active yet",
                  target_url:  "http://www.url.com",
                  style: "banner-style.banner-one",
                  image: "banner-img.banner-one",
                  post_started_at: (Time.current + 4.days),
                  post_ended_at:   (Time.current + 10.days))

      @banner2 = create(:banner, title: "Banner number two",
                  description:  "This is the text of banner number two and is not longer active",
                  target_url:  "http://www.url.com",
                  style: "banner-style.banner-two",
                  image: "banner-img.banner-two",
                  post_started_at: (Time.current - 10.days),
                  post_ended_at:   (Time.current - 3.days))

      @banner3 = create(:banner, title: "Banner number three",
                  description:  "This is the text of banner number three and has style banner-three",
                  target_url:  "http://www.url.com",
                  style: "banner-style.banner-three",
                  image: "banner-img.banner-three",
                  post_started_at: (Time.current - 1.day),
                  post_ended_at:   (Time.current + 10.days))

      @banner4 = create(:banner, title: "Banner number four",
                  description:  "This is the text of banner number four and has style banner-one",
                  target_url:  "http://www.url.com",
                  style: "banner-style.banner-one",
                  image: "banner-img.banner-one",
                  post_started_at: (DateTime.current - 10.days),
                  post_ended_at:   (DateTime.current + 10.days))

      @banner5 = create(:banner, title: "Banner number five",
                  description:  "This is the text of banner number five and has style banner-two",
                  target_url:  "http://www.url.com",
                  style: "banner-style.banner-one",
                  image: "banner-img.banner-one",
                  post_started_at: (DateTime.current - 10.days),
                  post_ended_at:   (DateTime.current + 10.days))
    end

    scenario 'Index show active banners' do
      visit admin_banners_path(filter: 'with_active')
      expect(page).to have_content("There are 3 banners")
    end

    scenario 'Index show inactive banners' do
      visit admin_banners_path(filter: 'with_inactive')
      expect(page).to have_content("There are 2 banners")
    end

    scenario 'Index show all banners' do
      visit admin_banners_path
      expect(page).to have_content("There are 5 banners")
    end
  end

  scenario 'Banners publication is listed on admin menu' do
    visit admin_root_path

    within('#side_menu') do
      expect(page).to have_link "Manage banners"
    end
  end

  scenario 'Publish a banner' do
    visit admin_root_path

    within('#side_menu') do
      click_link "Manage banners"
    end

    click_link "Create banner"

    select 'Banner style 1', from: 'banner_style'
    select 'Banner image 2', from: 'banner_image'
    fill_in 'banner_title', with: 'Such banner'
    fill_in 'banner_description', with: 'many text wow link'
    fill_in 'banner_target_url', with: 'https://www.url.com'
    last_week = Time.current - 7.days
    next_week = Time.current + 7.days
    fill_in 'post_started_at', with: last_week.strftime("%d/%m/%Y")
    fill_in 'post_ended_at', with: next_week.strftime("%d/%m/%Y")

    click_button 'Save changes'

    expect(page).to have_content 'Such banner'

    visit proposals_path

    expect(page).to have_content 'Such banner'
    expect(page).to have_link 'Such banner many text wow link', href: 'https://www.url.com'
  end

  scenario 'Edit banner with live refresh', :js do
    banner1 = create(:banner, title: 'Hello',
                              description: 'Wrong text',
                              target_url:  'http://www.url.com',
                              style: 'banner-style.banner-one',
                              image: 'banner-img.banner-one',
                              post_started_at: (Time.current + 4.days),
                              post_ended_at:   (Time.current + 10.days))

    visit admin_root_path

    within('#side_menu') do
      click_link "Site content"
      click_link "Manage banners"
    end

    click_link "Edit banner"

    fill_in 'banner_title', with: 'Modified title'
    fill_in 'banner_description', with: 'Edited text'
    select 'Banner style 1', from: 'banner_style'
    select 'Banner image 2', from: 'banner_image'

    within('div#js-banner-style') do
      expect(page).to have_selector('h2', text: 'Modified title')
      expect(page).to have_selector('h3', text: 'Edited text')
    end

    click_button 'Save changes'

    visit admin_banners_path
    expect(page).to have_content 'Modified title'
    expect(page).to have_content 'Edited text'

    expect(page).not_to have_content 'Hello'
    expect(page).not_to have_content 'Wrong text'
  end

  scenario 'Delete a banner' do
    create(:banner, title: 'Ugly banner',
                    description: 'Bad text',
                    target_url:  'http://www.url.com',
                    style: 'banner-style.banner-one',
                    image: 'banner-img.banner-one',
                    post_started_at: (Time.current + 4.days),
                    post_ended_at:   (Time.current + 10.days))

    visit admin_root_path

    within("#side_menu") do
      click_link "Manage banners"
    end

    expect(page).to have_content 'Ugly banner'

    click_link "Delete banner"

    visit admin_root_path
    expect(page).not_to have_content 'Ugly banner'
  end

end
