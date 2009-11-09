class Comment
  include MongoMapper::Document

  key :body,       String
  key :voters,     Array
  key :votes,      Integer, :default => 0
  key :depth,      Integer, :default => 0
  key :path,       String,  :default => ""

  key :parent_id,  String
  key :story_id,   String
  key :user_id,    String
  key :username,   String
  timestamps!

  # Relationships.
  belongs_to :user
  belongs_to :story

  # Callbacks.
  after_create :auto_upvote, :set_path, :increment_story_comment_count

  # Return an array of comments, threaded, from highest to lowest votes.
  # Sorts by votes descending by default, but could use any other field.
  # If you want to build out an internal balanced score, pass that field in,
  # and be sure to index it on the database.
  def self.threaded_with_field(story, field_name='votes')
    comments = find(:all, :conditions => {:story_id => story.id}, :order => "path asc, #{field_name} desc")
    results, map  = [], {}
    comments.each do |comment|
      if comment.parent_id.blank?
        results << comment
      else
        comment.path =~ /:([\d|\w]+)$/
        if parent = $1
          map[parent] ||= []
          map[parent] << comment
        end
      end
    end
    assemble(results, map)
  end

  # Used by Comment#threaded_with_field to assemble the results.
  def self.assemble(results, map)
    list = []
    results.each do |result|
      if map[result.id]
        list << result
        list += assemble(map[result.id], map)
      else
        list << result
      end
    end
    list
  end

  # Upvote this comment.
  def upvote(user)
    unless self.voters.include?(user.id)
      self.voters << user.id 
      self.votes += 1
      self.save
    end
  end

  # Is this a root node?
  def root?
    self.depth.zero?
  end

  def user=(user)
    self.username = user.username
    self.user_id  = user.id
  end

  private

  # Comment owner automatically upvoters.
  def auto_upvote
    upvote(self.user)
  end

  def increment_story_comment_count
    Story.collection.update({"_id" => self.story_id}, {"$inc" => {"comment_count" => 1}})
  end

  # Store the comment's path.
  def set_path
    unless self.parent_id.blank?
      parent        = Comment.find(self.parent_id)
      self.story_id = parent.story_id
      self.depth    = parent.depth + 1
      self.path     = parent.path + ":" + parent.id
    end
    save
  end
end
