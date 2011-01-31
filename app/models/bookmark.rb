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
 
  before_save :prepend_protocol_if_needed
  before_create :set_add_date_if_needed
  before_create :find_or_create_master
  after_save :push_tags_to_master
  before_destroy :decrement_total_saves_on_master
  

  scope :publicly_available, { :private=>false }

  scope :ordered, lambda {|*args| {:order => (args.first || 'add_date desc')} }
  
  def prepend_protocol_if_needed
      self.url = "http://#{self.url}"  unless self.url.downcase.match(/^http/)
  end
  
  def set_add_date_if_needed
    self.add_date = Time.now.utc if self.add_date.nil?
  end
  
  def find_or_create_master
    prepend_protocol_if_needed
    unless self.private?
      url = Url.find_or_create_by_url(self.url)
      url.total_saves = url.total_saves + 1
      url.title = self.title
      url.add_date = self.add_date || Time.now
      url.created_at = url.add_date if (url.add_date < url.created_at)
      url.generate_hotness
      url.save
      self.master = url
    end
  end
    
  def push_tags_to_master
    self.master.tag(self.tags, self.user) unless self.tags.empty?
  end
  
  def decrement_total_saves_on_master
    Url.collection.update({:url=>self.url}, {:$inc=>{ :total_saves => -1 } })
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

  
end