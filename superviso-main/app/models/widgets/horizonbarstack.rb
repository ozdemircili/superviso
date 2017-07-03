class Widgets::Horizonbarstack < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:series, :categories]})

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      title: self.title,
      series: self.series,
      categories: self.categories
    }.merge(self.last_values)
  end
end
