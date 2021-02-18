shared_examples "imageable" do |imageable_factory_name, imageable_path, imageable_path_arguments|
  let!(:administrator)       { create(:user) }
  let!(:user)                { create(:user) }
  let!(:imageable_arguments) { {} }
  let!(:imageable)           { create(imageable_factory_name, author: user) }

  before do
    create(:administrator, user: administrator)

    imageable_path_arguments.each do |argument_name, path_to_value|
      imageable_arguments.merge!("#{argument_name}": imageable.send(path_to_value))
    end
  end

  context "Show" do
    scenario "Show descriptive image when exists", :js do
      image = create(:image, imageable: imageable)

      visit send(imageable_path, imageable_arguments)

      expect(page).to have_css("img[alt='#{image.title}'][title='#{image.title}']")
    end

    scenario "Show image title when image exists" do
      image = create(:image, imageable: imageable)

      visit send(imageable_path, imageable_arguments)

      expect(page).to have_content image.title
    end
  end
end

def attach_image(path, success = true)
  image = find(".image")
  image_input = image.find("input[type=file]", visible: false)
  attach_file image_input[:id], path, make_visible: true
  if success
    expect(page).to have_css ".loading-bar.complete"
  else
    expect(page).to have_css ".loading-bar.errors"
  end
end
