class Widgets::UsageGauge < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:title, :max_value, :current_value]})

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      title: self.title,
      max: self.max_value,
      value: self.current_value
    }.merge(self.last_values)
  end
end


