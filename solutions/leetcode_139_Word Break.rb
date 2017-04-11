# @param {String} s
# @param {String[]} word_dict
# @return {Boolean}
def word_break(s, word_dict)
  s2 = s[0..s.length]
  s_arr = [s]
  s2_arr = [s2]
  word_dict.sort! { |x,y|
    xl = x.length.to_i
    yl = y.length.to_i
    xl <=> yl
  }
  word_dict.reverse.each { |word|
    s_arr.each_with_index { |s, index|
      s_arr[index] = s.split(word)
    }
    s_arr.flatten!
  }
  word_dict.each { |word|
    s2_arr.each_with_index { |s, index|
      s2_arr[index] = s.split(word)
    }
    s2_arr.flatten!
  }
  # word_dict.each {|word|
  #   s2.gsub! word, ''
  # }
  puts s_arr
  puts s2_arr
  puts word_dict
  if s_arr.length == 0 || s2_arr.length == 0
      return true
  end
  false
end
