#!/usr/bin/env ruby

require "fileutils"
require "date"

GPL2_HEADER = "# This file is a part of Redmin Agile (redmine_agile) plugin,
# Agile board plugin for redmine
#
# Copyright (C) 2011-#{Date.today.year} RedmineUP
# http://www.redmineup.com/
#
# redmine_agile is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_agile is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_agile.  If not, see <http://www.gnu.org/licenses/>.

"
def bitnami_version(text)
  text.force_encoding('utf-8') if text.respond_to?(:force_encoding)
  # remove light tags
  text = text.gsub(/(\s*(#|<!\-\-)\s*<LIGHT>\s.*?<\/LIGHT>[ ]*(\-\->)?)|(#\s<LIGHT\s?\/>(.*?)\n{1})/m, "")
  reg_light_block = /((#|<!--)\s(<BITNAMI\/>|<BITNAMI>|<BITNAMI\s\/>)\s#?.*?((<\/BITNAMI>)[ ]*(-->)?))/m
  reg_pro_block = /\s*(#|<!--)[ ]*<PRO>.*?<\/PRO>[ ]*(-->)*/m
  without_pro = text.gsub(reg_pro_block, "")
  light_text2 = /((#\s+)|(<BITNAMI\/>)}|(<BITNAMI>)|(<!\-\-)|(\-\->)|(<\/BITNAMI>))/m
  without_pro.gsub!(reg_light_block){|pas| pas.gsub(light_text2, "")}
  #remove one line BITNAMI tag
  without_pro.gsub(/(#\s<BITNAMI\s?\/>\s?)/, "")
end

def pro_version(text)
  text.force_encoding('utf-8') if text.respond_to?(:force_encoding)
  text = text.gsub(/(\s*(#|<!\-\-)\s*<BITNAMI>\s.*?<\/BITNAMI>[ ]*(\-\->)?)|(#\s<BITNAMI\s?\/>(.*?)\n{1})/m, "")
  text.gsub(/(\s*(#|<!\-\-)[ ]*<[\/]?PRO>[^\n\r]*(\-\->)*)|(\s*(#|<!\-\-)\s*<LIGHT>\s.*?<\/LIGHT>[ ]*(\-\->)?)|(#\s<LIGHT\s?\/>(.*?)\n{1})/m, "")
end

def light_version(text)
  text.force_encoding('utf-8') if text.respond_to?(:force_encoding)
  text = text.gsub(/(\s*(#|<!\-\-)\s*<BITNAMI>\s.*?<\/BITNAMI>[ ]*(\-\->)?)|(#\s<BITNAMI\s?\/>(.*?)\n{1})/m, "")
  reg_light_block = /((#|<!--)\s(<LIGHT\/>|<LIGHT>|<LIGHT\s\/>)\s#?.*?((<\/LIGHT>)[ ]*(-->)?))/m
  reg_pro_block = /\s*(#|<!--)[ ]*<PRO>.*?<\/PRO>[ ]*(-->)*/m
  without_pro = text.gsub(reg_pro_block, "")
  light_text2 = /((#\s+)|(<LIGHT\/>)}|(<LIGHT>)|(<!\-\-)|(\-\->)|(<\/LIGHT>))/m
  without_pro.gsub!(reg_light_block){|pas| pas.gsub(light_text2, "")}
  #remove one line LIGHT tag
  without_pro.gsub(/(#\s<LIGHT\s?\/>\s?)/, "")
end

def add_gpl2_license_header(files)
  files.each do |file_name|
    next if file_name.match("version.rb")
    file_content = File.read(file_name)
    file_content = GPL2_HEADER + file_content
    file_content = "# encoding: utf-8\n#\n" + file_content if file_name.match(/.*_(test|helper)\.rb/)
    File.open(file_name, "w") {|file| file.puts file_content}
  end
end

plugin_dir = File.expand_path('../', File.dirname(__FILE__))

Dir["#{plugin_dir}/**/*.rb",
    "#{plugin_dir}/**/*.erb",
    "#{plugin_dir}/**/*.api.rsb",
    "#{plugin_dir}/Gemfile"].each do |file_name|
  next if file_name.match("version.rb")
  text = File.read(file_name)

  if ARGV && ARGV[0] == 'light'
    patched_file = light_version(text)
  elsif  ARGV && ARGV[0] == 'bitnami'
    patched_file = bitnami_version(text)
  else
    patched_file = pro_version(text)
  end

  File.open(file_name, "w") {|file| file.puts patched_file}
end

add_gpl2_license_header(Dir["#{plugin_dir}/**/*.rb"])

if ARGV && (ARGV[0] == 'light' || ARGV[0] == 'bitnami')
    FileUtils.rm_r Dir["#{plugin_dir}/**/agile_queries*",
                       "#{plugin_dir}/**/agile_version*",
                       "#{plugin_dir}/**/redmine_agile_context_menu.js",
                       "#{plugin_dir}/app/**/*color*",
                       "#{plugin_dir}/lib/**/*color*",
                       "#{plugin_dir}/test/**/*color*",
                       "#{plugin_dir}/**/issue_priority_patch.rb",
                       "#{plugin_dir}/**/issue_query_patch.rb",
                       "#{plugin_dir}/**/tracker_patch.rb",
                       "#{plugin_dir}/**/*context_menu*",
                       "#{plugin_dir}/**/utils/header_tree.rb",
                       "#{plugin_dir}/**/charts/*cumulative_flow*",
                       "#{plugin_dir}/**/charts/*burnup*",
                       "#{plugin_dir}/**/charts/*lead_time*",
                       "#{plugin_dir}/**/charts/*velocity*",
                       "#{plugin_dir}/lib/**/hooks/helper_issues_hook*",
                       "#{plugin_dir}/assets/javascripts/visibility*",
                       "#{plugin_dir}/assets/javascripts/dragscrollable*"],
                     :force => true
    if ARGV[0] == 'light'
      FileUtils.rm_r Dir["#{plugin_dir}/app/views/bitnami/",
        "#{plugin_dir}/assets/images/pro_version_agile.png"],
        :force => true
    end
else
    FileUtils.rm_r Dir["#{plugin_dir}/app/views/agile_boards/_upgrade_to_pro.html.erb",
      "#{plugin_dir}/app/views/bitnami/"],
    :force => true
end

FileUtils.rm_r Dir["#{plugin_dir}/bitbucket-pipelines.yml"], :force => true
