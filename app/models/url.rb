require 'serialization'

class Url
  include MongoMapper::Document
  include ActsAsMongoTaggable
  include MongoMapper::Plugins::Serialization
  
  key :total_saves, Integer, :default=>0
  key :title, String
  key :url, String, :index=>true
  key :add_date, Time
  key :hotness, Float, :default => 0.0, :index => true
  timestamps!
  
  validates_uniqueness_of :url
  
  has_many :bookmarks, :order=>'add_date desc'
  
  scope :ordered, lambda {|*args| {:order => (args.first || 'add_date desc')} }

  def generate_hotness
    self.hotness = self.total_saves / (Time.now - self.created_at) 
  end
  
  def url_id
    self.id
  end
  
  def private?
    false
  end
  
end