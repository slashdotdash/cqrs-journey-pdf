#!/usr/bin/env ruby

# Generate a PDF of the Microsoft Patterns & Practices documentation (https://github.com/mspnp/cqrs-journey-doc/)
# Uses gimili (https://github.com/walle/gimli)

require 'fileutils'
require 'iconv'
require 'rubygems'

gem 'gimli'
require 'gimli'

# monkey-path Fixnum class with ordinalize method from ActiveSupport
class Fixnum
  def ordinalize
    if (11..13).include?(self % 100)
      "#{self}th"
    else
      case self % 10
        when 1; "#{self}st"
        when 2; "#{self}nd"
        when 3; "#{self}rd"
        else    "#{self}th"
      end
    end
  end
end

# extend Gimli to support table-of-contents and cover generation
module GimliExtension
  attr_accessor :pdf_title
    
  def pdf_kit(html)
    options = {}

    options.merge!({ :header_right => '[page]' })
    options.merge!({ :title => "Microsoft patterns & practices #{@pdf_title}", :outline => true })
    options.merge!({ :page_size => 'A4', :cover => "file://#{File.realdirpath(File.join(@output_dir, 'cover.htm'))}" })
    options.merge!({ :header_font_name => 'Calluna Sans' })
    options.merge!({ :toc => true, :toc_depth  => 3, :toc_font_name => 'Calluna Sans', :toc_header_text => 'Table of Contents', 
      :toc_header_font_size => '14', :toc_l1_font_size => '13', :toc_l2_font_size => '12', :toc_l3_font_size => '12' })
    
    kit = PDFKit.new(html, options)
    load_stylesheets kit
    kit
  end
end

class PdfGenerator
  attr_reader :input_dir, :output_dir
  
  def initialize(input_dir, output_dir)
    @input_dir, @output_dir = input_dir, output_dir
  end
  
  def to_pdf(input_pattern, output_filename, title, &blk)
    begin      
      FileUtils.rm_rf tmp_dir if Dir.exists?(tmp_dir)
      Dir.mkdir(tmp_dir)

      Dir.chdir(@input_dir) do
        # select files matching input pattern regex
        files = Dir.glob('*.markdown').select {|file| File.basename(file, '.*') =~ input_pattern }
        FileUtils.cp_r files, tmp_dir
        
        # always include the copyright file (as the first page) and images dir
        FileUtils.cp_r 'Copyright.markdown', File.join(tmp_dir, '00_Copyright.markdown')
        FileUtils.cp_r 'images', tmp_dir
      end

      FileUtils.cp_r File.join(@output_dir, 'cover.htm'), tmp_dir
      FileUtils.cp_r File.join(@output_dir, 'cover.png'), tmp_dir
      FileUtils.cp_r File.join(@output_dir, 'mspnp_logo.png'), tmp_dir        

      Dir.chdir(tmp_dir) do
        Dir.glob('*.markdown') do |filename|
          content = File.read filename
          
          ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
          content = ic.iconv(content + ' ')[0..-2]
          
          File.open(filename, 'w') do |writer|
            # allow modification of the content
            if block_given?
              yield content
            end
            
            writer.write content
          end
        end
        
        # enable C# syntax highlighting
        syntax_highlighting(tmp_dir)

        # output PDF stylesheet
        File.open('gimli.css', 'w') do |css|
          css.write <<-EOF
body { font-family: 'Calluna' !important; font-size: 18px; }
h1,h2,h3,h4,h5,h6 { font-family: 'Calluna Sans'; font-weight: bold; }
h1 { font-size: 2.25em; }
h2 { font-size: 1.85em; }
h3 { font-size: 1.7em; }
h4 { font-size: 1.5em;}
p,ul,ol,table { font-size: 18px; }
p { line-height: 1.25em; }
ul li, ol li { margin-bottom: 0.5em;}
img { max-width: 640px; }
table { width: 100%; max-width: 640px; word-wrap: break-word; font-size: 0.8em; }
table { border-collapse:collapse; }
table,th, td { border: 1px solid black; }
pre, code, tt, .highlight pre, pre { font-family: 'Monaco'; font-size: 14px; }
          EOF
        end
                
        files = ::Gimli::Path.list_valid('.', false).map { |file| ::Gimli::MarkupFile.new(file) }
        converter = ::Gimli::Converter.new(files, true, false, false, output_filename, '.', 'gimli.css')
        
        # Extend Gimli with support for table-of-contents and covers
        converter.extend(GimliExtension)

        converter.pdf_title = title
        converter.convert!        
      end
      
      FileUtils.mv File.join(tmp_dir, "#{output_filename}.pdf"), File.join(@output_dir, "#{output_filename}.pdf")
    rescue Exception => e
      puts e
    ensure
      FileUtils.rm_rf tmp_dir
    end
  end
  
  def syntax_highlighting(dir)
    Dir.chdir(tmp_dir) do
      Dir['*.markdown'].each do |file|
        text = File.read(file)
        
        text.gsub!(/```Cs/, '```csharp')
        text.gsub!(/``` /, '```')
        
        File.open(file, 'w') do |writer|
          writer.write text
        end
      end      
    end
  end
  
  def tmp_dir
    '/tmp/cqrs-pdf'
  end
end

unless ARGV.length == 2
  puts "usage: ruby generate.rb <input_dir> <output_dir>"
  exit
end

input_dir, output_dir = ARGV

generator = PdfGenerator.new(input_dir, output_dir)

generator.to_pdf(/00_WhatOthersSaying|01_Foreword|Journey|Reference|Tales/, 'mspnp-cqrs-journey', 'CQRS Journey') do |content|
  # remove final notice from all content
  content.gsub!('### This version of this chapter was part of our working repository during the project. The final version of this chapter is now available on MSDN at [http://aka.ms/cqrs](http://aka.ms/cqrs).', '')
  
  # strip (Chapter Title) suffix from titles
  content.gsub!(/(# .*) \(Chapter Title\)/, '\\1')
end