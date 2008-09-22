module IrregularScience
  def resize_within(w, h)
    r_old = width.to_f / height
    r_new = w.to_f / h
  
    w_new = r_new > r_old ? (h * r_old).to_i : w
    h_new = r_new > r_old ? h : (w / r_old).to_i
    
    self.resize(w_new, h_new) do |image|
      yield image
    end
  end

  def resize_exact(w, h)
    r_old = width.to_f / height
    r_new = w.to_f / h
  
    w_crop = r_new > r_old ? width : (height * r_new).to_i
    h_crop = r_new > r_old ? (width / r_new).to_i : height
  
    trim_w = (width - w_crop) / 2
    trim_h = (height - h_crop) / 2
  
    l, r = trim_w, trim_w + w_crop
    t, b = trim_h, trim_h + h_crop
    
    self.with_crop(l, t, r, b) do |img|
      img.resize(w, h) do |thumb|
        yield thumb
      end
    end
  end

  def resize_to_width(w)
   
    h = self.height
    if(w > self.width)
      w = self.width
    else
      w = w
    end 
    scale = w.to_f / width
    self.resize(w, h*scale) do |image|
      yield image
    end
  end

  def resize_to_height(h)
    scale = h.to_f / height
  
    img.resize(w*scale, h) do |image|
      yield image
    end
  end
end

ImageScience.send(:include, IrregularScience)