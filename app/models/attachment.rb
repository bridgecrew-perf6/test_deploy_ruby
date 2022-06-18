class Attachment < ActiveRecord::Base 
	attr_accessor :_destroy
	belongs_to :assetable, polymorphic: true

  	has_attached_file :asset,
                    :url  => "/uploads/attachment/:style_:basename.:extension",
                    :path => ":rails_root/public/uploads/attachment/:style_:basename.:extension",
                    :default_url => "",
                    :keep_old_files => true
end
