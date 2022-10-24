class Admin::MachineLearning::ScriptsComponent < ApplicationComponent
  attr_reader :machine_learning_job

  def initialize(machine_learning_job)
    @machine_learning_job = machine_learning_job
  end

  private

    def script_select_options
      scripts_info.map { |info| [info[:name], { "aria-describedby": info[:name] }] }
    end

    def scripts_info
      @scripts_info ||= ::MachineLearning.scripts_info
    end
end
