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

module RPodder
  
  class FeedFetcher

    def initialize(podcastURL)
      @podcastURL = podcastURL
    end
    
    def fetch
      url = URI.parse(@podcastURL)
      
      response = Net::HTTP.start(url.host, url.port) do |http|
        path = url.path
        
        #TODO: Test what if there are several query parameters, one parameter, etc?
        path = path + "?" + url.query if !url.query.nil?
        http.get(path)
      end
      response.body
    end
  end
  
  class FeedReader
    
    def initialize(feedXML)
      @feedXML = REXML::Document.new(feedXML)
    end
    
    def episodes
      episodes = []
      @feedXML.elements.each("rss/channel/item") do |episode|
         episodes << episode.elements["enclosure"].attributes["url"]
      end
      episodes
    end
    
    def title
      REXML::XPath.first(@feedXML, "rss/channel/title").text
    end
  end
  
  class FeedStorage
    
    def initialize(workDirectory, feedReader, downloader)
      @workDirectory = workDirectory
      @feedReader = feedReader
      @downloader = downloader
    end
    
    def storeEpisodes
      folder = feedFolder
      FileUtils.mkdir_p(folder) if !File.exists?(folder) 
      
      @feedReader.episodes.each do |episode|
        episodeFileFullName = File.join(folder, episodeName(episode))
        @downloader.download(episode, episodeFileFullName)
      end
    end
    
    def episodeName(episode)
      episode[(episode.rindex(/\//) + 1)..-1]
    end
    
    def feedFolder
      podcastFolderName = @feedReader.title.downcase.gsub(/\s/, "")
      File.join(@workDirectory, podcastFolderName)
    end
  end
  
  class FileDownloader    
    def download(fileURL, fileName)
      system("wget \"#{fileURL}\" -O #{fileName}")
    end
  end
end

if __FILE__ == $PROGRAM_NAME

  #Reading arguments
  podcastURL = ARGV[0]
  workDirectory = ARGV[1]
  
  xmlFeed = RPodder::FeedFetcher.new(podcastURL).fetch  
  feedReader = RPodder::FeedReader.new(xmlFeed)
  downloader = RPodder::FileDownloader.new
  feedStorage = RPodder::FeedStorage.new(workDirectory, feedReader, downloader).storeEpisodes
end