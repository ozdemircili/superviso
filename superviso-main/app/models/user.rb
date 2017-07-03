class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  validates :auth_token, uniqueness: true

  before_create :generate_auth_token

  has_many :dashboards
  has_many :widgets, through: :dashboards

  belongs_to :plan
  
  serialize :hidden_announcements, Array



  def subscription_level
    self.plan || Plan.find_by(base_plan: true)  
  end

  def announcements
    result = Announcement.where("starts_at <= :now and ends_at >= :now", now: Time.zone.now)
    result = result.where("id not in (?)", hidden_announcements) if hidden_announcements.present?
    result
  end

  def hide_announcement(announcement) 
    self.hidden_announcements << announcement.id 
    save
  end

  private
  def generate_auth_token
    begin
      self.auth_token = SecureRandom.hex
    end while self.class.exists?(auth_token: auth_token)
  end

end
