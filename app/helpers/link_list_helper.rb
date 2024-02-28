module LinkListHelper
  def link_list(*, **)
    render Shared::LinkListComponent.new(*, **)
  end
end
