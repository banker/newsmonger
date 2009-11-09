Factory.define(:user) do |u|
  u.sequence(:email) { |n| "john#{n}@doe.com" }
  u.sequence(:username) { |n| "joe_user_#{n}" }
  u.password "testing"
  u.password_confirmation "testing"
end
