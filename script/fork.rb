#!/usr/bin/env ruby
# Copyright (c) 2007, Hongli Lai
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this list
#   of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice, this list
#   of conditions and the following disclaimer in the documentation and/or other
#   materials provided with the distribution.
# * Neither the name of the Hongli nor the names of its contributors may be used to
#   endorse or promote products derived from this software without specific prior
#   written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

count = ARGV[0].to_i
if count < 1
	count = 1
end
puts "Spawning #{count} Rails processes..."


#### Preload Rails libraries. ####
require File.dirname(__FILE__) + "/../config/environment"
require 'fcgi_handler'
require 'ruby_version_check'
require 'initializer'
require 'dispatcher'

Rails::Initializer.run
require 'breakpoint' if defined?(BREAKPOINT_SERVER_PORT)
require_dependency('application.rb')

class Object
	# Remove some constants so we don't get an annoying warning.
	[:RAILS_GEM_VERSION, :MAX_SESSION_TIME].each do |sym|
		if constants.include?(sym.to_s)
			remove_const(sym)
		end
	end
end


#### Fork the FastCGI processes. ####
require 'socket'
children = []
count.times do |i|
	file = "log/fastcgi.socket-#{i}"
	pid = fork do
		if File.exist?(file)
			File.unlink(file)
		end
		server = UNIXServer.new(file)
		$stdin.reopen(server)
		puts "* Process #{i} listening on socket #{file}"
		load File.dirname(__FILE__) + '/../public/dispatch.fcgi'
	end
	children.push([pid, file])
end

children.each do |child|
	pid = child[0]
	file = child[1]
	Process.wait(pid)
	File.unlink(file)
end

