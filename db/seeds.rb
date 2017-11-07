if User.where(name: "Test user").present?
  puts "Skipping because user already exists"
  exit
end

gds_organisation_id = "af07d5a5-df63-4ddc-9383-6a666845ebe9"
user_id = "026530a0-750f-41e6-8863-b539d1467145"

User.create!(
  uid: user_id,
  name: "Test user",
  permissions: ["signin", "GDS Editor"],
  organisation_content_id: gds_organisation_id,
)