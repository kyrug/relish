class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :username
  
  # Associations / Relationships
  has_many :bookmarks
  
  # Roles
  ROLES = %w[admin author banned]
  
  before_create :set_default_role

  def set_default_role
    self.role = "author"
  end
  
  def to_param
    username
  end
  
end
