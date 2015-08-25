module DebatesHelper

  def sort_debates(debates, filter)
    sort_criteria = {'votes' => :total_votes, 'news' => :created_at, 'rated' => :likes}
    debates.sort_by(&sort_criteria[filter]).reverse
  end

end
