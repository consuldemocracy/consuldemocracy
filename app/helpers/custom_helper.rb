module CustomHelper
  def exists_polls_of_kind?(kind)
    Poll.where(kind: kind).count > 0
  end
end
