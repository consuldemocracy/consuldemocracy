# frozen_string_literal: true

require "rails_helper"

describe Admin::Sensemaker::AnalysesLinkComponent do
  include Rails.application.routes.url_helpers

  let(:debate) { create(:debate) }
  let(:component) { Admin::Sensemaker::AnalysesLinkComponent.new(debate) }

  before do
    Setting["feature.sensemaker"] = true
  end

  describe "#render?" do
    context "when sensemaker feature is enabled and at least one job exists (any status)" do
      before do
        create(:sensemaker_job, analysable_type: "Debate", analysable_id: debate.id, published: false)
      end

      it "returns true" do
        expect(component.render?).to be true
      end
    end

    context "when sensemaker feature is enabled but no jobs exist" do
      it "returns false" do
        expect(component.render?).to be false
      end
    end

    context "when sensemaker feature is disabled" do
      before do
        Setting["feature.sensemaker"] = nil
        create(:sensemaker_job, analysable_type: "Debate", analysable_id: debate.id)
      end

      it "returns false" do
        expect(component.render?).to be_falsy
      end
    end
  end

  describe "rendering" do
    context "when jobs are available" do
      before do
        create(:sensemaker_job, analysable_type: "Debate", analysable_id: debate.id)
      end

      it "renders a link to the admin sensemaker jobs index filtered by the resource" do
        render_inline component

        expect(page).to have_link(I18n.t("admin.sensemaker.index.sensemaker_analyses_count", count: 1),
                                  href: admin_sensemaker_jobs_path(resource_type: "debates",
                                                                   resource_id: debate.id))
      end
    end

    context "when no jobs exist" do
      it "does not render the link" do
        render_inline component

        expect(page).not_to have_link(I18n.t("admin.sensemaker.index.sensemaker_analyses_count", count: 1))
      end
    end
  end
end
