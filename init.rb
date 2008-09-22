# Include hook code here
require "image_science"
require 'acts_as_uploadable'
require "view_helpers" 
require 'irregular_science'
ActionView::Base.send( :include, UploadableViewHelper)
ActiveRecord::Base.send(:include, Artenlinea::Acts::Uploadable)
ActiveRecord::Base.send(:include, IrregularScience)


puts 'iniciando acts_as_uploadable'