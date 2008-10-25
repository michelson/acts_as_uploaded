module UploadableViewHelper

    
    def image_s3(image,options = {})
       w = options[:width].nil? ? '' : "width=\"#{options[:width]}\" "
       h = options[:height].nil? ? '' : "height=\"#{options[:height]}\" "
       classe=  options[:classe].nil? ? '' : options[:classe]
       border = options[:border].nil? ? '' : options[:border]
       style = options[:style].nil? ? '' : options[:style]
       type = options[:type].nil? ? 'thumb' : options[:type]
       alt = options[:alt].nil? ? '' : options[:alt]
       folder = options[:folder].nil? ? 'fotos_artistas_mini' : options[:folder]
       unless image.image.nil?
           unless image.in_s3 == false 
             path = image.s3_path(type)
           else
             path = image.simple_path_with_file(type)
           end
             image_remota = "<img src=\"#{path} \" alt=\"#{alt}\" style=\"#{style}\" border=\"#{border}\" class=\"#{classe}\" #{h} #{w}   />"
           else
             image_remota = 'nada'
      end
     
       return image_remota
     end
    
    
  
end