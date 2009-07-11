# Helper functions for determining platform
class Platform
	def self.mac?
	  return RUBY_PLATFORM =~ /darwin/
	end
	
	def self.windows?
	  return RUBY_PLATFORM =~ /mswin/
	end
	
	def self.linux?
		return RUBY_PLATFORM =~ /linux/
	end
end
