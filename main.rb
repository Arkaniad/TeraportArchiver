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
$BOOK_LENGTH = [507, 493] # Only know the first two book lengths for now. Probably will use dates instead.

# Create a logger and format it nicely.
log = Logger.new(STDOUT)
log.level = Logger::DEBUG
log.formatter = proc do |severity, datetime, progname, msg|
  datetime = datetime.strftime("%Y-%m-%d %H:%M:%S")
    "[#{severity}@#{datetime}] #{msg}\n"
end


log.info("Initializing Teraport Engine")
log.debug("Starting at #{$EPOCH.to_s} and fetching from #{$BASE_HOST}")
log.debug("Getting the first comic! schlock#{$EPOCH.strftime($DATE_FORMAT)}.png")
Net::HTTP.start($BASE_HOST) do |http|
  resp = http.get( "#{$BASE_DIR}schlock#{$EPOCH.strftime($DATE_FORMAT)}.png" )
  open("/tmp/#{$EPOCH.strftime($DATE_FORMAT)}.png", "a+") do |file|
    file.write(resp.body)
  end
end
log.debug("File lies at /tmp/#{$EPOCH.strftime($DATE_FORMAT)}.png")
log.debug("Opening in firefox!")
system("firefox /tmp/#{$EPOCH.strftime($DATE_FORMAT)}.png")
