class Admin::MachineLearning::ShowComponent < ApplicationComponent
  include Header
  attr_reader :machine_learning_job

  def initialize(machine_learning_job)
    @machine_learning_job = machine_learning_job
  end

  def title
    t("admin.machine_learning.title")
  end

  private

    def enabled?
      ::MachineLearning.enabled?
    end
end
