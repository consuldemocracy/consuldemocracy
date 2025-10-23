require "rails_helper"

describe "Custom content blocks" do
  scenario "top links" do
    create(:site_customization_content_block, name: "top_links", locale: "en",
                                              body: "<li>content for top links</li>")
    create(:site_customization_content_block, name: "top_links", locale: "es",
                                              body: "<li>contenido para top links</li>")

    visit "/?locale=en"

    expect(page).to have_content("content for top links")
    expect(page).not_to have_content("contenido para top links")

    visit "/?locale=es"

    expect(page).to have_content("contenido para top links")
    expect(page).not_to have_content("content for top links")
  end

  scenario "footer" do
    create(:site_customization_content_block, name: "footer", locale: "en",
                                              body: "<li>content for footer</li>")
    create(:site_customization_content_block, name: "footer", locale: "es",
                                              body: "<li>contenido para footer</li>")

    visit "/?locale=en"

    within ".social" do
      expect(page).to have_content("content for footer")
      expect(page).not_to have_content("contenido para footer")
    end

    visit "/?locale=es"

    within ".social" do
      expect(page).to have_content("contenido para footer")
      expect(page).not_to have_content("content for footer")
    end
  end

  scenario "footer_legal content block" do
    create(:site_customization_content_block, name: "footer_legal", locale: "en",
                                              body: "<li>legal content for footer</li>")
    create(:site_customization_content_block, name: "footer_legal", locale: "es",
                                              body: "<li>contenido legal para el footer</li>")

    visit "/?locale=en"

    within ".legal" do
      expect(page).to have_content("legal content for footer")
      expect(page).not_to have_content("contenido legal para el footer")
    end

    visit "/?locale=es"
    within ".legal" do
      expect(page).to have_content("contenido legal para el footer")
      expect(page).not_to have_content("legal content for footer")
    end
  end

  scenario "main navigation left" do
    create(:site_customization_content_block, name: "subnavigation_left", locale: "en",
                                              body: "<li>content for left links</li>")
    create(:site_customization_content_block, name: "subnavigation_left", locale: "es",
                                              body: "<li>contenido para left links</li>")

    visit "/?locale=en"

    expect(page).to have_content("content for left links")
    expect(page).not_to have_content("contenido para left links")

    visit "/?locale=es"

    expect(page).to have_content("contenido para left links")
    expect(page).not_to have_content("content for left links")
  end

  scenario "main navigation right" do
    create(:site_customization_content_block, name: "subnavigation_right", locale: "en",
                                              body: "<li>content for right links</li>")
    create(:site_customization_content_block, name: "subnavigation_right", locale: "es",
                                              body: "<li>contenido para right links</li>")

    visit "/?locale=en"

    expect(page).to have_content("content for right links")
    expect(page).not_to have_content("contenido para right links")

    visit "/?locale=es"

    expect(page).to have_content("contenido para right links")
    expect(page).not_to have_content("content for left links")
  end
end
