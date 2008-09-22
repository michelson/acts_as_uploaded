module UploadableViewHelper

    
    def image_s3(image,options = {})
       w = options[:width].nil? ? '' : "width=\"#{options[:width]}\" "
       h = options[:height].nil? ? '' : "height=\"#{options[:height]}\" "
       classe=  options[:classe].nil? ? '' : options[:classe]
       border = options[:border].nil? ? '' : options[:border]
       style = options[:style].nil? ? '' : options[:style]
       type = options[:type].nil? ? 'thumb' : options[:type]
       folder = options[:folder].nil? ? 'fotos_artistas_mini' : options[:folder]
       image_remota = "<img src=\"#{image.s3_path(type)} \" style=\"#{style}\" border=\"#{border}\" class=\"#{classe}\" #{h} #{w}   />"
       return image_remota
     end
    
    
  
end