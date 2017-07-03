class Widgets::Clock < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:title, :date, :time]})

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      title: self.title,
      date: self.date,
      time: self.time
    }.merge(self.last_values)
  end
end


