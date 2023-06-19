class Proposals::GeozonesComponent < ApplicationComponent
  delegate :image_path_for, to: :helpers

end
