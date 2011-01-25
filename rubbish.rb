class Rubbish
  def initialize
    while true
      print '$ '
      
      arr = gets.chomp.split(' ')
      begin
        @command = arr.first.to_sym
      rescue ArgumentError => e
        puts 'ERROR ERROR ERROR'
      end
      if arr[1..-1].empty?
        @arguments = nil
      else
        @arguments = arr[1..-1]
      end
      
      if @command == :initialize
        output = method_missing(@command, @arguments)
      else
        output = send(@command, @arguments)
      end
      puts output if output && !output.empty?
    end
  end
  
  def cd(dir)
    begin
      Dir.chdir(dir.first)
    rescue Errno::ENOENT => e
      puts "No such directory: #{dir}"
    end
    return nil
  end
  
  def method_missing(sym, *args, &block)
    exec = sym.to_s
    if args && !args.empty?
      args.each { |arg| exec += " #{arg}" }
    end
    `#{exec}`
  end
  
end

Rubbish.new