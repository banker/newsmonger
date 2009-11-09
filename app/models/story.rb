class Story
  include MongoMapper::Document

  key :title,     String
  key :url,       String
  key :slug,      String
  key :voters,    Array
  key :votes,     Integer, :default => 0
  key :relevance, Integer, :default => 0

  # Cached values.
  key :comment_count, Integer, :default => 0
  key :username,      String

  # Note this: ids are strings, not integers.
  key :user_id,   String
  timestamps!

  # Relationships.
  belongs_to :user
  many :comments

  # Validations.
  URL_REGEX = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  validates_presence_of :title, :url, :user_id
  validates_format_of :url, :with => URL_REGEX

  # Callbacks.
  after_validation_on_create :store_user_data, :create_slug

  def self.find_by_slug(slug)
    first(:conditions => {:slug => slug})
  end

  def to_param
    self.slug || self.id
  end

  def self.upvote(story_id, user_id)
    collection.update({'_id' => story_id, 'voters' => {'$ne' => user_id}}, 
      {'$inc' => {'votes' => 1}, '$push' => {'voters' => user_id}})
  end
  
  # Upvote this story.
  def upvote(user)
    unless self.voters.include?(user.id)
      self.voters << user.id 
      self.votes += 1
      self.relevance = calculate_relevance unless new_record?
      self.save
    end
  end

  private

  # Stories are displayed in order of relevance.
  # Relevance will eventually reach zero, at which point, 
  # stories are displayed in order of date posted and votes.
  def calculate_relevance
    return self.votes if self.created_at > 8.hours.ago.utc
  end

  # Cache username and upvote.
  def store_user_data
    upvote(self.user)
    self.username = self.user.username
  end

  # Create a slug from the title.
  # From Sluggable Finder: http://github.com/ismasan/sluggable-finder/
  def convert_to_slug(str)
    if defined?(ActiveSupport::Inflector.parameterize)
      ActiveSupport::Inflector.parameterize(str).to_s
    else
      ActiveSupport::Multibyte::Handlers::UTF8Handler.
       normalize(str,:d).split(//u).reject { |e| e.length > 1 }.join.strip.gsub(/[^a-z0-9]+/i, '-').downcase.gsub(/-+$/, '')
    end
  end

  # Note: this slug creation code is vulnerable to race conditions.
  # Refactoring forthcoming.
  def create_slug
    return if self.title.blank?
    tail, int = "", 1
    initial   = convert_to_slug(self.title)
    while Story.find_by_slug(initial + tail) do 
      int  += 1
      tail = "-#{int}"
    end
    self.slug = initial + tail
  end
end
