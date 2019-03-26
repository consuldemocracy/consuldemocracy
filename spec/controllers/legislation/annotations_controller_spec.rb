require "rails_helper"

describe Legislation::AnnotationsController do

  describe "POST create" do
    before do
      @process = create(:legislation_process, allegations_start_date: Date.current - 3.days, allegations_end_date: Date.current + 2.days)
      @draft_version = create(:legislation_draft_version, :published, process: @process, title: "Version 1")
      @final_version = create(:legislation_draft_version, :published, :final_version, process: @process, title: "Final version")
      @user = create(:user, :level_two)
    end

    it "creates an ahoy event" do
      sign_in @user

      post :create, process_id: @process.id,
                    draft_version_id: @draft_version.id,
                    legislation_annotation: {
                        "quote" => "ipsum",
                        "ranges" => [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11}],
                        "text": "una anotacion"
                      }
      expect(Ahoy::Event.where(name: :legislation_annotation_created).count).to eq 1
      expect(Ahoy::Event.last.properties["legislation_annotation_id"]).to eq Legislation::Annotation.last.id
    end

    it "does not create an annotation if the draft version is a final version" do
      sign_in @user

      post :create, process_id: @process.id,
                    draft_version_id: @final_version.id,
                    legislation_annotation: {
                      "quote" => "ipsum",
                      "ranges" => [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11}],
                      "text": "una anotacion"
                    }

      expect(response).to have_http_status(:not_found)
    end

    it "creates an annotation if the process allegations phase is open" do
      sign_in @user

      expect do
        xhr :post, :create, process_id: @process.id,
                    draft_version_id: @draft_version.id,
                    legislation_annotation: {
                        "quote" => "ipsum",
                        "ranges" => [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11}],
                        "text": "una anotacion"
                      }
      end.to change { @draft_version.annotations.count }.by(1)
    end

    it "does not create an annotation if the process allegations phase is not open" do
      sign_in @user
      @process.update_attribute(:allegations_end_date, Date.current - 1.day)

      expect do
        xhr :post, :create, process_id: @process.id,
                    draft_version_id: @draft_version.id,
                    legislation_annotation: {
                        "quote" => "ipsum",
                        "ranges" => [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11}],
                        "text": "una anotacion"
                      }
      end.not_to change { @draft_version.annotations.count }
    end

    it "creates an annotation by parsing parameters in JSON" do
      sign_in @user

      expect do
        xhr :post, :create, process_id: @process.id,
                    draft_version_id: @draft_version.id,
                    legislation_annotation: {
                        "quote" => "ipsum",
                        "ranges" => [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11}].to_json,
                        "text": "una anotacion"
                      }
      end.to change { @draft_version.annotations.count }.by(1)
    end

    it "creates a new comment on an existing annotation when range is the same" do
      annotation = create(:legislation_annotation, draft_version: @draft_version, text: "my annotation",
                          ranges: [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11}],
                          range_start: "/p[1]", range_start_offset: 6, range_end: "/p[1]", range_end_offset: 11)
      sign_in @user

      expect do
        xhr :post, :create, process_id: @process.id,
                    draft_version_id: @draft_version.id,
                    legislation_annotation: {
                        "quote" => "ipsum",
                        "ranges" => [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11}],
                        "text": "una anotacion"
                      }
      end.not_to change { @draft_version.annotations.count }

      expect(annotation.reload.comments_count).to eq(2)
      expect(annotation.comments.last.body).to eq("una anotacion")
    end

  end
end
