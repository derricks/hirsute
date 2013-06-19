Gem::Specification.new do |spec|
  spec.name = 'hirsute'
  spec.version = '0.1.0'
  spec.date = '2013-06-02'
  spec.summary = 'A DSL for creating fake but plausible data.'
  spec.description = <<-DESC
    Hirsute is a Ruby-based domain specific language for creating
    fake data based on a variety of techniques, including non-uniform
    probabilities to more closely emulate real-world data.
    (e.g., allow a person to have up to 100 friends in a social
    network but specify that most will have between ten and twenty.)
    DESC
  spec.authors = ["Derrick Schneider"]
  spec.email = 'derrick.schneider@gmail.com'
  spec.files = [Dir.glob('./**/*.rb'),Dir.glob('./**/*.md'),Dir.glob('./**/*.hrs'),Dir.glob('./bin/**'),Dir.glob('./tests/**'),"./MIT_LICENSE"].flatten
  spec.executables << 'hirsute'
end
  
