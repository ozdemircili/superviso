class Widgets::Klimato < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:title, :location, :temperature, :code, :unit, :temperature]})

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      location: self.location,
      temperature: self.temperature,
      code: self.code,
      format: self.unit,
      temperature: self.temperature
    }.merge(self.last_values)
  end
end

