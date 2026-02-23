class Admin::MachineLearning::ScriptsComponent < ApplicationComponent
  attr_reader :machine_learning_job

  def initialize(machine_learning_job)
    @machine_learning_job = machine_learning_job
  end

  private

    def script_select_options
      ::MachineLearning.script_select_options
    end

    def scripts_info
      ::MachineLearning.scripts_info
    end

    def processed_label
      script_config = ::MachineLearning::AVAILABLE_SCRIPTS[machine_learning_job.script]
      kind = script_config ? script_config[:kind] : "default"
      t("admin.machine_learning.processed_labels.#{kind}",
        default: t("admin.machine_learning.processed_labels.default"))
    end

    def processed_resource_name
      machine_learning_job.script.split("_").first.singularize.capitalize
    end
end
