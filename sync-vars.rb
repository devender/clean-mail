username = 'devender'
#all the variables you want to be copied/sync
to_copy = ['PATH', 'HOME', 'LOGNAME']

props = Hash.new
to_copy.each { |name| props[name] = ENV[name] }

File.open("/Users/#{username}/.MacOSX/environment.plist", "w") do |file| 
  file.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" 
  file.puts "<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"
  file.puts "<plist version=\"1.0\">"
  file.puts "<dict>"
  props.each do |key,value|
    file.puts "        <key>#{key}</key>"
    file.puts "        <string>#{value}</string>"
  end
  file.puts "</dict>"
  file.puts "</plist>"
end 
