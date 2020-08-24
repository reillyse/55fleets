# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

app = App.create! name: 'build_system'
pod =
  app.pods.create! name: 'build_pod', number_of_members: 2, ami: 'ami-8d3040e7'
