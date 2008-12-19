require 'net/telnet'
require 'logger'

class ExchangeCleaner

	def initialize
		@log = Logger.new(STDOUT);	@log.level = Logger::DEBUG
	end

	def delete_pesky_mails(server,username,password,dry_run)
		folders_to_check = ['INBOX', 'Deleted Items']
		connect_to_exchange server,username, password
		folders_to_check.each { |b| examine_and_delete_messages_in b,dry_run }
		logout_and_close
	end

	private 
	def list_all_folders 			
		send_command "? LIST \"\" \"*\""; 	
	end	

	def select_box box
		send_command "? SELECT \"#{box}\"";					
	end

	def logout_and_close
		send_command "? logout"
		@client.close
	end
	
	def examine_and_delete_messages_in box, dry_run
		@log.debug("examining folder #{box}")
		text = select_box box 		
		number_of_messages = 0
		if text.include? 'EXISTS'
			 array = text.split('*')
			 number_of_messages = array[1].gsub(/EXISTS/,'').strip.to_i
		end

		if number_of_messages > 0
			(1...number_of_messages).each do |i|
				compatible = is_rfc_822_compatible? box,i			
				@log.debug("#{box}-message-#{i}-rfc-compatible?-#{compatible}")				
				@log.info("#{box}-message-#{i}-rfc-compatible?-#{compatible}") if !compatible
				if !compatible
					if dry_run.eql?('y')
						delete_message box,i	
					else
						puts "I could have deleted this message you chicken"
					end	
				end
			end
		end	
	end

	
	def delete_message box, message_number
		@log.info("Deleting message #{box}-#{message_number}")
		send_command "? store #{message_number} +FLAGS (\Deleted)"
		send_command "? expunge" 
	end
	
	def is_rfc_822_compatible? box,message_number
		@log.debug("Checking#{box}, #{message_number}")
		text = send_command "? FETCH #{message_number} rfc822.header"
		!text.include? 'NO The requested message could not be converted to an RFC-822 compatible format'
	end

	def send_command command
		text = ''
		begin
			@client.cmd(command) { |c| @log.debug(c.chomp) ; text << c }
		rescue Exception=>e
		end
		text
	end

	def connect_to_exchange server, username, password
		@client = Net::Telnet.new('Host' => server, 'Port' => '143',"Prompt" => /[#>:]/n, 'Timeout' => 5 )
		login username, password
	end

	def login username, password	
		send_command "? LOGIN #{username} #{password}"; 	
	end

end

if ARGV.length != 4
	puts "please provide server, username, password and dry run (y/n) "
	exit -1
end

e = ExchangeCleaner.new
e.delete_pesky_mails ARGV[0], ARGV[1], ARGV[2], ARGV[3]


