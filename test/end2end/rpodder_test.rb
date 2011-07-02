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

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../lib'

require 'rpodder/rpodder'
require 'test/unit'
require 'fileutils'
require 'pathname'

class RPodderTest < Test::Unit::TestCase

  #TODO: Think about using directory names in a more conventional and portable manner
  def setup
    @rpodder = File.expand_path(File.dirname(__FILE__) + '/../../lib/rpodder/rpodder.rb')
    @workDir = File.expand_path(File.dirname(__FILE__) + '/work')
    Dir.mkdir(@workDir) if !File.exists?(@workDir)
    @podcastTitle = "testpodcast"
    @episodesNumber = 5
    @episode1Path = "#{@workDir}/#{@podcastTitle}/1.mp3"
  end

  def teardown
    FileUtils.rm_rf(@workDir)
  end

  def test_when_feed_and_storage_folder_are_given_to_rpodder_then_all_episodes_are_downloaded    
    feed({:title => @podcastTitle, :episodesNumber => @episodesNumber})
    
    download_feed

    (1..@episodesNumber).each do |i|
      assert_file_contents("#{@workDir}/#{@podcastTitle}/#{i}.mp3", "Contents of episode with id #{i}.mp3")
    end
  end
  
  def test_when_use_episode_name_option_is_given_then_all_episodes_are_downloaded_to_files_named_accordingly
    feed({:title => @podcastTitle, :episodesNumber => @episodesNumber})
    
    download_feed("-use_episode_names")

    (1..@episodesNumber).each do |i|
      assert_file_contents("#{@workDir}/testpodcast/Episode #{i}.mp3", "Contents of episode with id #{i}.mp3")
    end
  end

  def test_when_episode_was_already_downloaded_then_it_is_not_overwritten
    feed({:title => @podcastTitle, :episodesNumber => 1})
 
    download_feed
        
    assert_file_contents(@episode1Path, "Contents of episode with id 1.mp3")
    firstDownloadModificationTime = File.mtime(@episode1Path)

    sleep 1

    download_feed

    assert_file_contents(@episode1Path, "Contents of episode with id 1.mp3")
    secondDownloadModificationTime = File.mtime(@episode1Path)

    assert_equal(firstDownloadModificationTime.to_i, secondDownloadModificationTime.to_i)
  end

  def test_when_episode_was_downloaded_only_partially_then_it_is_overwritten
    feed({:title => @podcastTitle, :episodesNumber => 1})
    
    write_to_file(@episode1Path, "Contents")
    assert_file_contents(@episode1Path, "Contents")

    download_feed
    
    assert_file_contents(@episode1Path, "Contents of episode with id 1.mp3")
  end
  
  def test_when_several_podcasts_are_downloaded_then_their_episodes_are_stored
    episodesNumber = 5
    podcastTitles = ["podcasttitle1", "podcasttitle2", "podcasttitle3"]    
    
    podcastTitles.each do |podcastTitle|
      feed({:title => podcastTitle, :episodesNumber => episodesNumber})
      download_feed
    end

    podcastTitles.each do |podcastTitle|
      (1..episodesNumber).each do |i|
        assert_file_contents("#{@workDir}/#{podcastTitle}/#{i}.mp3", "Contents of episode with id #{i}.mp3")
      end
    end    
  end
    
  #TODO: Make the working directory parameter optional?
  
  private

  def download_feed(options = "")
    system("ruby #{@rpodder} fetch \"#{@feedURL}\" \"#{@workDir}\" #{options}")
  end

  def feed(opts)
    title = opts[:title]
    episodesNumber = opts[:episodesNumber]
    @feedURL = "http://localhost:4567/rss-feed-episodes-with-title/#{title}/1/#{episodesNumber}"
  end
    
  def write_to_file(filePath, contents)
    FileUtils.mkdir_p(File.dirname(filePath))
    File.open(filePath, 'w') {|f| f.write(contents) }
  end
  
  def assert_file_contents(path, contents)
    assert(File.exists?(path))
    assert_equal(contents, File.readlines(path).join)
  end
end