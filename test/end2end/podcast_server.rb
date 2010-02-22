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

require 'rubygems'
require 'sinatra'

@@xmlHeader = <<HEADER
<rss xmlns:content="http://purl.org/rss/1.0/modules/content/" version="2.0">
<channel>
<title>Test Podcast</title>
<link>http://localhost:4567</link>
<description>Description</description>
<copyright>Copyright</copyright>
<generator>Generator</generator>
<language>en-us</language>
<image>
<url>http://localhost:4567</url>
<title>Test Podcast</title>
<link>http://localhost:4567</link>
</image>
<lastBuildDate>#{Time.now}</lastBuildDate>
HEADER

@@xmlFooter=<<FOOTER
</channel>
</rss>
FOOTER

def getRSSFeedForItems(from, to)
  result = @@xmlHeader
  (from..to).each {|id| result += getRSSFeedItemWithId(id)}
  result += @@xmlFooter
end

def getRSSFeedItemWithId(id)
  xml = <<ITEM
  <item>
  <title>Episode #{id}</title>
  <description>
  Test episode with id = #{id}
  </description>
  <pubDate>#{Time.now}</pubDate>
  <link>http://localhost:4567</link>
  <guid>
  http://localhost:4567/episodes/#{id}
  </guid>
  <enclosure url="http://localhost:4567/episodes/#{id}.mp3" length="unknown" type="audio/mpeg"/>
  </item>
ITEM
end

get '/rss-feed-episodes/:from/:to' do
   from = params[:from].to_i
   to = params[:to].to_i
   getRSSFeedForItems(from, to)
end

get '/episodes/:id' do
  "Contents of episode with id #{params[:id]}"
end