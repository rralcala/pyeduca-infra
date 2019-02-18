class User < ActiveRecord::Base

  attr_accessor :password
  attr_accessible :name, :admin, :email, :bucket, :activation_limit
  attr_accessible :can_create_dev_keys, :password
  before_save :hash_password  

  has_many :activations, :dependent => :destroy

  validates_length_of :name, :within => 3..40
  validates_length_of :password, :within => 5..40, :allow_nil => true
  validates_numericality_of :activation_limit, :greater_than => 0
  validates_numericality_of :bucket, :greater_than_or_equal_to => 0
  validates_presence_of :name, :email, :bucket, :activation_limit
  validates_uniqueness_of :name, :email
  validates_format_of :email, :with => /^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i, :message => "Invalid email"

  def bucket_handles(amount)
    result = true

    if !admin
      result = (bucket >= amount)
    end

    result
  end

  def reduce_bucket(amount)
    if !admin
      self.bucket = self.bucket - amount
      return self.save
    end

    true
  end

  def within_limits(amount)
    if !admin
      return (1..activation_limit).include?(amount)
    end

    true
  end

  def devel_keys_allowed
    if !admin
      return self.can_create_dev_keys
    end

    true
  end

  def change_password(old_password, new_password, verification)
    if !self.valid_password?(old_password)
      self.errors.add_to_base _("Invalid password")
      return false
    end

    if new_password != verification
      self.errors.add_to_base _("Verification doesn\'t match")
      return false    
    end

    self.password = new_password
    self.save
  end

  def self.authenticate(name, password)
    user = User.find_by_name(name)
    return user if user and user.valid_password?(password)
  end

  def valid_password?(password)
    self.password_hash == User.hash_password(password)
  end

  private

  def self.hash_password(password, salt=YAAS_CONFIG[:password_salt])
    Digest::SHA512.hexdigest("#{password}:#{salt}")
  end

  def hash_password
    self.password_hash = User.hash_password(self.password) unless self.password.blank?
  end

end
