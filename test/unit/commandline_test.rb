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

class CommandLineTest < Test::Unit::TestCase

  def test_when_fetch_action_with_feed_parameter_and_all_options_are_used_then_they_are_parsed
    parse("fetch myrssfeed -workdir myworkdir -use_episode_names")
    
    assert_pairs_equal(
      ["fetch", @args.action],
      ["myrssfeed", @args.podcastURL],
      ["myworkdir", @args.workDirectory],
      [true, @args.useEpisodeNames])
  end

  def test_when_fetch_action_with_feed_parameter_and_no_options_are_used_then_they_are_parsed_and_default_work_directory_is_used
    parse("fetch myrssfeed")
    
    assert_pairs_equal(
      ["fetch", @args.action],
      ["myrssfeed", @args.podcastURL],
      ["#{ENV['HOME']}/rpodder_podcasts", @args.workDirectory],
      [false, @args.useEpisodeNames])
  end
  
  def test_when_no_rss_feed_is_specified_then_exception_is_raised
    assert_raise(RuntimeError) do
      parse("fetch -workdir myworkdir -use_episode_names")
    end
  end
  
  def test_when_action_is_not_fetch_then_exception_is_raised
    assert_raise(RuntimeError) do
      parse("pull myrssfeed -workdir myworkdir -use_episode_names")
    end
  end
  
  private
  
  def assert_pairs_equal(*pairs)
    pairs.each do |pair|
      assert_equal(pair[0], pair[1])
    end
  end
  
  def parse(commandLine)
    @commandLine = RPodder::CommandLine.new()
    @args = @commandLine.parse(commandLine.split(/ /))
  end
end