# Minimal, structured production seeds for municipalities
# This file mirrors the structure of db/dev_seeds.rb, but only creates minimal, real data.
# SAFE TO RUN MULTIPLE TIMES - idempotent operations only

# Helper methods (copied from dev_seeds.rb, but simplified for minimal data)
def section(section_title)
  puts section_title
  yield
  puts " ✅"
end

def log(msg)
  puts "#{msg}\n"
end

# --- Admin User ---
section "Admin User" do
  # Only create if no admin exists (safe to run multiple times)
  if Administrator.count == 0
    admin = User.create!(username: "admin", email: "admin@consul.dev", password: "changeme",
                         password_confirmation: "changeme", confirmed_at: Time.current,
                         terms_of_service: "1")
    admin.create_administrator
    log "Created default admin user (admin@consul.dev / changeme)"
  else
    log "Admin user already exists, skipping creation"
  end
end

# --- Settings ---
section "Settings" do
  # Reset defaults is safe to run multiple times
  Setting.reset_defaults
  log "Default settings loaded."
end

# --- Web Sections ---
section "Web Sections" do
  # Only load if not already loaded (safe to run multiple times)
  unless WebSection.exists?
    load Rails.root.join("db", "web_sections.rb")
  else
    log "Web sections already exist, skipping"
  end
end

# --- Pages (commented out due to model name issues) ---
# section "Pages" do
#   # Only load if not already loaded (safe to run multiple times)
#   unless Pages.exists?
#     load Rails.root.join("db", "pages.rb")
#   else
#     log "Pages already exist, skipping"
#   end
# end

# --- Sustainable Development Goals ---
section "SDG" do
  # Only load if not already loaded (safe to run multiple times)
  unless SDG::Goal.exists?
    load Rails.root.join("db", "sdg.rb")
  else
    log "SDG data already exists, skipping"
  end
end

# --- Example Project/Section (if your app needs one for UI) ---
section "Example Project" do
  if defined?(Project) && Project.count == 0
    Project.create!(title: "Welcome Project", description: "This is an example project. Edit or add more!")
    log "Created example project."
  else
    log "Projects already exist, skipping example creation"
  end
end

# --- Example Community (if needed) ---
section "Example Community" do
  # Some installs have a minimal communities table without name/description.
  # Create only if compatible, otherwise skip safely.
  if defined?(Community) && Community.count == 0 && Community.column_names.include?("name")
    Community.create!(name: "Welcome Community", description: "This is an example community.")
    log "Created example community."
  else
    log "Skipping community creation (incompatible schema or already present)."
  end
end

log "Minimal production seeds loaded safely. Ready for municipalities!"
