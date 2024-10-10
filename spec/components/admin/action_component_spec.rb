require "rails_helper"

describe Admin::ActionComponent do
  describe "method" do
    it "is not included by default for most actions" do
      render_inline Admin::ActionComponent.new(:create, double, path: "/")

      expect(page).to have_link count: 1
      expect(page).not_to have_button
      expect(page).not_to have_css "[data-method]"
    end

    it "is included in the link when the method is get" do
      render_inline Admin::ActionComponent.new(:create, double, path: "/", method: :get)

      expect(page).to have_link count: 1
      expect(page).to have_css "a[data-method='get']"
      expect(page).not_to have_button
    end

    it "defaults to :delete for the destroy action" do
      render_inline Admin::ActionComponent.new(:destroy, double, path: "/")

      expect(page).to have_css "input[name='_method']", visible: :all, count: 1
      expect(page).to have_css "input[name='_method'][value='delete']", visible: :hidden
    end

    it "can be overriden for the destroy action" do
      render_inline Admin::ActionComponent.new(:destroy, double, path: "/", method: :put)

      expect(page).to have_css "input[name='_method']", visible: :all, count: 1
      expect(page).to have_css "input[name='_method'][value='put']", visible: :hidden
    end
  end

  describe "HTML class" do
    it "includes an HTML class for the action by default" do
      render_inline Admin::ActionComponent.new(:edit, double, path: "/")

      expect(page).to have_link class: %w[edit-link admin-action]
    end

    it "keeps the admin-action class when the class is overwritten" do
      render_inline Admin::ActionComponent.new(:edit, double, path: "/", class: "modify-link")

      expect(page).to have_link class: %w[modify-link admin-action]
      expect(page).not_to have_css ".edit-link"
    end
  end

  describe "HTML id" do
    it "is not rendered for non-ActiveModel records" do
      render_inline Admin::ActionComponent.new(:edit, double, path: "/")

      expect(page).not_to have_css "[id]"
    end

    it "includes an id based on the model and the action by default" do
      record = double(model_name: double(param_key: "computer"), to_key: [1])

      render_inline Admin::ActionComponent.new(:edit, record, path: "/")

      expect(page).to have_link class: "edit-link", id: "edit_computer_1"
    end

    it "can be overwritten" do
      record = double(model_name: double(param_key: "computer"), to_key: [1])

      render_inline Admin::ActionComponent.new(:edit, record, path: "/", id: "my_id")

      expect(page).to have_link class: "edit-link", id: "my_id"
      expect(page).not_to have_css "#edit_computer_1"
    end
  end

  describe "aria-describedby attribute" do
    it "is not rendered by default" do
      render_inline Admin::ActionComponent.new(:edit, double, path: "/")

      expect(page).to have_link count: 1
      expect(page).not_to have_css "[aria-describedby]"
    end

    it "renders with the given value" do
      render_inline Admin::ActionComponent.new(:edit, double, path: "/", "aria-describedby": "my_descriptor")

      expect(page).to have_link count: 1
      expect(page).to have_css "[aria-describedby='my_descriptor']"
    end

    it "renders a default value when aria-describedby is true" do
      record = double(model_name: double(param_key: "book"), to_key: [23])

      render_inline Admin::ActionComponent.new(:edit, record, path: "/", "aria-describedby": true)

      expect(page).to have_link count: 1
      expect(page).to have_css "[aria-describedby='edit_book_23_descriptor']"
    end
  end

  describe "aria-label attribute" do
    it "is not rendered by default" do
      record = double(human_name: "Stay home")

      render_inline Admin::ActionComponent.new(:edit, record, path: "/")

      expect(page).to have_link count: 1
      expect(page).not_to have_css "[aria-label]"
    end

    it "is not rendered when aria-label is nil" do
      render_inline Admin::ActionComponent.new(:edit, double, path: "/", "aria-label": nil)

      expect(page).to have_link count: 1
      expect(page).not_to have_css "[aria-label]"
    end

    it "renders with the given value" do
      render_inline Admin::ActionComponent.new(:edit, double, path: "/", "aria-label": "Modify")

      expect(page).to have_link count: 1
      expect(page).to have_css "[aria-label='Modify']"
    end

    context "when aria-label is true" do
      it "includes the action and the human_name of the record" do
        record = double(human_name: "Stay home")

        render_inline Admin::ActionComponent.new(:edit, record, path: "/", "aria-label": true)

        expect(page).to have_link count: 1
        expect(page).to have_css "a[aria-label='Edit Stay home']", exact_text: "Edit"
      end

      it "uses the to_s method when there's no human_name" do
        record = double(to_s: "do_not_go_out")

        render_inline Admin::ActionComponent.new(:edit, record, path: "/", "aria-label": true)

        expect(page).to have_link count: 1
        expect(page).to have_css "a[aria-label='Edit Do not go out']", exact_text: "Edit"
      end

      it "uses the human_name when there are both human_name and to_s" do
        record = double(human_name: "Stay home", to_s: "do_not_go_out")

        render_inline Admin::ActionComponent.new(:edit, record, path: "/", "aria-label": true)

        expect(page).to have_link count: 1
        expect(page).to have_css "a[aria-label='Edit Stay home']", exact_text: "Edit"
      end
    end
  end

  describe "data-confirm attribute" do
    it "is not rendered by default" do
      render_inline Admin::ActionComponent.new(:edit, double, path: "/")

      expect(page).to have_link count: 1
      expect(page).not_to have_css "[data-confirm]"
    end

    it "is not rendered when confirm is nil" do
      render_inline Admin::ActionComponent.new(:edit, double, path: "/", confirm: nil)

      expect(page).to have_link count: 1
      expect(page).not_to have_css "[data-confirm]"
    end

    it "renders with the given value" do
      render_inline Admin::ActionComponent.new(:edit, double, path: "/", confirm: "Really?")

      expect(page).to have_link count: 1
      expect(page).to have_css "[data-confirm='Really?']"
    end

    context "when confirm is true" do
      it "uses the human name as default" do
        record = double(human_name: "Everywhere and nowhere")
        text = 'Are you sure? Edit "Everywhere and nowhere"'

        render_inline Admin::ActionComponent.new(:edit, record, path: "/", confirm: true)

        expect(page).to have_link count: 1
        expect(page).to have_css "[data-confirm='#{text}']"
      end

      it "includes a more detailed message for the destroy action" do
        record = double(human_name: "Participatory Budget 2015")
        text = 'Are you sure? This action will delete "Participatory Budget 2015" and can\\\'t be undone.'

        render_inline Admin::ActionComponent.new(:destroy, record, path: "/", confirm: true)

        expect(page).to have_button count: 1
        expect(page).to have_css "[data-confirm='#{text}']"
      end
    end
  end

  describe "data-disable-with attribute" do
    it "is not rendered for links" do
      render_inline Admin::ActionComponent.new(:edit, double, path: "/")

      expect(page).not_to have_css "[data-disable-with]"
    end

    it "is rendered for buttons" do
      render_inline Admin::ActionComponent.new(:hide, double, path: "/", method: :delete)

      expect(page).to have_css "button[data-disable-with='Hide']"
    end
  end
end
