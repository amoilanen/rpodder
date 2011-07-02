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
      raise "Cannot fetch feed. Wrong URL format?" if url.scheme != "http" || url.host.nil? || url.port.nil?
      
      getBody(url.host, url.port, getPath(url))
    end
    
    private
    
    def getPath(url)
      path = url.path
      path = path + "?" + url.query if !url.query.nil?
      path
    end
    
    def getBody(host, port, path)
      response = Net::HTTP.start(host, port) do |http|
        http.get(path)
      end
      response.body
    end
  end
  
  #TODO: Too much boiler-plate code in Episode. Can we get rid of it?
  class Episode
    
    include Comparable
    
    attr_reader :url, :name 
    
    def initialize(url, name)
      @url, @name = url, name
    end
    
    def comparable_fields
      [url, name]
    end
 
    def <=>(other)
      self.comparable_fields <=> other.comparable_fields
    end
  end
  
  class FeedReader
    
    def initialize(feedXML)
      @feedXML = REXML::Document.new(feedXML)
    end
    
    def episodes
      episodes = []
      @feedXML.elements.each("rss/channel/item") do |episode|
         url = episode.elements["enclosure"].attributes["url"]
         name = episode.elements["title"].text
         episodes << Episode.new(url, name)
      end
      episodes
    end
    
    def title
      title = REXML::XPath.first(@feedXML, "rss/channel/title")
      title.text if !title.nil?
    end
  end
  
  class FeedStorage
    
    def initialize(workDirectory, feedReader, downloader, opts = {})
      @workDirectory = workDirectory
      @feedReader = feedReader
      @downloader = downloader
      @useEpisodeNames = !opts[:useEpisodeNames].nil? && opts[:useEpisodeNames]
    end
    
    def storeEpisodes
      folder = feedFolderName
      FileUtils.mkdir_p(folder) if !File.exists?(folder) 
      
      @feedReader.episodes.each do |episode|
        downloadedFileFullName = File.join(folder, downloadedFileName(episode))          
        @downloader.download(episode.url, downloadedFileFullName)
      end
    end
    
    private

    def downloadedFileName(episode)      
      if @useEpisodeNames
        episodeNameBasedName(episode)
      else 
        URLBasedName(episode)
      end
    end
    
    def episodeNameBasedName(episode)
      serverExtension = rightMostPart(episode.url, /\./)        
      (episode.name + "." + serverExtension if !serverExtension.nil?) || episode.name
    end
    
    def URLBasedName(episode)
      shortEpisodeURL = rightMostPart(episode.url, /\//)      
      shortEpisodeURL || episode.url
    end
    
    def feedFolderName
      title = @feedReader.title
      return @workDirectory if title.nil?
      
      podcastFolderName = @feedReader.title.downcase.gsub(/\s/, "")
      File.join(@workDirectory, podcastFolderName)
    end
    
    def rightMostPart(str, pattern)
      rightMostIndex = str.rindex(pattern)
      str[(rightMostIndex + 1)..-1] if !rightMostIndex.nil?
    end
  end
  
  class FileDownloader    
    def download(fileURL, fileName)
      system("wget -c \"#{fileURL}\" -O \"#{fileName}\"")
    end
  end
  
  class CommandLine

    def parse(args)
      workDirectory = consumeValueOption(args, "-workdir", "#{ENV['HOME']}/rpodder_podcasts")
      useEpisodeNames = consumeBooleanOption(args, "-use_episode_names")  
      
      action = args[0]
      podcastURL = args[1]
      
      raise if action != "fetch"
      raise if podcastURL.nil?
      
      Args.new({:action => action, :podcastURL => podcastURL, :workDirectory => workDirectory,
        :useEpisodeNames => useEpisodeNames})
    end
    
    private
    
    def consumeValueOption(args, optionName, defaultValue)      
      consumeOption(args, optionName, defaultValue) do |args, optionIndex|
        optionValue = args[optionIndex + 1]
        2.times { args.delete_at(optionIndex)}
        optionValue
      end
    end
    
    def consumeBooleanOption(args, optionName)
      consumeOption(args, optionName, false) do |args, optionIndex|
        args.delete_at(optionIndex)
        true
      end
    end
    
    def consumeOption(args, optionName, defaultValue, &block)
      optionIndex = args.index(optionName)
      optionValue = nil
      if !optionIndex.nil?
        optionValue = block.call(args, optionIndex)
      end
      optionValue.nil? ? defaultValue : optionValue 
    end
  end
  
  class Args
    attr_reader :action, :podcastURL, :workDirectory, :useEpisodeNames
    
    def initialize(opts)
      @action = opts[:action]
      @podcastURL = opts[:podcastURL]
      @workDirectory = opts[:workDirectory]
      @useEpisodeNames = opts[:useEpisodeNames]
    end
  end
end

if __FILE__ == $PROGRAM_NAME  
  commandLine = RPodder::CommandLine.new()
  args = commandLine.parse(ARGV)
  xmlFeed = RPodder::FeedFetcher.new(args.podcastURL).fetch  
  feedReader = RPodder::FeedReader.new(xmlFeed)
  downloader = RPodder::FileDownloader.new
  feedStorage = RPodder::FeedStorage.new(args.workDirectory, feedReader, downloader,
    {:useEpisodeNames => args.useEpisodeNames})

  feedStorage.storeEpisodes
end