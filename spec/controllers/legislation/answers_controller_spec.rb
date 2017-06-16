require "rails_helper"

describe Legislation::AnswersController do

  describe "POST create" do
    before do
      @process = create(:legislation_process, debate_start_date: Date.current - 3.days, debate_end_date: Date.current + 2.days)
      @question = create(:legislation_question, process: @process, title: "Question 1")
      @question_option = create(:legislation_question_option, question: @question, value: "Yes")
      @user = create(:user, :level_two)
    end

    it "creates an ahoy event" do
      sign_in @user

      post :create, params: {process_id: @process.id, question_id: @question.id, legislation_answer: { legislation_question_option_id: @question_option.id }}
      expect(Ahoy::Event.where(name: :legislation_answer_created).count).to eq 1
      expect(Ahoy::Event.last.properties["legislation_answer_id"]).to eq Legislation::Answer.last.id
    end

    it "creates an answer if the process debate phase is open" do
      sign_in @user

      expect do
        post :create, params: {process_id: @process.id, question_id: @question.id, legislation_answer: { legislation_question_option_id: @question_option.id }}, xhr: true
      end.to change { @question.reload.answers_count }.by(1)
    end

    it "does not create an answer if the process debate phase is not open" do
      sign_in @user
      @process.update_attribute(:debate_end_date, Date.current - 1.day)

      expect do
        post :create, params: {process_id: @process.id, question_id: @question.id, legislation_answer: { legislation_question_option_id: @question_option.id }}, xhr: true
      end.not_to change { @question.reload.answers_count }
    end
  end
end
