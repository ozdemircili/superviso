class Widget < ActiveRecord::Base

  belongs_to :dashboard, inverse_of: :widgets
  has_one :user, through: :dashboard

  before_create :set_coordinates
  before_create :generate_secret_token
  
  validate :quota, on: :create
  
  has_settings do |s|
    s.key :style, defaults: {color: "#ec663c", row: 1, col: 1, size_x: 1, size_y: 1}
    s.key :custom
  end

  def dashing_type
    self.type.match(/::(.+)/)[1]
  end
  protected

  def last_values
    _values = nil
    RedisPool.with do |conn|
      _values = conn.get "w:#{self.secret_token}:last"
    end

    if _values.nil?
      {}
    else
      JSON(_values).symbolize_keys!.except(:id, :dashing_type)
    end
  end
  
  def self.settings_attr_accessor(attrs_hash)
    attrs_hash.each do |namespace, method_names|
      method_names.each do |method_name|
      eval "
        def #{method_name}
          self.settings(:#{namespace}).send(:#{method_name})
        end
        def #{method_name}=(value)
          self.settings(:#{namespace}).send(:#{method_name}=, value)
        end
      "
      end
    end
  end
  
  private

  def set_coordinates
    return unless self.dashboard
    return unless self.deletable

    coordinates = self.dashboard.next_coordintes
    self.col = coordinates[:col]
    self.row = coordinates[:row]
  end
  def generate_secret_token
    begin
      self.secret_token = SecureRandom.hex
    end while self.class.exists?(secret_token: secret_token)
  end


  def quota
    if(self.dashboard.user.widgets.count >= self.dashboard.user.subscription_level.widget_quota)
      errors.add(:base, "Over quota")
    end
  end
end
