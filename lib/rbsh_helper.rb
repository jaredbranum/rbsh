module RbshHelper
  def self.ruby_indentation_level(str)
    #return 1 unless remove_strings!(str) == 0
    level = 0
    level += (str.count('{') - str.count('}') >= 0) ? str.count('{') - str.count('}') : 0
    level += (str.count('(') - str.count(')') >= 0) ? str.count('(') - str.count(')') : 0
    level += (str.count('[') - str.count(']') >= 0) ? str.count('[') - str.count(']') : 0
    
    str.split("\n").each do |line|
      if has_keyword?(line)
        level += 1 unless line =~ /\send(\s|$).*/
      end
    end
    level
  end
  
  private

  # this string parsing is going to get pretty complicated.
  # do it later
  #
  # def remove_strings(str)
  #   str = remove_empty_strings(str)
  #   while true
  #     first_char = "'"
  #     first_pos = str.index("'")
  #     if first_pos && (str.index('"') < first_pos)
  #       first_char = '"'
  #       first_pos = str.index('"')
  #     end
  #     if first_pos && (str.index('/') < first_pos)
  #       first_char = '/'
  #       first_pos = str.index('/')
  #     end
  #     return 0 if first_pos.nil?
  #     return 1 if str.count(first_char) == 1
  #     first_char = Regexp.quote(first_char)
  #     str = str.gsub(/#{first_char}[^\\]+#{first_char}/)
  #   end
  # end
  # 
  # def remove_empty_strings(str)
  #   str = str.gsub(/""/,'')
  #   str = str.gsub(/''/,'')
  #   str = str.gsub(/\/\//,'')
  #   str.gsub(/\\\\/,'')
  # end
  
  def self.has_keyword?(str)
    !!(str =~ /(.*(\s|^)do\s+|^\s*(module|class|def|if|unless|case|while|until|for|begin))/)
  end
  
  def num_chars(str,chr)
    #str.each
  end
end