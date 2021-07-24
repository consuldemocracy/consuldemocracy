class Documents::FieldsComponent < ApplicationComponent
  attr_reader :f

  def initialize(f)
    @f = f
  end

  private

    def document
      f.object
    end
end
