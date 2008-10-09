include ActionView::Helpers::NumberHelper
# ActsAsUploadable
module Artenlinea
  module Acts #:nodoc:
    module Uploadable #:nodoc:
      
      def self.included(base)
            @@content_types      = ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg']
            mattr_reader :content_types, :attachment_options
            attr_accessor :uploaded_data
               #base.class_inheritable_accessor :attachment_options
          base.extend ClassMethods
      end

      module ClassMethods
        
        def acts_as_uploadable(options = {})
           options[:min_size]         ||= 1
            options[:max_size]         ||= 1.megabyte
            options[:size]             ||=  1.megabyte #(options[:min_size]..options[:max_size])
            options[:thumbnails]       ||= {}
            options[:content_type] ||= ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png', 'image/jpg'] 
            options[:thumbnail_class]  ||= self
            options[:s3_access]        ||= :public_read
            options[:s3_bucket] ||= 'animalita'
            options[:path] ||= self.to_s.tableize
             write_inheritable_attribute :attachment_options, options
             class_inheritable_reader :attachment_options

            validate_on_create :validate_size
            after_save :write_file ,:if=>:file_required?
            after_destroy :delete_all_s3_copies
            validate              :attachment_attributes_valid? , :if=>:file_required?
               
          include Artenlinea::Acts::Uploadable::InstanceMethods
          extend Artenlinea::Acts::Uploadable::SingletonMethods
        end
    
      end

      module SingletonMethods
      end

      module InstanceMethods
        # Add instance methods here
        #upload_data=
         def uploaded_data() nil; end

          def uploaded_data=(file_attributes)
            unless file_attributes.blank?
              @file = File.open(file_attributes[:path])
              write_attribute(:image, sanitize_image(file_attributes[:name]))
              write_attribute(:content_type, file_attributes[:content_type])
              write_attribute(:size, file_attributes[:size])
              write_attribute(:path, file_attributes[:path])
            end
          end
        
        def validate_size
          if @file.blank?
           errors.add(:uploaded_data,'is required.')
          end
          if !@file.blank? && self.size.to_i > 3.megabyte
            errors.add(:image,'es muy grande ' + number_to_human_size(self.size.to_i)  )
          end
        end
        
        def file_required?
          !@file.blank? 
        end
        
        def write_file
          write_to_local
          process_img
          migrate_to_s3
          delete_all_local_copies  
        end
        
        #sanitizar
         def sanitize_image(image)
              # get only the image, not the whole path (from IE)
              just_image = File.basename(image)
              # replace all none alphanumeric, underscore or perioids with underscore
             just_image.gsub(/[^\w\.\_]/,'_')
          end
          
         # validates the size and content_type attributes according to the current model's options
          def attachment_attributes_valid?
            [:content_type].each do |attr_name|
              enum = attachment_options[attr_name]
               errors.add attr_name, ActiveRecord::Errors.default_error_messages[:inclusion] unless enum.nil? || enum.include?(send(attr_name))
            end
          end
        
        ##file operations
        def write_to_local(type = 'original')
              FileUtils.mkdir_p(self.local_path(type)) unless File.exists?(self.local_path(type))
              File.open(self.local_path_with_file,'w') do |file|
              file.puts @file.read
              end 
           end

         #esto me retorna solo el path sin el archivo
         def local_path(type = 'original')
            dir_photos = File.join(RAILS_ROOT,'public',attachment_options[:path],self.id.to_s,type)
           base_path = dir_photos
           return  base_path     
         end

         #esto me retorna  el path con el archivo
         def local_path_with_file(type = 'original')
            dir_photos = File.join(RAILS_ROOT,'public',attachment_options[:path],self.id.to_s,type)
            base_path = dir_photos +"/"
            image_path = self.image
            return  base_path + image_path    
         end
         
         #el path remoto para s3
         def remote_path(type = 'original')
          # base_path = "#{self.user_id}/art_works/#{self.id}/#{type}/"
           base_path = "#{self.user_id}/#{attachment_options[:path]}/#{self.id}/#{type}/"
           return  base_path + self.image
         end  
         #el path completo de la imagen en s3
         def s3_path(type = 'original')
           return "http://s3.amazonaws.com/#{attachment_options[:s3_bucket]}/" + remote_path(type)
         end

         #procesamos la imagen , generamos las 3 copias
         def process_img    
           path = self.local_path_with_file
           ImageScience.with_image(path) do |img|
              img.resize_to_width(550) do |crop|
                FileUtils.mkdir_p(self.local_path('resize')) unless File.exists?(self.local_path('resize'))
                 path = self.local_path_with_file('resize')
                crop.save(path) 
               end
             img.cropped_thumbnail(100) do |thumb|
               FileUtils.mkdir_p(self.local_path('thumb')) unless File.exists?(self.local_path('thumb'))
               path = self.local_path_with_file('thumb')
               thumb.save(path)
             end
           end
         end

         #Subir la foto a S3
         #artenlinea_bucket = AWS::S3::Bucket.find('artenlinea_dev')
         def migrate_to_s3
         bucket = attachment_options[:s3_bucket]
           %w(original thumb resize).each do |type|
             #Solo lo subo a S3 si el archivo no existe
             unless AWS::S3::S3Object.exists?(self.remote_path(type), bucket)
               AWS::S3::S3Object.store(self.remote_path(type), 
               open(self.local_path_with_file(type)), bucket,:access=>:public_read)
             end
           end
         end

         def delete_all_local_copies  
           #Borro las fotos de mi pc!!
           %w( original thumb resize).each do |type|
             FileUtils.rm(self.local_path_with_file(type))
           end   
         end

         def delete_all_s3_copies
            bucket = attachment_options[:s3_bucket] #S3_BUCKET
            %w( original thumb resize).each do |type|
              if AWS::S3::S3Object.exists?(self.remote_path(type), bucket)
                AWS::S3::S3Object.delete(self.remote_path(type),  bucket)
              end
             end
         end 
         
      end
    end
  end
end
