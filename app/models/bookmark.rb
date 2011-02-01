require 'serialization'

class Bookmark
  include MongoMapper::Document
  include MongoMapper::Plugins::Serialization
  
  key :title, String
  key :url,   String
  key :user_id, ObjectId, :index=>true
  key :url_id, ObjectId, :index=>true
  key :note, String
  key :tags, Array, :index=>true
  key :add_date, Time
  key :private, Boolean, :default=>false
  timestamps!
  
  validates_uniqueness_of :url, :scope => :user_id
  
  belongs_to :user
  belongs_to :master, :class_name=>'Url', :foreign_key=>:url_id
 
  before_create :ensure_add_date
  before_create :find_or_create_master
  before_save :ensure_url_protocol
  before_save :handle_privacy_changes
  after_save :push_tags_to_master
  after_save :generate_url_stats
  
  after_destroy :generate_url_stats
  
  scope :publicly_available, { :private=>false }
  
  scope :ordered, lambda {|*args| {:order => (args.first || 'add_date desc')} }


  def ensure_url_protocol
    self.url = "http://#{self.url}"  unless self.url.downcase.match(/^http/)
  end
  
  def ensure_add_date
    self.add_date = Time.now.utc if self.add_date.nil?
  end
  
  def find_or_create_master
    ensure_url_protocol
    if self.public?
      url = Url.find_or_create_by_url(self.url)
      url.title = self.title
      url.add_date = self.add_date || Time.now
      url.created_at = url.add_date if (url.add_date < url.created_at)
      url.save
      self.master = url
    end
  end
    
  def push_tags_to_master
    self.master.tag(self.tags, self.user) unless self.tags.empty? or self.private?
  end
  
  def total_saves
    self.master.total_saves
  end
  
  def tag_list=(tags)
    self.tags = tags.split(' ').compact.uniq
  end
  
  def tag_list
    self.tags.join(' ')
  end
  
  def public?
    (self.private?) ? false : true
  end

  def handle_privacy_changes
    if going_private?
      self.master.delete_tags_by_user(self.user)
      self.master = nil
    elsif going_public?
      find_or_create_master
    end
  end
  
  def generate_url_stats
    Url.generate_url_stats(self.url)
  end
  
  protected
  def going_private?
    self.private_changed? && self.private?
  end
  
  def going_public?
    self.private_changed? && self.public?
  end

end