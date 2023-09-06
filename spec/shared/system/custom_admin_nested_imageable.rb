shared_examples "admin nested imageable" do |imageable_factory_name, path, imageable_path_arguments,
                                             fill_resource_method_name, submit_button, imageable_success_notice,
                                             has_many_images = false, management: false|
  let!(:user)                { create(:user, :level_two) }
  let!(:arguments)           { {} }
  let!(:imageable)           { create(imageable_factory_name) }
  let(:management)           { management }

  before do
    create(:administrator, user: user)

    imageable_path_arguments&.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": imageable.send(path_to_value))
    end

    imageable.update!(author: user) if imageable.respond_to?(:author)
  end

  describe "at #{path}" do
    if path.include? "edit"
      scenario "show persisted image" do
        create(:image, imageable: imageable)
        do_login_for user, management: management

        visit send(path, arguments)

        expect(page).to have_css ".image", count: 1
        expect(page).not_to have_css "a#new_image_link"
      end

      scenario "remove nested field after removing the image" do
        create(:image, imageable: imageable)
        do_login_for user, management: management

        visit send(path, arguments)
        click_link "Remove image"

        expect(page).not_to have_css ".image"
        expect(page).to have_css "a#new_image_link"
      end

      scenario "don't duplicate fields after removing and adding an image" do
        create(:image, imageable: imageable)
        do_login_for user, management: management

        visit send(path, arguments)
        click_link "Remove image"
        click_link "Add image"

        expect(page).to have_css ".image", count: 1, visible: :all
      end
    end
  end
end
