# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding super admin..."

# Destroy data in dependency order to satisfy FK constraints
Form.destroy_all
User.destroy_all

admin_email = ENV.fetch("SUPER_ADMIN_EMAIL", "admin@example.com")
admin_password = ENV.fetch("SUPER_ADMIN_PASSWORD", "password")

admin = User.create!(email: admin_email, password: admin_password, password_confirmation: admin_password, role: :super_admin)

puts "Seeded super admin: #{admin.email}"
