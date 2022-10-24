class Admin::MachineLearning::SettingsComponent < ApplicationComponent
  private

    def script_kinds
      @script_kinds ||= ::MachineLearning.script_kinds
    end

    def filenames
      ::MachineLearning.data_intermediate_files
    end

    def data_path(filename)
      ::MachineLearning.data_path(filename)
    end
end
