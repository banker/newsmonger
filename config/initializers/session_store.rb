# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_news_session',
  :secret      => 'a9a81f1d344cb2fec5cfa416acdfbbed20e5c7d7115d8d73021a668c9b6c915f18d7b4aa5360ec367621fc37d57d187d7fce157541b711a765d63a2ca74daddc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
