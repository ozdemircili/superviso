class Widgets::LoadAverage < Widget
  settings_attr_accessor({style: [:color, :size_x, :size_y, :row, :col]})
  settings_attr_accessor({custom: [:title, :value_1, :value_2, :value_3]})
  
  before_save :fix_width

  def dashing_data_hash
    {
      id: self.secret_token,
      view: self.dashing_type,
      title: self.title,
      value1: self.value_1.empty? ? 0 : self.value_1,
      value2: self.value_2.empty? ? 0 : self.value_2,
      value3: self.value_3.empty? ? 0 : self.value_3
    }.merge(self.last_values)
  end

  private 

  def fix_width 
    if self.size_x.to_i < 2
      self.size_x = "2"
    end
  end
end
