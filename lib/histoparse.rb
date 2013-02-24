# A mini-DSL within Hirsute that can parse ASCII-art histograms for use in Hirsute
# For instance, it could translate this
# |****
# |**
# |*****
# into a histogram array of
# [0.36,0.18,8.45]
module Hirsute
  module HistoParse
    
    def parse_histogram(histogram_string)
      ParsedHistogram.new(histogram_string)
    end
    
    #encapsulates the information about a parsed histogram
    class ParsedHistogram
      attr_reader :histogram_buckets
      
      def initialize(histogram_string)
        line_regex = /(\*+)/
        
        lines = histogram_string.split "\n"
        
        # extract information
        
        # just those lines that have histogram data
        histo_lines = Array.new
        # parallel array that tracks stars per line
        stars_per_line = Array.new
        
        total_stars = 0
        
        lines.each do |line|
          next if !(line_regex =~ line)
          
          stars = line[line_regex,1]
          total_stars = total_stars + stars.length
          histo_lines << line
          stars_per_line << stars.length
        end
        
        @histogram_buckets = stars_per_line.map {|count| count.to_f / total_stars.to_f}
      end
      
    end
  end
end