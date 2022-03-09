require "rails_helper"

describe PagesController do
  describe "Static pages" do
    it "includes a privacy page" do
      get :show, params: { id: :privacy }
      expect(response).to be_ok
    end

    it "includes a conditions page" do
      get :show, params: { id: :conditions }
      expect(response).to be_ok
    end

    it "includes a accessibility page" do
      get :show, params: { id: :accessibility }
      expect(response).to be_ok
    end
  end

  describe "More info pages" do
    it "includes a more info page" do
      get :show, params: { id: "help/index" }
      expect(response).to be_ok
    end

    it "includes a how_to_use page" do
      get :show, params: { id: "help/how_to_use/index" }
      expect(response).to be_ok
    end

    it "includes a faq page" do
      get :show, params: { id: :faq }
      expect(response).to be_ok
    end
  end

  describe "Not found pages" do
    it "returns a 404 message" do
      get :show, params: { id: "nonExistentPage" }
      expect(response).to be_not_found
    end

    it "returns a 404 message for a JavaScript request" do
      get :show, params: { id: "nonExistentJavaScript.js" }
      expect(response).to be_not_found
    end

    it "returns a 404 message for draft pages" do
      create(:site_customization_page, slug: "other-slug", status: "draft")

      get :show, params: { id: "other-slug" }

      expect(response).to be_not_found
    end
  end
end
