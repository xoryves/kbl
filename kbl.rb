#!/usr/bin/env ruby
require 'json'
require 'mustache'

FILE_JSON = ARGV[0] || 'keyboard-layout_.json'
FILE_HTML = ARGV[1] || 'kbl_.html'

file = File.read(FILE_JSON)
kbl_json = JSON.parse(file)

# https://github.com/ijprest/keyboard-layout-editor/blob/master/serial.js#L47
label_map = [
  #0  1  2  3  4  5  6  7  8  9 10 11
  [ 0, 6, 2, 8, 9,11, 3, 5, 1, 4, 7,10], # 0 = no centering
  [ 1, 7,-1,-1, 9,11, 4,-1,-1,-1,-1,10], # 1 = center x
  [ 3,-1, 5,-1, 9,11,-1,-1, 4,-1,-1,10], # 2 = center y
  [ 4,-1,-1,-1, 9,11,-1,-1,-1,-1,-1,10], # 3 = center x & y
  [ 0, 6, 2, 8,10,-1, 3, 5, 1, 4, 7,-1], # 4 = center front (default)
  [ 1, 7,-1,-1,10,-1, 4,-1,-1,-1,-1,-1], # 5 = center front & x
  [ 3,-1, 5,-1,10,-1,-1,-1, 4,-1,-1,-1], # 6 = center front & y
  [ 4,-1,-1,-1,10,-1,-1,-1,-1,-1,-1,-1]  # 7 = center front & x & y
]
label_map = [
  #tl tc tr ml mc mr bl bc br
  [:tl, :bl, :tr, :br, nil, nil, :ml, :mr, :tc, :mc, :bc, nil], # 0 = no centering
  [:tc, :bc, :br, :br, nil, nil, :mc, :br, :br, :br, :br, nil], # 1 = center x
  [:ml, :br, :mr, :br, nil, nil, :br, :br, :mc, :br, :br, nil], # 2 = center y
  [:mc, :br, :br, :br, nil, nil, :br, :br, :br, :br, :br, nil], # 3 = center x & y
  [:tl, :bl, :tr, :br, nil, :br, :ml, :mr, :tc, :mc, :bc, :br], # 4 = center front (default)
  [:tc, :bc, :br, :br, nil, :br, :mc, :br, :br, :br, :br, :br], # 5 = center front & x
  [:ml, :br, :mr, :br, nil, :br, :br, :br, :mc, :br, :br, :br], # 6 = center front & y
  [:mc, :br, :br, :br, nil, :br, :br, :br, :br, :br, :br, :br]  # 7 = center front & x & y
]

options = {
  index: 4
}
keys = []

kbl_json[1..-3].each do |row|
  row.each do |elem|
    if elem.is_a? Hash
      options[:index] = elem['a'] unless elem['a'].nil?
    else
      key = []
      values = elem.split("\n")
      values.each_with_index do |val, i|
        next if val.nil? || val.empty?
        key << {pos: label_map[options[:index]][i], val: val}
      end
      keys << key
    end
  end
end

template = File.read('kbl.mustache')
data = {keys: keys}
File.open(FILE_HTML, 'w') { |f| f.write(Mustache.render template, data) }
