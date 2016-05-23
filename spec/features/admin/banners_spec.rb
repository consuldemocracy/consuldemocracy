require 'rails_helper'

feature 'Admin add banners' do

  background do
    @banner1 = create(:banner, title: "Banner number one", 
                description:  "This is the text of banner number one and is not active yet",
                target_url:  "http://www.url.com",
                style: "banner-style.banner-one",
                image: "banner-img.banner-one",
                post_started_at: (Time.now + 4.days),
                post_ended_at:   (Time.now + 10.days))

    @banner2 = create(:banner, title: "Banner number two", 
                description:  "This is the text of banner number two and is not longer active",
                target_url:  "http://www.url.com",
                style: "banner-style.banner-two",
                image: "banner-img.banner-two",
                post_started_at: (Time.now - 10.days),
                post_ended_at:   (Time.now - 3.days))

    @banner3 = create(:banner, title: "Banner number three", 
                description:  "This is the text of banner number three and has style banner-three",
                target_url:  "http://www.url.com",
                style: "banner-style.banner-three",
                image: "banner-img.banner-three",
                post_started_at: (Time.now - 1.days),
                post_ended_at:   (Time.now + 10.days))

    @banner4 = create(:banner, title: "Banner number four", 
                description:  "This is the text of banner number four and has style banner-one",
                target_url:  "http://www.url.com",
                style: "banner-style.banner-one",
                image: "banner-img.banner-one",
                post_started_at: (DateTime.now - 10.days),
                post_ended_at:   (DateTime.now + 10.days))

    @banner5 = create(:banner, title: "Banner number five", 
                description:  "This is the text of banner number five and has style banner-two",
                target_url:  "http://www.url.com",
                style: "banner-style.banner-one",
                image: "banner-img.banner-one",
                post_started_at: (DateTime.now - 10.days),
                post_ended_at:   (DateTime.now + 10.days))

    login_as(create(:administrator).user)
  end

  scenario 'option publish banners is listed on admin menu' do
    visit admin_root_path

    within('#admin_menu') do
      expect(page).to have_link "Publish banner"
    end
  end

  scenario 'index show active banners' do
    visit admin_banners_path(filter: 'with_active')
    expect(page).to have_content("There are 3 banners")
  end

  scenario 'index show inactive banners' do
    visit admin_banners_path(filter: 'with_inactive')
    expect(page).to have_content("There are 2 banners")
  end

  scenario 'index show all banners' do
    visit admin_banners_path
    expect(page).to have_content("There are 5 banners")
  end

  scenario 'refresh changes on edit banner', :js do
    visit edit_admin_banner_path(@banner1)

    fill_in 'banner_title', with: 'Titulo modificado'
    fill_in 'banner_description', with: 'Texto modificado'

    within('div#js-banner-style') do
      expect(page).to have_selector('h2', :text => 'Titulo modificado')
      expect(page).to have_selector('h3', :text => 'Texto modificado')
    end
  end

  scenario 'refresh changes on edit banner', :js do
    visit edit_admin_banner_path(@banner1)
    

    fill_in 'banner_title', with: 'Titulo modificado'
    fill_in 'banner_description', with: 'Texto modificado'

    within('div#js-banner-style') do
      expect(page).to have_selector('h2', :text => 'Titulo modificado')
      expect(page).to have_selector('h3', :text => 'Texto modificado')
    end
  end

  scenario 'option Publish banners is listed on admin menu' do
    visit admin_banners_path

    within('#admin_menu') do
      expect(page).to have_link "Publish banner"
    end
  end

end