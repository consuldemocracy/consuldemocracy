require "rails_helper"

feature "Custom content blocks" do
  scenario "top links" do
    create(:site_customization_content_block, name: "top_links", locale: "en",
                                              body: "content for top links")
    create(:site_customization_content_block, name: "top_links", locale: "es",
                                              body: "contenido para top links")

    visit "/?locale=en"

    expect(page).to have_content("content for top links")
    expect(page).not_to have_content("contenido para top links")

    visit "/?locale=es"

    expect(page).to have_content("contenido para top links")
    expect(page).not_to have_content("content for top links")
  end

  scenario "footer" do
    create(:site_customization_content_block, name: "footer", locale: "en",
                                              body: "content for footer")
    create(:site_customization_content_block, name: "footer", locale: "es",
                                              body: "contenido para footer")

    visit "/?locale=en"

    expect(page).to have_content("content for footer")
    expect(page).not_to have_content("contenido para footer")

    visit "/?locale=es"

    expect(page).to have_content("contenido para footer")
    expect(page).not_to have_content("content for footer")
  end

  scenario "main navigation left" do
    create(:site_customization_content_block, name: "subnavigation_left", locale: "en",
                                              body: "content for left links")
    create(:site_customization_content_block, name: "subnavigation_left", locale: "es",
                                              body: "contenido para left links")

    visit "/?locale=en"

    expect(page).to have_content("content for left links")
    expect(page).not_to have_content("contenido para left links")

    visit "/?locale=es"

    expect(page).to have_content("contenido para left links")
    expect(page).not_to have_content("content for left links")
  end

  scenario "main navigation right" do
    create(:site_customization_content_block, name: "subnavigation_right", locale: "en",
                                              body: "content for right links")
    create(:site_customization_content_block, name: "subnavigation_right", locale: "es",
                                              body: "contenido para right links")

    visit "/?locale=en"

    expect(page).to have_content("content for right links")
    expect(page).not_to have_content("contenido para right links")

    visit "/?locale=es"

    expect(page).to have_content("contenido para right links")
    expect(page).not_to have_content("content for left links")
  end
end
