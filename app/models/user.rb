class User < ActiveRecord::Base
	before_create :set_register_date

	has_secure_password
	validates_uniqueness_of :username, :email, :message => "already taken"
	validates_presence_of :username, :message => "can't be blank"

	# before_save :uppercase_fields

	ADMINISTRATOR 	= 1.freeze
	MODERATOR		= 2.freeze

	%w(ADMINISTRATOR MODERATOR).each do |state|
		define_method "#{state.downcase}?" do
			role == self.class.const_get(state)
		end
	end

	# def uppercase_fields
	#     self.attributes.each do |key, value|
	#     	self.attributes[key] = value.to_s.upcase!
	#     end
	# end

	def set_register_date
		self.register_at = DateTime.now
		self.login_at = DateTime.now
		self.logout_at = DateTime.now
	end

	def label_status
		if self.status
			'<i class="icon-ok" title="Active"></i>'.html_safe
		else
			'<i class="icon-remove" title="Inactive"></i>'.html_safe
		end
	end
	
  def set_deleted
    # update(is_deleted: true)
    update(status: false)
  end

  def set_enabled
    # update(is_deleted: false)
    update(status: true)
  end
end