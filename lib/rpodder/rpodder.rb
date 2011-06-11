#
# rpodder, podcast catching client written in Ruby.
#
# Copyright (c) 2011 Anton Ivanov anton.al.ivanov(no spam)gmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'net/http'
require 'uri'
require 'rexml/document'
require 'fileutils'

#TODO:'Quick-and-dirty' implementation just to make the first end-to-end test pass. 
#Re-factor the code to make it more object oriented and reduce duplication, cover with unit tests
#A few classes should be extracted, in the resulting code there should not be so many comment as now

if __FILE__ == $PROGRAM_NAME

  #Reading arguments
  podcastURL = ARGV[0]
  podcastDirectory = ARGV[1]
  
  #Creating the podcast directory if it does not exist
  FileUtils.mkdir_p(podcastDirectory) if !File.exists?(podcastDirectory) 
  
  #Reading XML feed
  url = URI.parse(podcastURL)
  response = Net::HTTP.start(url.host, url.port) do |http|
    http.get(url.path)
  end
  xmlFeed = response.body

  #Parsing the feed to get the episodes  
  episodes = Array.new()
  xmlFeed = REXML::Document.new(xmlFeed)

  xmlFeed.elements.each("rss/channel/item") do |episode|
     episodes << episode.elements["enclosure"].attributes["url"]
  end
  
  #Getting the title of the podcast and computing the folder to store the episodes in
  title = REXML::XPath.first(xmlFeed, "rss/channel/title").text
  podcastFolderName = title.downcase.gsub(/\s/, "")
  
  podcastFolderFullName = File.join(podcastDirectory, podcastFolderName)

  #Creating the podcast folder if it does not exist
  FileUtils.mkdir_p(podcastFolderFullName) if !File.exists?(podcastFolderFullName) 
  
  #Downloading the episodes into the folder with 'wget'
  episodes.each do |episode|
    
    #Getting the name of the episode
    episodeFileName = episode[(episode.rindex(/\//) + 1)..-1]
    episodeFileFullName = File.join(podcastFolderFullName, episodeFileName)
    system("wget \"#{episode}\" -O #{episodeFileFullName}")
  end
end