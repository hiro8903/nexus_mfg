# Initial Test User for Development
User.find_or_create_by!(user_code: "EMP001") do |user|
  user.name = "山田 太郎"
  user.password = "password"
end

puts "Seed: Created EMP001 user."
