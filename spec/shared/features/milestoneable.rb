shared_examples "milestoneable" do |factory_name, path_name|
  it_behaves_like "progressable", factory_name, path_name

  let!(:milestoneable) { create(factory_name) }

  feature "Show milestones" do
    let(:path) { send(path_name, *resource_hierarchy_for(milestoneable)) }

    scenario "Show milestones", :js do
      create(:milestone, milestoneable: milestoneable,
                         description_en: "Last milestone with a link to https://consul.dev",
                         description_es: "Último hito con el link https://consul.dev",
                         publication_date: Date.tomorrow)

      first_milestone = create(:milestone, milestoneable: milestoneable,
                                           description: "First milestone",
                                           publication_date: Date.yesterday)
      image = create(:image, imageable: first_milestone)
      document = create(:document, documentable: first_milestone)

      login_as(create(:user))
      visit path

      find("#tab-milestones-label").click

      within("#tab-milestones") do
        expect(first_milestone.description).to appear_before("Last milestone with a link to https://consul.dev")
        expect(page).to have_content(Date.tomorrow)
        expect(page).to have_content(Date.yesterday)
        expect(page).not_to have_content(Date.current)
        expect(page.find("#image_#{first_milestone.id}")["alt"]).to have_content(image.title)
        expect(page).to have_link(document.title)
        expect(page).to have_link("https://consul.dev")
        expect(page).to have_content(first_milestone.status.name)
      end

      select("Español", from: "locale-switcher")

      find("#tab-milestones-label").click

      within("#tab-milestones") do
        expect(page).to have_content("Último hito con el link https://consul.dev")
        expect(page).to have_link("https://consul.dev")
      end
    end

    scenario "Show no_milestones text", :js do
      login_as(create(:user))

      visit path

      find("#tab-milestones-label").click

      within("#tab-milestones") do
        expect(page).to have_content("Don't have defined milestones")
      end
    end
  end
end
