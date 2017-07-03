class Widgets::Countdown < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:title, :end_date]})
  

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      title: self.title,
      end: self.end_date
    }.merge(self.last_values)
  end
end

