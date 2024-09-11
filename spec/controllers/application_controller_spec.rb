require "rails_helper"

describe ApplicationController do
  controller do
    skip_authorization_check

    def index
      render plain: I18n.locale
    end
  end

  describe "#current_budget" do
    it "returns the last budget that is not in draft phase" do
      create(:budget, :finished,  created_at: 2.years.ago, name: "Old")
      create(:budget, :accepting, created_at: 1.year.ago,  name: "Previous")
      create(:budget, :accepting, created_at: 1.month.ago, name: "Current")
      create(:budget, :drafting,  created_at: 1.week.ago,  name: "Next")

      budget = subject.instance_eval { current_budget }
      expect(budget.name).to eq("Current")
    end
  end

  describe "#switch_locale" do
    it "uses the default locale by default" do
      Setting["locales.default"] = "pt-BR"

      get :index

      expect(response.body).to eq "pt-BR"
    end

    it "uses the locale in the parameters when it's there" do
      get :index, params: { locale: :es }

      expect(response.body).to eq "es"
    end

    it "uses the locale in the session if there are no parameters" do
      get :index, params: { locale: :es }

      expect(response.body).to eq "es"

      get :index

      expect(response.body).to eq "es"
    end

    it "uses the locale in the parameters even when it's in the session" do
      get :index

      expect(response.body).to eq "en"

      get :index, params: { locale: :es }

      expect(response.body).to eq "es"
    end

    it "only accepts enabled locales" do
      Setting["locales.enabled"] = "en es fr"

      get :index, params: { locale: :es }

      expect(response.body).to eq "es"

      get :index, params: { locale: :de }

      expect(response.body).to eq "es"

      get :index, params: { locale: :fr }

      expect(response.body).to eq "fr"
    end

    context "authenticated user" do
      let(:user) { create(:user) }
      before { sign_in(user) }

      it "updates the prefered locale when it's in the parameters" do
        get :index, params: { locale: :es }

        expect(user.reload.locale).to eq "es"
        expect(response.body).to eq "es"
      end
    end
  end
end
