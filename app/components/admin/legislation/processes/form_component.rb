class Admin::Legislation::Processes::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  attr_reader :process
  use_helpers :admin_submit_action

  def initialize(process)
    @process = process
  end
end
