shared_examples "relationable" do |relationable_model_name|

  let(:relationable) { create(relationable_model_name) }
  let(:related1) { create([:proposal, :debate].sample) }
  let(:related2) { create([:proposal, :debate].sample) }
  let(:user) { create(:user) }

  scenario 'related contents are listed' do
    related_content = create(:related_content, parent_relationable: relationable, child_relationable: related1)

    visit eval("#{relationable.class.name.downcase}_path(relationable)")
    within("#related-content-list") do
      expect(page).to have_content(related1.title)
    end

    visit eval("#{related1.class.name.downcase}_path(related1)")
    within("#related-content-list") do
      expect(page).to have_content(relationable.title)
    end
  end

  scenario 'related contents list is not rendered if there are no relations' do
    visit eval("#{relationable.class.name.downcase}_path(relationable)")
    expect(page).to_not have_css("#related-content-list")
  end

  scenario 'related contents can be added' do
    visit eval("#{relationable.class.name.downcase}_path(relationable)")

    expect(page).to have_selector('#related_content', visible: false)
    click_on("Add related content")
    expect(page).to have_selector('#related_content', visible: true)

    within("#related_content") do
      fill_in 'url', with: "#{Setting['url']}/#{related1.class.name.downcase.pluralize}/#{related1.to_param}"
      click_button "Add"
    end

    within("#related-content-list") do
      expect(page).to have_content(related1.title)
    end

    visit eval("#{related1.class.name.downcase}_path(related1)")

    within("#related-content-list") do
      expect(page).to have_content(relationable.title)
    end

    within("#related_content") do
      fill_in 'url', with: "#{Setting['url']}/#{related2.class.name.downcase.pluralize}/#{related2.to_param}"
      click_button "Add"
    end

    within("#related-content-list") do
      expect(page).to have_content(related2.title)
    end
  end

  scenario 'if related content URL is invalid returns error' do
    visit eval("#{relationable.class.name.downcase}_path(relationable)")

    click_on("Add related content")

    within("#related_content") do
      fill_in 'url', with: "http://invalidurl.com"
      click_button "Add"
    end

    expect(page).to have_content("Link not valid. Remember to start with #{Setting[:url]}.")
  end

  scenario 'related content can be flagged', :js do
    related_content = create(:related_content, parent_relationable: relationable, child_relationable: related1)

    login_as(user)
    visit eval("#{relationable.class.name.downcase}_path(relationable)")

    within("#related-content-list") do
      expect(page).to have_css("#flag-expand-related-#{related_content.opposite_related_content.id}")
      find("#flag-expand-related-#{related_content.opposite_related_content.id}").click
      expect(page).to have_css("#flag-drop-related-#{related_content.opposite_related_content.id}", visible: true)
      click_link("flag-related-#{related_content.opposite_related_content.id}")

      expect(page).to have_css("#unflag-expand-related-#{related_content.opposite_related_content.id}")
    end

    expect(related_content.reload.flags_count).to eq(1)
    expect(related_content.opposite_related_content.flags_count).to eq(1)
  end

  scenario 'if related content has been flagged more than 5 times it will be hidden', :js do
    related_content = create(:related_content, parent_relationable: relationable, child_relationable: related1)

    related_content.flags_count = Setting['related_contents_report_threshold'].to_i + 1
    related_content.opposite_related_content.flags_count = related_content.flags_count

    related_content.save
    related_content.opposite_related_content.save

    login_as(user)
    visit eval("#{relationable.class.name.downcase}_path(relationable)")

    expect(page).to_not have_css("#related-content-list")
  end
end
