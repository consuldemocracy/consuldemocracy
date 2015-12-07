# Default admin user (change password after first deploy to a server!)
if Administrator.count == 0 && !Rails.env.test?
  admin = User.create!(username: 'admin', email: 'admin@madrid.es', password: '12345678', password_confirmation: '12345678', confirmed_at: Time.now, terms_of_service: "1")
  admin.create_administrator
end

# Names for the moderation console, as a hint for moderators
# to know better how to assign users with official positions
Setting.create(key: 'official_level_1_name', value: 'Empleados públicos')
Setting.create(key: 'official_level_2_name', value: 'Organización Municipal')
Setting.create(key: 'official_level_3_name', value: 'Directores generales')
Setting.create(key: 'official_level_4_name', value: 'Concejales')
Setting.create(key: 'official_level_5_name', value: 'Alcaldesa')

# Max percentage of allowed anonymous votes on a debate
Setting.create(key: 'max_ratio_anon_votes_on_debates', value: '50')

# Max votes where a debate is still editable
Setting.create(key: 'max_votes_for_debate_edit', value: '1000')

# Max votes where a proposal is still editable
Setting.create(key: 'max_votes_for_proposal_edit', value: '1000')

# Prefix for the Proposal codes
Setting.create(key: 'proposal_code_prefix', value: 'MAD')

# Number of votes needed for proposal success
Setting.create(key: 'votes_for_proposal_success', value: '53726')

# Users with this email domain will automatically be marked as level 1 officials
# Emails under the domain's subdomains will also be included
Setting.create(key: 'email_domain_for_officials', value: '')
