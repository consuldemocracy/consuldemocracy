require_dependency Rails.root.join("app", "models", "user").to_s

class User
  scope :officials_by_project,     ->(projects) { where("users.official_position ILIKE ?", "%#{projects}%") }
end
