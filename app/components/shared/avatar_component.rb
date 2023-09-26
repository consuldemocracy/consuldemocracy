class Shared::AvatarComponent < ApplicationComponent
  attr_reader :record, :given_options
  delegate :avatar_image, to: :helpers

  def initialize(record, **given_options)
    @record = record
    @given_options = given_options
  end

  private

    def default_options
      { seed: seed }
    end

    def options
      default_options.merge(given_options)
    end

    def seed
      record.id
    end
end
