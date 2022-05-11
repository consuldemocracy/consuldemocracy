class Admin::BudgetQuestions::QuestionsComponent < ApplicationComponent
    include Header
    attr_reader :budget
  
    def initialize(budget)
      @budget = budget
    end
  
    private
  
  end
  