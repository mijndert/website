# == Set variables =========================================

DATE = Time.now.strftime("%Y-%m-%d")
TIME = Time.now.strftime("%H:%M:%S")
POST_DIR = '_posts'
PERMALINK = '/writing/posts/'

# == Definitions =========================================

def prompt(*args)
  print(*args)
  gets
end

# == Task/post =============================================

desc "Generate new post"
task :post do

  puts 'Please write the post title'
  @name = STDIN.gets.chomp

  @title = @name.downcase.strip.gsub(' ', '-')
  @file = "#{POST_DIR}/#{DATE}-#{@title}.markdown"

  if File.exists?("#{file}")
    raise 'file already exists'
  else
    File.open(@file, 'a+') do |file|
      file << "---\n"
      file << "layout: post\n"
      file << "title: \"#{@name}\"\n"
      file << "date: #{DATE} #{TIME} +02:00\n"
      file << "permalink: #{PERMALINK}#{@title}/\n"
      file << "---\n"
    end
  end
end
