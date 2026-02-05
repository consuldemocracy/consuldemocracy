class Admin::Legislation::Processes::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  attr_reader :process
  delegate :admin_submit_action, to: :helpers

  def initialize(process)
    @process = process
  end
end
