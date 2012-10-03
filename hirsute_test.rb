## some simple exercises of the hirsute system

a('user') {has "user_id" => counter(12),
               "comment" => "some random text";}

users = user * 5

puts users.inspect