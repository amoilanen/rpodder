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

class FeedReaderTest < Test::Unit::TestCase
  
  def test_when_title_and_episodes_are_in_feed_then_they_are_read
    feed = <<feed
    <rss xmlns:content="http://purl.org/rss/1.0/modules/content/" version="2.0">
    <channel>
      <title>Podcast Title</title>
      <item>
        <title>Episode 1</title>
        <enclosure url="http://example.com/episode1.mp3" length="unknown" type="audio/mpeg"/>
      </item>
      <item>
        <title>Episode 2</title>
        <enclosure url="http://example.com/episode2.mp3" length="unknown" type="audio/mpeg"/>
      </item>
      <item>
        <title>Episode 3</title>
        <enclosure url="http://example.com/episode3.mp3" length="unknown" type="audio/mpeg"/>
      </item>
    </channel>
    </rss>
feed

    reader = RPodder::FeedReader.new(feed)
    
    assert_equal("Podcast Title", reader.title)
    assert_equal([
      RPodder::Episode.new("http://example.com/episode1.mp3", "Episode 1"),
      RPodder::Episode.new("http://example.com/episode2.mp3", "Episode 2"), 
      RPodder::Episode.new("http://example.com/episode3.mp3", "Episode 3")], reader.episodes)
  end
  
  def test_when_no_episodes_in_feed_then_feed_is_still_read
    feed = <<feed
    <rss xmlns:content="http://purl.org/rss/1.0/modules/content/" version="2.0">
    <channel>
      <title>Podcast Title</title>
    </channel>
    </rss>
feed

    reader = RPodder::FeedReader.new(feed)
    
    assert_equal("Podcast Title", reader.title)
    assert_equal([], reader.episodes)
  end
  
  def test_when_no_title_in_feed_then_feed_is_still_read
    feed = <<feed
    <rss xmlns:content="http://purl.org/rss/1.0/modules/content/" version="2.0">
    <channel>
      <item>
        <title>Episode 1</title>
        <enclosure url="http://example.com/episode1.mp3" length="unknown" type="audio/mpeg"/>
      </item>
      <item>
        <title>Episode 2</title>
        <enclosure url="http://example.com/episode2.mp3" length="unknown" type="audio/mpeg"/>
      </item>
      <item>
        <title>Episode 3</title>
        <enclosure url="http://example.com/episode3.mp3" length="unknown" type="audio/mpeg"/>
      </item>
    </channel>
    </rss>
feed

    reader = RPodder::FeedReader.new(feed)
    
    assert_nil(reader.title)
    assert_equal([
      RPodder::Episode.new("http://example.com/episode1.mp3", "Episode 1"),
      RPodder::Episode.new("http://example.com/episode2.mp3", "Episode 2"), 
      RPodder::Episode.new("http://example.com/episode3.mp3", "Episode 3")], reader.episodes)
  end
  
  def test_when_feed_is_malformed_then_exception_is_raised
    assert_raise(REXML::ParseException) do
      reader = RPodder::FeedReader.new("<")
    end
  end
end