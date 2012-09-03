#!/usr/bin/env ruby

# Add the necessary imports.
require "net/http"
require "logger"
require "date"


# Set some globals. Rubyists cringe here!
$EPOCH = Date.new(2000,6,12) # This is the day the comic started!
# This works because, apparently, Howard Tayler never missed a single day.
$DATE_FORMAT = "%Y%m%d"
$PANEL_SUFFIXES = ["a", "b" "c", "d", "-a", "-b", "-c", "-d"] # Should work, I suppose.
$BASE_HOST = "static.schlockmercenary.com" # This is where all the comics are at.
$BASE_DIR = "/comics/"
$STORE_DIR = "#{Dir.getwd}/comics/"
$BOOK_LENGTH = [507, 493] # Only know the first two book lengths for now. Probably will use dates instead.
$LOG = Logger.new(STDOUT)

# Define some handy functions.
def get_comic(date)
  $LOG.debug("GET: http://static.schlockmercenary.com/comics/schlock#{date}.png")
  Net::HTTP.start($BASE_HOST) do |http|
    resp = http.get( "#{$BASE_DIR}schlock#{date}.png" )
    open("#{$STORE_DIR}#{date}.png", "a+") do |file|
      file.write(resp.body)
    end
  end
  $LOG.debug("File lies at #{$STORE_DIR}#{date}.png")
end

# Format the logger nicely.
$LOG.level = Logger::DEBUG
$LOG.formatter = proc do |severity, datetime, progname, msg|
  datetime = datetime.strftime("%Y-%m-%d %H:%M:%S")
    "[#{severity}@#{datetime}] #{msg}\n"
end

$LOG.info("Checking storage directory and creating it if it doesn't exist...")
if File.exist?($STORE_DIR)
  $LOG.info("Directory already exists, wonderful. Continuing as planned.")
else
  Dir.mkdir($STORE_DIR)
  $LOG.info("Created the directory!")
end

$LOG.info("Starting at #{$EPOCH.to_s} and fetching from #{$BASE_HOST}")

while 1 do
  get_comic($EPOCH.strftime("%Y%m%d"))
  $EPOCH=$EPOCH.next  
end
