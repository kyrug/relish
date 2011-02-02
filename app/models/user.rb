class User
  include MongoMapper::Document
  plugin MongoMapper::Devise

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :token_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :username
   
  key :email, String
  key :encrypted_password, String
  key :password_salt, String
  key :reset_password_token, String
  key :remember_token, String
  key :remember_created_at, String
  key :sign_in_count, Integer
  key :current_sign_in_at, DateTime
  key :last_sign_in_at, DateTime
  key :current_sign_in_ip, String
  key :last_sign_in_ip, String
  key :username, String
  key :role, String
  key :authentication_token
  timestamps!
    
  key :display_name, String
  key :slug, String, :index=>true 
              

  # Associations / Relationships
  has_many :bookmarks

  # Roles
  ROLES = %w[admin author banned]

  before_create :set_default_role
  before_save :ensure_authentication_token

  def set_default_role
    self.role = "author"
  end
  
  def bookmarks_visible_to(user)
    (self == user) ? self.bookmarks : self.bookmarks.publicly_available
  end

  def to_param
    self.username
  end
  
end