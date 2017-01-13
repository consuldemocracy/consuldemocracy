require 'rails_helper'

describe Legislation::AnnotationsController do

  describe 'POST create' do
    before(:each) do
      @process = create(:legislation_process, allegations_start_date: Date.current - 3.day, allegations_end_date: Date.current + 2.days)
      @draft_version = create(:legislation_draft_version, :published, process: @process, title: "Version 1")
      @final_version = create(:legislation_draft_version, :published, :final_version, process: @process, title: "Final version")
      @user = create(:user, :level_two)
    end

    it 'should create an ahoy event' do
      sign_in @user

      post :create, process_id: @process.id,
                    draft_version_id: @draft_version.id,
                    annotation: {
                        "quote"=>"Ordenación Territorial",
                        "ranges"=>[{"start"=>"/p[1]", "startOffset"=>1, "end"=>"/p[1]", "endOffset"=>3}],
                        "text": "una anotacion"
                      }
      expect(Ahoy::Event.where(name: :legislation_annotation_created).count).to eq 1
      expect(Ahoy::Event.last.properties['legislation_annotation_id']).to eq Legislation::Annotation.last.id
    end

    it 'should not create an annotation if the draft version is a final version' do
      sign_in @user

      post :create, process_id: @process.id,
                    draft_version_id: @final_version.id,
                    annotation: {
                      "quote"=>"Ordenación Territorial",
                      "ranges"=>[{"start"=>"/p[1]", "startOffset"=>1, "end"=>"/p[1]", "endOffset"=>3}],
                      "text": "una anotacion"
                    }

      expect(response).to have_http_status(:not_found)
    end

    it 'should create an annotation if the process allegations phase is open' do
      sign_in @user

      expect do
        xhr :post, :create, process_id: @process.id,
                    draft_version_id: @draft_version.id,
                    annotation: {
                        "quote"=>"Ordenación Territorial",
                        "ranges"=>[{"start"=>"/p[1]", "startOffset"=>1, "end"=>"/p[1]", "endOffset"=>3}],
                        "text": "una anotacion"
                      }
      end.to change { @draft_version.annotations.count }.by(1)
    end

    it 'should not create an annotation if the process allegations phase is not open' do
      sign_in @user
      @process.update_attribute(:allegations_end_date, Date.current - 1.day)

      expect do
        xhr :post, :create, process_id: @process.id,
                    draft_version_id: @draft_version.id,
                    annotation: {
                        "quote"=>"Ordenación Territorial",
                        "ranges"=>[{"start"=>"/p[1]", "startOffset"=>1, "end"=>"/p[1]", "endOffset"=>3}],
                        "text": "una anotacion"
                      }
      end.to_not change { @draft_version.annotations.count }
    end
  end
end
