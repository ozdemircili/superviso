class Widgets::Gauge < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:series, :suffix, :max]})

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      title: self.title,
      series: self.series,
      suffix: self.suffix,
      max: self.max
    }.merge(self.last_values)
  end
end


