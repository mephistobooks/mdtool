#! /usr/bin/env ruby
#
#

require 'pp'
require 'uri'
require 'fileutils'
#require 'iconv'


#
SRCDIR = "wiki"
DSTDIR = "dst"

SRCCPS = "EUC-JP"
DSTCPS = "UTF-8"

SRCEXT = ".txt"
DSTEXT = ".md"


#
#
#
def list( pukiwiki_dir = SRCDIR )
  ret = []

  for fn in `ls #{pukiwiki_dir}/*.txt`.split(/\s/).map!{|e| e.chomp}
    len = File.basename(fn, ".txt").length
    if len%2 > 0
      then raise "Strange filename length #{len} for #{fn}"
    end

    #
    #puts "#{fn} #{File.basename(fn, ".txt").size/2.0}"
    ret.push( fn )
  end

  ret
end

# encode the name of filename to uri-form.
# ex. "A5D7A5EAA5ADA5E5A5A2" (EUC-coded string)
#     => "q=%A5%D7%A5%EA%A5%AD%A5%E5%A5%A2" (uri query form)
#
def _encode_filename( orig )
  "q=" + '%' + orig.scan(/.{1,#{2}}/).join('%')
end

# decode uri-encoded string as just string.
# ex. "q=%A5%D7%A5%EA%A5%AD%A5%E5%A5%A2" (uri query form)
#     => "プリキュア" (string in EUC-JP)
#
def _decode_as_s( uri, kcode=Encoding::EUCJP )
  URI.decode_www_form( uri, kcode ).last.last
end

# ordinary code conversion: EUC-JP to UTF-8.
#
#
def conv_eucjp2utf8( s_euc )
  # String#encode
  s_euc.encode( 'UTF-8', 'EUC-JP' )
end

# change from EUC-encoded string to string in UTF-8.
# ex. "A5D7A5EAA5ADA5E5A5A2" (EUC-coded string)
#     => "プリキュア" (in UTF-8)
#
def conv_fn2utf8( fn )
  conv_eucjp2utf8( _decode_as_s( _encode_filename( fn ) ) )
end

# change string in utf-8 to EUC-JP-encoded string.
# ex. "プリキュア" (in UTF-8)
#     => "A5D7A5EAA5ADA5E5A5A2" (EUC-coded string)
def conv_utf82fn( s_in_utf8 )
  s_in_utf8.encode('EUC-JP','UTF-8').split(//).map{|c| c.codepoints.map{|cd| sprintf("%X",cd)}}.flatten.join
end

################################################################

# convert PukiWiki data (xxxx.txt) into files in HFS+.
# * treats basename (xxxx of xxxx.txt) as EUC-encoded string
# ==== Args
# * srcdir  PukiWiki data dir
# * dstdir  directory for output
#
def convert( srcdir = SRCDIR, dstdir = DSTDIR )
  list( srcdir ).each do |old|
    puts "for <#{old}>"
    #
    tmp = ""
    newfn = nil

    # "wiki/A5D7A5EAA5ADA5E5A5A2.txt" => "A5D7A5EAA5ADA5E5A5A2"
    #
    #
    tmp = File.basename( old, SRCEXT )

    # "A5D7A5EAA5ADA5E5A5A2" (EUC-coded string)
    # => "プリキュア" (string in UTF-8)
    #
    tmp = conv_fn2utf8( tmp )

    # escape for file name convention (in HFS+).
    tmp = Regexp.escape( tmp )  # paren, $, etc.
    #tmp = tmp.gsub(':', '\:')   # no needs to escape with colon.
    tmp = tmp.gsub('\\ ', ' ')   # unescape with spaces.
    tmp = tmp.gsub('\\.', '.')   # unescape with periods.
    tmp = tmp.gsub('\\-', '-')   # unescape with hyphens.
    tmp = tmp.gsub('\\(', '(')   # unescape with parens(open).
    tmp = tmp.gsub('\\)', ')')   # unescape with parens(close).


    # Create directories when slashes are contained in filename.
    # (We cannot use slashes in HFS+)
    #
    if tmp.match('/')
      # # If you want flat filename, substitute it with some string.
      # # In this case, digging directories should not be done.
      # #
      # tmp.gsub('/', "%2F")

      # dig directories.
      puts "  create dirs for #{tmp}."
      tmpdir = dstdir+"/"+File.dirname( tmp )
      FileUtils.makedirs( tmpdir )
      if not(Dir.exists?( tmpdir ))
        raise "Cannot create dir"
      else
        puts "  Dir #{tmpdir} is created."
      end

      newfn = File.basename( tmp )  # filename w/o directory and ext.
    end

    if not( newfn )
      newfn = dstdir + "/" + tmp + DSTEXT
    else
      newfn = dstdir + "/" + File.dirname( tmp ) + "/" + newfn + DSTEXT
    end


    puts "  Processing #{newfn}..."
    #`cp -f #{old} #{newfn}`
    `echo "# #{newfn}" > "#{newfn}"`
    #`iconv -f #{SRCCPS} -t #{DSTCPS} #{old} >> "#{newfn}"`
    `iconv -f #{SRCCPS} -t #{DSTCPS} #{old} | ./nf-pw2md.rb >> "#{newfn}"`
    puts "  Done."

  end
end


################################################################

# Main.

convert()


#### endof filename: pw2mw.rb
