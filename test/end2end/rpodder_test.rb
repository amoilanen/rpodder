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
  end

  def teardown
    FileUtils.rm_rf(@workDir)
  end

  def test_when_feed_and_storage_folder_are_given_to_rpodder_then_all_episodes_are_downloaded
    feedURL = 'http://localhost:4567/rss-feed-episodes/1/5'
    system("ruby #{@rpodder} fetch \"#{feedURL}\" \"#{@workDir}\"")

    (1..5).each do |i|
      assert_file_exists("#{@workDir}/testpodcast/#{i}.mp3", "Contents of episode with id #{i}.mp3")
    end
  end
  
  def test_when_use_episode_name_option_is_given_then_all_episodes_are_downloaded_to_files_named_accordingly
    feedURL = 'http://localhost:4567/rss-feed-episodes/1/5'
    system("ruby #{@rpodder} fetch \"#{feedURL}\" \"#{@workDir}\" -use_episode_names")

    (1..5).each do |i|
      assert_file_exists("#{@workDir}/testpodcast/Episode #{i}.mp3", "Contents of episode with id #{i}.mp3")
    end
  end
  
  #TODO: Make the working directory parameter optional?
  
  private 
 
  def assert_file_exists(path, contents)
    assert(File.exists?(path))
    assert_equal(contents, File.readlines(path).join)
  end
end