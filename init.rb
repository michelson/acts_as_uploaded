# Include hook code here

require 'acts_as_uploadable'
require "view_helpers" 
ActionView::Base.send( :include, UploadableViewHelper)
ActiveRecord::Base.send(:include, Artenlinea::Acts::Uploadable)

puts 'iniciando acts_as_uploadable'