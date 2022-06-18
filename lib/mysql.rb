class Mysql
	require 'rubygems'
	require	'fileutils'

	def Mysql.full_backup
		begin
			env = (Rails.env.production? ? "production" : "development")

			db_config = YAML::load(IO.read("#{Rails.root}/config/database.yml"))
			db_name = db_config[env]["database"]
			db_user = db_config[env]["username"]
			db_pass = db_config[env]["password"]

			@temp_dir = "/tmp/mysql_backup"
			FileUtils.mkdir_p @temp_dir
			dump_file = "#{@temp_dir}/dump#{Date.today.to_s}.sql"

			cmd = "mysqldump #{db_name} -u#{db_user} -p'#{db_pass}' > #{dump_file}"
			run(cmd)

			ret = File.new(dump_file).read
			# FileUtils.rm_rf(@temp_dir)
			ret
		rescue => e
			return false
		end
	end

	def Mysql.restore(file)
		begin
			env = (Rails.env.production? ? "production" : "development")		

			db_config = YAML::load(IO.read("#{Rails.root}/config/database.yml"))
			db_name = db_config[env]["database"]
			db_user = db_config[env]["username"]
			db_pass = db_config[env]["password"]

			cmd = "mysql -u#{db_user} -p#{db_pass} #{db_name} < '#{file}'"
			run(cmd)

			return true
		rescue => e
			return false
		end
	end

	def Mysql.run(command)
		result = system(command)
		raise("error, process exited with status #{$?.exitstatus}") unless result
	end
end