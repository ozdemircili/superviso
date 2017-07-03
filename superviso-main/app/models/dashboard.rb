class Dashboard < ActiveRecord::Base
  belongs_to :user
  belongs_to :cloned_from, class_name: Dashboard
  has_many :widgets, inverse_of: :dashboard

  accepts_nested_attributes_for :widgets

  validate :quota, on: :create

  def widgets_by_row
    self.widgets.sort_by{|w| w.row }.reverse
  end
  
  def next_coordintes
    if self.widgets.any?
      rows = self.widgets.map{|w| w.row}
      col = 1
      row  = rows.max+1
    else
      col = 1
      row = 1
    end

    return {col: col, row: row}
  end

  def pusher_channel
    "private-dashboard-#{self.id}"
  end

  def self.templates
    self.where(user_id: nil, template: true)
  end

  def self.build_from_template(_template)
    dolly =_template.dup(except: [:name, :template], include: {widgets: :setting_objects })
    dolly.widgets.each do |w|
      w.deletable = false
    end
    dolly
  end

  def script_end_point_config
    {
      end_point: "http://collector.superviso.com",
      auth_token: user.auth_token,
      widgets: self.widget_roles
    }
  end

  def widget_roles
    self.widgets.inject({}) {|hash, elem| hash.merge!(elem.role => elem.secret_token) }
  end

  private
  def quota
    if(self.user.dashboards.count >= self.user.subscription_level.dashboard_quota)
      errors.add(:base, "Over quota")
    end
  end
end
