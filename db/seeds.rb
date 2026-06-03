# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# coding: utf-8

User.create!(name: "管理者",
             email: "admin@example.com",
             password: "password",
             password_confirmation: "password",
             admin: true,
             superior: false)

User.create!(name: "テストユーザー",
             email: "test@example.com",
             password: "password",
             password_confirmation: "password",
             admin: false,
             superior: false)

User.create!(name: "上長A",
             email: "manager-a@example.com",
             password: "password",
             password_confirmation: "password",
             admin: false,
             superior: true)

User.create!(name: "上長B",
             email: "manager-b@example.com",
             password: "password",
             password_confirmation: "password",
             admin: false,
             superior: true)

60.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@example.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end