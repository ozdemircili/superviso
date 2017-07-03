class Widgets::ProgressBars < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:title, :progress_items]})

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      title: self.title,
      progress_items: self.progress_items
    }.merge(self.last_values)
  end
end



