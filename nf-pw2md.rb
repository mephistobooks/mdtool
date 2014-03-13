#! /usr/bin/env ruby
# filename: nf-pw2md.rb
# PukiWiki to Markdown for OSX.
#
# input: STDIN
# output: STDOUT
#

require 'pp'
require 'uri'
require 'fileutils'


#

#
RE_COMMENT_PW="^\/{2}(.*)"
RE_NEWLINE_PW="~\s*$"

# section.
RE_SEC_PW   = "^\\*{1}($|[^*].*)"
RE_SSEC_PW  = "^\\*{2}($|[^*].*)"
RE_SSSEC_PW = "^\\*{3}($|[^*].*)"
#RE_SSSSEC_PW = "^\*{4,}[^*]"

# region (multiple lines)

## citation.
RE_CITE_PW = "^ (.*)"

## reference.
RE_CREF1_PW = "^>{1}($|[^>].*)"
RE_CREF2_PW = "^>{2}($|[^>].*)"
RE_CREF3_PW = "^>{3}($|[^>].*)"

## lists.
RE_UI1_PW = "^-{1}($|[^-].*)"
RE_UI2_PW = "^-{2}($|[^-].*)"
RE_UI3_PW = "^-{3}($|[^-].*)"

RE_OI1_PW = "^\\+{1}($|[^+].*)"
RE_OI2_PW = "^\\+{2}[^+]"
RE_OI3_PW = "^\\+{3}[^+]"

#

## strong/italic/delete.
RE_STRONG_PW = "(^|[^'])'{2}([^']*?)'{2}($|[^'])"
RE_ITALIC_PW = "'{3}([^']*?)'{3}"
RE_DEL_PW = "(^|[^%])%{2}([^%]*?)%{2}($|[^%])"

# break line.
RE_BLINE_PW = "^-{3}"

RE_MAP = {}

RE_MAP[RE_COMMENT_PW]   = lambda{|x,y| "<!-- #{x} -->" }
RE_MAP[RE_NEWLINE_PW]   = lambda{|x,y| y.gsub(/~$/, " "*2) }

RE_MAP[RE_SEC_PW]   = lambda{|x,y| "# #{x}" }
RE_MAP[RE_SSEC_PW]  = lambda{|x,y| "## #{x}" }
RE_MAP[RE_SSSEC_PW] = lambda{|x,y| "### #{x}" }

RE_MAP[RE_CITE_PW] = lambda{|x,y| "```\n#{x}\n```" }

RE_MAP[RE_CREF1_PW] = lambda{|x,y| "> #{x}" }
RE_MAP[RE_CREF2_PW] = lambda{|x,y| "> #{x}" }
RE_MAP[RE_CREF3_PW] = lambda{|x,y| "> #{x}" }

RE_MAP[RE_UI1_PW] = lambda{|x,y| "* #{x}" }
RE_MAP[RE_UI2_PW] = lambda{|x,y| " "*4 + "* #{x}" }
RE_MAP[RE_UI3_PW] = lambda{|x,y| " "*4*2 + "* #{x}" }

RE_MAP[RE_OI1_PW] = lambda{|x,y| "1. #{x}" }
RE_MAP[RE_OI2_PW] = lambda{|x,y| " "*4 + "1. #{x}" }
RE_MAP[RE_OI3_PW] = lambda{|x,y| " "*4*2 + "1. #{x}" }

RE_MAP[RE_STRONG_PW] = lambda{|x,y| y.gsub(/#{RE_STRONG_PW}/, '\1__\2__\3') }
RE_MAP[RE_ITALIC_PW] = lambda{|x,y| y.gsub(/#{RE_ITALIC_PW}/, '_\1_') }
RE_MAP[RE_DEL_PW]    = lambda{|x,y| y.gsub(/#{RE_DEL_PW}/, '\1~~\2~~\3') }


# RE_MAP_MW = {}
# RE_MAP_MW[RE_SEC_PW] = lambda{|x| "==#{x} ==" }
# RE_MAP_MW[RE_SSEC_PW] = lambda{|x| "===#{x} ===" }
# RE_MAP_MW[RE_SSSEC_PW] = lambda{|x| "====#{x} ====" }


#
def _replace( line, regexp, re_map )
  ret = nil
  if line =~ /#{regexp}/ then
    ret = re_map[regexp].call( $1, line )
  end

  #
  if ret.nil?
    line
  else
    ret
  end
end

#
def replace( line, re_map )
  ret = line

  re_map.keys.each do |re|
    tmp = _replace( line, re, re_map )
    if tmp != line then
      ret = tmp
      break
    end

  end

  ret
end


################################################################

# Main.

while l=$stdin.gets do

  l.chomp!
  #$stderr.puts l
  puts replace(l, RE_MAP)

end


#### endof filename: pw2mw.rb
