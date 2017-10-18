module RepresentativesHelper

  def representative_select_options
    Forum.all.order(name: :asc).collect { |r| [ r.name, r.id ] }
  end

end