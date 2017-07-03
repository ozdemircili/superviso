class Widgets::Fadelist < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:title, :items]})

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      title: self.title,
      items: self.items
    }.merge(self.last_values)
  end
end

