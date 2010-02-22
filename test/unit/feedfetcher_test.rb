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
require 'flexmock/test_unit'

class FeedFetcherTest < Test::Unit::TestCase
  
  def test_when_full_URL_is_provided_then_it_is_used_to_fetch_contents    
    @fetcher = RPodder::FeedFetcher.new("http://example.com:8080/examplepodcast.rss")

    assert_get_request_is_made_with("example.com", 8080, "/examplepodcast.rss")
  end

  def test_when_invalid_URL_is_provided_then_exception_is_raised
    assert_raise(RuntimeError) do 
      @fetcher = RPodder::FeedFetcher.new("abcd")
      @fetcher.fetch
    end
  end

  def test_when_one_query_parameter_is_provided_with_URL_then_this_parameter_is_used
    @fetcher = RPodder::FeedFetcher.new("http://example.com:8080/examplepodcast.rss?index=1")

    assert_get_request_is_made_with("example.com", 8080, "/examplepodcast.rss?index=1")
  end
  
  def test_when_several_query_parameters_are_provided_with_URL_then_these_parameter_are_used
    @fetcher = RPodder::FeedFetcher.new("http://example.com:8080/examplepodcast.rss?index=1&format=ogg")

    assert_get_request_is_made_with("example.com", 8080, "/examplepodcast.rss?index=1&format=ogg")
  end
  
  def test_when_protocol_other_than_http_is_used_then_exception_is_raised
    assert_raise(RuntimeError) do 
      @fetcher = RPodder::FeedFetcher.new("ftp://example.com:8080/examplepodcast.rss")
      @fetcher.fetch
    end
  end
  
  def assert_get_request_is_made_with(url, port, path)
    @fetcher = flexmock(@fetcher)
    @fetcher.should_receive(:getBody).with(url, port, path).and_return("content")
    assert_equal("content", @fetcher.fetch)
  end
end