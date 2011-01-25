require 'etc'

class Rubbish
  def initialize
    @pwd = ENV['PWD']
    @previous_dir = @pwd
    while true
      hostname = `hostname`.chomp.split('.').first
      @pwd = @pwd.gsub(Etc.getpwuid.dir, '~')
      @prompt = "#{ENV['USER']}@#{hostname}:#{@pwd}$ "
      print @prompt
      
      arr = gets
      return if arr.nil?
      arr = arr.chomp.split(' ')
      begin
        @command = arr.first
        if @command
          @command = @command.to_sym
        else 
          next
        end
      rescue ArgumentError => e
        puts 'ERROR ERROR ERROR'
      end
      if arr[1..-1].empty?
        @arguments = nil
      else
        @arguments = arr[1..-1]
      end
      
      @system_command = false
      
      if @command == :initialize
        output = method_missing(@command, @arguments)
      else
        output = send(@command, @arguments)
      end
      if @system_command
        puts "No command or method found: #{@command}" unless output
      elsif output && !output.blank?
        puts output
      end
    end
  end
  
  def cd(dir)
    begin
      home = Etc.getpwuid.dir
      old_prev_dir = @previous_dir
      if dir.nil?
        @previous_dir = Dir.pwd
        Dir.chdir(home)
      else
        dir = dir.first.gsub('~', home)
        dir = @previous_dir if dir == '-'
        @previous_dir = Dir.pwd
        Dir.chdir(dir)
      end
    rescue Errno::ENOENT => e
      puts "No such directory: #{dir}"
      @previous_dir = old_prev_dir
    end
    @pwd = Dir.pwd
    return nil
  end
  
  def method_missing(sym, *args, &block)
    @system_command = true
    exec = sym.to_s
    if args && !args.empty?
      args.each { |arg| exec += " #{arg.to_s}" }
    end
    system "#{exec}"
  end
  
end

Rubbish.new