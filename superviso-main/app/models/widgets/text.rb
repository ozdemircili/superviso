class Widgets::Text < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:title, :text, :moreinfo]})

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      title: self.title,
      text: self.text,
      moreinfo: self.moreinfo
    }.merge(self.last_values)
  end
end
