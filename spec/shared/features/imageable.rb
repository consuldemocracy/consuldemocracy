shared_examples "imageable" do |imageable_factory_name, imageable_path, imageable_path_arguments|
  include ActionView::Helpers
  include ImagesHelper
  include ImageablesHelper

  let!(:administrator)          { create(:user) }
  let!(:user)                   { create(:user) }
  let!(:imageable_arguments)    { {} }
  let!(:imageables_arguments)   { {} }
  let!(:imageable)              { create(imageable_factory_name, author: user) }
  let!(:imageable_dom_name)     { imageable_factory_name.parameterize }

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

      expect(page).to have_css("img[alt='#{image.title}']")
    end

    scenario "Show image title when image exists" do
      image = create(:image, imageable: imageable)

      visit send(imageable_path, imageable_arguments)

      expect(page).to have_content image.title
    end

    scenario "Should not display upload image button when there is no logged user" do
      visit send(imageable_path, imageable_arguments)

      within "##{dom_id(imageable)}" do
        expect(page).not_to have_link("Upload image")
      end
    end

    scenario "Should not display upload image button when maximum number of images reached " do
      create_list(:image, 3, imageable: imageable)
      visit send(imageable_path, imageable_arguments)

      within "##{dom_id(imageable)}" do
        expect(page).not_to have_link("Upload image")
      end
    end

    scenario "Should display upload image button when user is logged in and is imageable owner" do
      login_as(user)

      visit send(imageable_path, imageable_arguments)

      within "##{dom_id(imageable)}" do
        expect(page).to have_link("Upload image")
      end
    end

    scenario "Should display upload image button when admin is logged in" do
      login_as(administrator)

      visit send(imageable_path, imageable_arguments)

      within "##{dom_id(imageable)}" do
        expect(page).to have_link("Upload image")
      end
    end

    scenario "Should navigate to new image page when click un upload button" do
      login_as(user)

      visit send(imageable_path, imageable_arguments)
      click_link  "Upload image"

      expect(page).to have_selector("h1", text: "Upload image")
    end

  end

  context "New" do

    scenario "Should not be able for unathenticated users" do
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      expect(page).to have_content("You must sign in or register to continue.")
    end

    scenario "Should not be able for other users" do
      login_as create(:user)

      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      expect(page).to have_content("You do not have permission to carry out the action 'new' on image.")
    end

    scenario "Should be able to imageable author" do
      login_as imageable.author

      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      expect(page).to have_selector("h1", text: "Upload image")
    end

    scenario "Should show imageable custom recomentations" do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id,
                           from: send(imageable_path, imageable_arguments))

      expect(page).to have_content(image_first_recommendation(Image.new(imageable: imageable)))
      expect(page).to have_content "You can upload images in following formats:  #{imageable_humanized_accepted_content_types}."
      expect(page).to have_content "You can upload one image up to 1 MB."
    end

    scenario "Should display attachment validation errors after invalid image upload", :js do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      attach_file :image_attachment, "spec/fixtures/files/logo_header.png", make_visible: true

      expect(page).to have_css "small.error"
    end

    scenario "Should display file name after image selection", :js do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      attach_file :image_attachment, "spec/fixtures/files/empty.pdf", make_visible: true

      expect(page).to have_content "empty.pdf"
    end

    scenario "Should not display file name after invalid image upload", :js do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      attach_file :image_attachment, "spec/fixtures/files/clippy.png", make_visible: true

      expect(page).to have_css ".loading-bar.errors"
      expect(page).not_to have_content "clippy.png"
    end

    scenario "Should display cached image without caption after valid image upload", :js do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      attach_file :image_attachment, "spec/fixtures/files/clippy.jpg", make_visible: true

      expect(page).to have_css("figure img")
      expect(page).not_to have_css("figure figcaption")
    end

    scenario "Should update loading bar style after valid file upload", :js do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      attach_file :image_attachment, "spec/fixtures/files/clippy.jpg", make_visible: true

      expect(page).to have_selector ".loading-bar.complete"
    end

    scenario "Should update loading bar style after invalid file upload", :js do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      attach_file :image_attachment, "spec/fixtures/files/logo_header.png", make_visible: true

      expect(page).to have_selector ".loading-bar.errors"
    end

    scenario "Should update image title with attachment original file name after valid image upload", :js do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      attach_file :image_attachment, "spec/fixtures/files/clippy.jpg", make_visible: true

      expect(page).to have_css("input[name='image[title]'][value='clippy.jpg']", visible: false)
    end

    scenario "Should not update image title with attachment original file name after valid image upload when title already defined by user", :js do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      fill_in :image_title, with: "My custom title"
      attach_file :image_attachment, "spec/fixtures/files/clippy.jpg", make_visible: true

      expect(page).to have_selector ".loading-bar.complete"
      expect(page).to have_css("input[name='image[title]'][value='My custom title']", visible: false)
    end

    scenario "Should update image cached_attachment field after valid file upload", :js do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      attach_file :image_attachment, "spec/fixtures/files/clippy.jpg", make_visible: true

      expect(page).to have_css("input[name='image[cached_attachment]'][value$='clippy.jpg']", visible: false)
    end

    scenario "Should not update image cached_attachment field after invalid file upload", :js do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      attach_file :image_attachment, "spec/fixtures/files/logo_header.png", make_visible: true

      expect(page).to have_selector ".loading-bar.errors"
      expect(find("input[name='image[cached_attachment]']", visible: false).value).to eq("")
    end

  end

  context "Create" do

    scenario "Should show validation errors" do
      login_as imageable.author
      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id)

      click_on "Upload image"

      expect(page).to have_content "3 errors prevented this Image from being saved: "
      expect(page).to have_selector "small.error", text: "can't be blank", count: 2
    end

    scenario "Should show error notice after unsuccessfull image upload" do
      login_as imageable.author

      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id,
                           from: send(imageable_path, imageable_arguments))
      attach_file :image_attachment, "spec/fixtures/files/empty.pdf"
      click_on "Upload image"

      expect(page).to have_content "Cannot create image. Check form errors and try again."
    end

    scenario "Should show success notice after successfull image upload" do
      login_as imageable.author

      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id,
                           from: send(imageable_path, imageable_arguments))
      fill_in :image_title, with: "Image title"
      attach_file :image_attachment, "spec/fixtures/files/clippy.jpg"
      click_on "Upload image"

      expect(page).to have_content "Image was created successfully."
    end

    scenario "Should redirect to imageable path after successfull image upload" do
      login_as imageable.author

      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id,
                           from: send(imageable_path, imageable_arguments))
      fill_in :image_title, with: "Image title"
      attach_file :image_attachment, "spec/fixtures/files/clippy.jpg"
      click_on "Upload image"

      within "##{dom_id(imageable)}" do
        expect(page).to have_selector "h1", text: imageable.title
      end
    end

    scenario "Should show new image on imageable images tab after successfull image upload" do
      login_as imageable.author

      visit new_image_path(imageable_type: imageable.class.name,
                           imageable_id: imageable.id,
                           from: send(imageable_path, imageable_arguments))
      fill_in :image_title, with: "Image title"
      attach_file :image_attachment, "spec/fixtures/files/clippy.jpg"
      click_on "Upload image"

      expect(page).to have_content "Image title"
    end

  end

  context "Destroy" do

    let!(:image) { create(:image, imageable: imageable, user: imageable.author) }

    scenario "Should show success notice after successfull deletion by an admin" do
      login_as administrator

      visit send(imageable_path, imageable_arguments)
      click_on "Remove image"

      expect(page).to have_content "Image was deleted successfully."
    end

    scenario "Should show success notice after successfull deletion" do
      login_as imageable.author

      visit send(imageable_path, imageable_arguments)
      click_on "Remove image"

      expect(page).to have_content "Image was deleted successfully."
    end

    scenario "Should not show image after successful deletion" do
      login_as imageable.author

      visit send(imageable_path, imageable_arguments)
      click_on "Remove image"

      expect(page).not_to have_selector "figure img"
    end

    scenario "Should redirect to imageable path after successful deletion" do
      login_as imageable.author

      visit send(imageable_path, imageable_arguments)
      click_on "Remove image"

      within "##{dom_id(imageable)}" do
        expect(page).to have_selector "h1", text: imageable.title
      end
    end

  end

end
