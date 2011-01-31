class User
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :token_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :username

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