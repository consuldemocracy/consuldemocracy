module LinkListHelper
  def link_list(*links, **options)
    render Shared::LinkListComponent.new(*links, **options)
  end
end
