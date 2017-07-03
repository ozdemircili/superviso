class Widgets::Number < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:title, :current, :last, :prefix]})

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      title: self.title,
      current: self.current.empty? ? 0 : self.current,
      last: self.last.empty? ? 0 : self.last,
      prefix: self.prefix
    }.merge(self.last_values)
  end
end

