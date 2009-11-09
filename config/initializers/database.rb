include MongoMapper

# Settings for MongoHQ
if ['production', 'development'].include?(Rails.env)
  MongoMapper.connection = Mongo::Connection.new('db.mongohq.com')
  MongoMapper.database = 'brooklyn'
  MongoMapper.database.authenticate('kyle', 'secret')
else
  MongoMapper.database = "news-#{Rails.env}"
end

MongoMapper.database.create_collection("stories")
MongoMapper.database = "news-#{Rails.env}"

# It's also possible to define indexes in the the model itself; however,
# a few issues are being worked out still. This is a temporary solution.
Comment.ensure_index([["story_id", 1], ["path", 1], ["points", -1]])
MongoMapper.ensure_indexes!

# Handle passenger forking.
if defined?(PhusionPassenger)
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     MongoMapper.database.connect_to_master if forked
   end
end 
