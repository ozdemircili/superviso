class Widgets::Meter < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:title, :min, :max, :current_value]})

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      title: self.title,
      min: self.min,
      max: self.max,
      value: self.current_value
    }.merge(self.last_values)
  end
end


