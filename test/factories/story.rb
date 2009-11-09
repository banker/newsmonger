Factory.define :story do |s|
  s.url   "http://google.com"
  s.title "Google Launches Search"
  s.user  { Factory(:user) }
end
