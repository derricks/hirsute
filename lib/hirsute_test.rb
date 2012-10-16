## some simple exercises of the hirsute system

storage :mysql

a('user') {
  has  :user_id => counter(12),
       :comment => "some random text",
       :email   => combination("hirsute",counter(100),"@test.com");
  is_stored_in "simcity_user";
}

users = user * 5

puts users.inspect

finish users

# pseudo-code
# users.each do |user|
#   num_regions = random_number_from_histogram([.1,.2,.5,.1,.1]) # probably the middle one
#   regions.filter 10 {|region| region.creator_id.is_nil>}
#   regions.each {|region| region.creator_id = user.user_id}
# end