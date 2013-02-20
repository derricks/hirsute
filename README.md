Hirsute
=======
Hirsute is a Ruby-based domain specific language for generating plausible fake data. You might need fake data for any of the following reasons:
* demoing to a potential customer and providing a realistic experience
* building a "real" database for testing (versus the often messy, inaccurate databases in dev systems)
* building a database for load testing before a launch

In Hirsute, you define a template for what an object might look like, and then generate however many copies you need. Then you can work with those collections as needed. There is a full manual, but here is a quick example to give the flavor. Say you're building a system where you have a bunch of users, and you want to build in a "friend" concept that allows each user to have 10 friends. You want to generate a random sample of data, but you think most users will only have 2-4 friends.

The relevant Hirsute script might look like this:

<code><pre>
    # define a user template that has an id that is an incrementing counter starting at 1 and an email address that we're defining as testuser1@gmail.com,testuser2@yahoo.com,testuser3@aol.com, and so forth

    storage :mysql

    a('user') {
        has :id => counter,
            :email => combination(
                      "testuser",counter,"@",one_of(['gmail','aol','yahoo']),".com")
        is_stored_in "users"
    }

    #make 1000 users
    users = user * 1000

    # define a friendship object that maps two users together. Just define the user ids as literals so they can be defined but can be filled in later
    a('friendship') {
        has :user1 => 1, 
            :user2 => 1
        is_stored_in "friendship"
    }
    friendships = collection_of friendship

    # for each user, pick an appropriate number of friends and create the friendship objects
    foreach user do |cur_user|
      # figure out a number of friends this user might have. Pass in a histogram to steer the probability the way we want
      # the first argument is the options to draw from, the second argument (optional) is a histogram representing distribution of probabilities
      num_friends = pick_from([0,1,2,3,4,5,6,7,8,9,10],
                               [0.02,0.1,0.3,0.3,0.2,0.01,0.01,0.01,0.01,0.02,0.01]
                              )

      # since this in Ruby, you can just write in it as needed
      (0...num_friends).each do |idx|
         # grab a random user that isn't this one
         friend = any(user) {|friend| friend.id != cur_user.id}

         new_friendship = friendship.make # because there's only one collection holding these, it's added automatically
         new_friendship.user1 = friend.id
         new_friendship.user2 = cur_user.id
      end
    end

    # and now write them all out to files
    finish users
    finish friendships
</pre></code>

This will create files that have data such as this:
<code><pre>
    INSERT INTO users ('email','id') VALUES ('testuser1@yahoo.com',1);
    INSERT INTO users ('email','id') VALUES ('testuser2@yahoo.com',2);
    INSERT INTO users ('email','id') VALUES ('testuser3@aol.com',3);
    INSERT INTO users ('email','id') VALUES ('testuser4@yahoo.com',4);
    INSERT INTO users ('email','id') VALUES ('testuser5@yahoo.com',5);
</pre></code>

and 

<code><pre>
    INSERT INTO friendship ('user1','user2') VALUES (624,1);
    INSERT INTO friendship ('user1','user2') VALUES (808,1);
    INSERT INTO friendship ('user1','user2') VALUES (81,1);
    INSERT INTO friendship ('user1','user2') VALUES (15,2);
</pre></code>

To run this script, cd to the hirsute directory and run
<code><pre>
  ruby lib/hirsute.rb samples/readme.hrs
</pre></code>

Roadmap
-------
Hirsute is still early in development, but my goal is to continue adding output formats (currently only mysql and csv are supported) and generators as well as continuing to allow for more declarative syntax that would make the data generation more flexible, terse, and intuitive.

I also don't think it will yet meet one of my needs, which is to generate the data for a multimillion-user system. So far, it does everything in memory, which will obviously cause problems for large data sets.

Why Hirsute?
------------
The name was a joke with a friend. When I wanted something like this, I asked him, since he's up on many open-source projects. He said he didn't know of something like this, so I replied, "No, no. You're supposed to say 'Look at Hirsute' or something like that."