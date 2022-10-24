class MachineLearning::InfoComponent < ApplicationComponent
  delegate :current_user, to: :helpers
end
