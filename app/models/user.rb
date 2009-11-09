require 'digest/sha1'
require 'bcrypt'
class User
  include MongoMapper::Document
  
  key :username, String, :required => true
  key :email, String, :required => true
  key :crypted_password, String
  key :reset_password_code, String
  key :reset_password_code_until, Time
  
  RegEmailName = '[\w\.%\+\-]+'
  RegDomainHead = '(?:[A-Z0-9\-]+\.)+'
  RegDomainTLD = '(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum)'
  RegEmailOk = /\A#{RegEmailName}@#{RegDomainHead}#{RegDomainTLD}\z/i
  
  def self.authenticate(email, secret)
    u = User.first(:conditions => {:email => email.downcase})
    u && u.authenticated?(secret) ? u : nil
  end
  
  validates_length_of :username, :within => 6..15
  validates_length_of :email,    :within => 6..100, :allow_blank => true
  validates_format_of :email,    :with => RegEmailOk, :allow_blank => true
  
  PasswordRequired = Proc.new { |u| u.password_required? }
  validates_presence_of :password, :if => PasswordRequired
  validates_confirmation_of :password, :if => PasswordRequired, :allow_nil => true
  validates_length_of :password, :minimum => 6, :if => PasswordRequired, :allow_nil => true
  
  def authenticated?(secret)
    password == secret ? true : false
  end
  
  def password
    if crypted_password.present?
      @password ||= BCrypt::Password.new(crypted_password)
    else
      nil
    end
  end
  
  def password=(value)
    if value.present?
      @password = value
      self.crypted_password = BCrypt::Password.create(value)
    end
  end
  
  def email=(new_email)
    new_email.downcase! unless new_email.nil?
    write_attribute(:email, new_email)
  end
  
  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
  def set_password_code!
    seed = "#{email}#{Time.now.to_s.split(//).sort_by {rand}.join}"
    self.reset_password_code_until = 1.day.from_now
    self.reset_password_code = Digest::SHA1.hexdigest(seed)
    save!
  end
end
