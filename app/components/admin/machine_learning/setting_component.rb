class Admin::MachineLearning::SettingComponent < ApplicationComponent
  attr_reader :kind

  def initialize(kind)
    @kind = kind
  end

  private

    def setting
      @setting ||= Setting.find_by(key: "machine_learning.#{kind}")
    end

    def ml_info
      @ml_info ||= MachineLearningInfo.for(kind)
    end

    def filenames
      ::MachineLearning.data_output_files[ml_info.kind.to_sym].sort
    end

    def data_path(filename)
      ::MachineLearning.data_path(filename)
    end
end
