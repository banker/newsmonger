Factory.define(:comment) do |c|
  c.user  { Factory(:user)  }
  c.story { Factory(:story) }
  c.body  "I liked this story."
end
