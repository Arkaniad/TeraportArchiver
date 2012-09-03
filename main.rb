#!/usr/bin/env ruby

# Add the necessary imports.
require "net/http"
require "logger"
require "date"
require "RMagick"

# Set some globals. Rubyists cringe here!
$EPOCH = Date.new(2000,6,12) # This is the day the comic started!
# This works because, apparently, Howard Tayler never missed a single day.
$DATE_FORMAT = "%Y%m%d"
$PANEL_SUFFIXES = ["nyf", "a", "b", "c", "d", "-a", "-b", "-c", "-d"] # Should work, I suppose.
$FILETYPES = [".png", ".jpg", ".jpeg"]
$BASE_HOST = "static.schlockmercenary.com" # This is where all the comics are at.
$BASE_DIR = "/comics/"
$STORE_DIR = "#{Dir.getwd}/comics/"
$BOOK_LENGTH = [507, 493] # Only know the first two book lengths for now. Probably will use dates instead.
$LOG = Logger.new(STDOUT)

# Define some handy functions.
def get_comic(date)
  $LOG.debug("GET: http://static.schlockmercenary.com/comics/schlock#{date}.png")
  Net::HTTP.start($BASE_HOST) do |http|
    resp = http.get( "#{$BASE_DIR}schlock#{date}#{$FILETYPES[0]}" )
    if(resp.code=="404")
      resp = http.get( "#{$BASE_DIR}schlock#{date}#{$FILETYPES[1]}" )
      if(resp.code=="404")
        $LOG.debug("Multipanel comic!")
        get_multipanel_comic(date)
      else
        write_img(date, resp.body, $FILETYPES[1])
        $LOG.debug("File lies at #{$STORE_DIR}#{date}.jpg")
      end
    else
      write_img(date, resp.body)
      $LOG.debug("File lies at #{$STORE_DIR}#{date}.png")
    end
  end
end

def get_multipanel_comic(date)
  $LOG.debug("Getting multi-panel comic for this date.")
  list = Magick::ImageList.new
  Net::HTTP.start($BASE_HOST) do |http|
    $PANEL_SUFFIXES.each do |sfx|
      resp = http.get("#{$BASE_DIR}schlock#{date}#{sfx}.png")
      if(resp.code=="200")
        $LOG.debug("Got panel #{sfx}")
        list.push(Magick::Image.from_blob(resp.body){self.format = "PNG"}.first)
      end
    end
  end
  $LOG.debug("Stitching multiple panels together.")
  write_img(date, list.append(true).to_blob)
end

def write_img(date, content, fmt=".png")
  open("#{$STORE_DIR}#{date}#{fmt}", "a+") do |file|
    file.write(content)
  end
end

# Format the logger nicely.
$LOG.level = Logger::DEBUG
$LOG.formatter = proc do |severity, datetime, progname, msg|
  datetime = datetime.strftime("%Y-%m-%d %H:%M:%S")
    "[#{severity}@#{datetime}] #{msg}\n"
end

$LOG.info("Checking storage directory and creating it if it doesn't exist...")
if File.exist?($STORE_DIR)
  $LOG.info("Directory already exists, wonderful. Resuming")
  resumedate = Dir.glob("#{$STORE_DIR}*").map!{|ent| Date.parse(File.basename(ent).chomp(".png"))}.sort!.last.strftime("%Y%m%d")
  $EPOCH = Date.parse(resumedate)
else
  Dir.mkdir($STORE_DIR)
  $LOG.info("Created the directory!")
end

$LOG.info("Starting at #{$EPOCH.to_s} and fetching from #{$BASE_HOST}")

# Get all comics from the comic's epoch to now!
(Date.today - $EPOCH).to_i.times do
  get_comic($EPOCH.strftime("%Y%m%d"))
  $EPOCH=$EPOCH.next  
end
