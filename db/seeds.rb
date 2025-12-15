# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding sample data..."

Form.destroy_all

feedback = Form.create!(title: "Website Feedback")
name_field = feedback.fields.create!(label: "Your name", field_type: "text", position: 1)
rating_field = feedback.fields.create!(label: "Rating (1-5)", field_type: "number", position: 2)
topic_field = feedback.fields.create!(label: "Topic", field_type: "select", position: 3)
topic_field.options.create!([
	{ label: "Bug", value: "bug", position: 1 },
	{ label: "Feature Request", value: "feature", position: 2 },
	{ label: "General", value: "general", position: 3 }
])

survey = Form.create!(title: "Quick Survey")
survey.fields.create!(label: "Age", field_type: "number", position: 1)
survey_select = survey.fields.create!(label: "Favorite Color", field_type: "select", position: 2)
survey_select.options.create!([
	{ label: "Red", value: "red" },
	{ label: "Green", value: "green" },
	{ label: "Blue", value: "blue" }
])

puts "Seeded #{Form.count} forms, #{Field.count} fields, #{Option.count} options."
