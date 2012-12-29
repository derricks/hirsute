Hirsute: The Manual
===================

Hirsute is a Ruby DSL for defining rules that yield fake data sets. You can use these fake data sets for examples in an application, testing code against a "normal" (versus dev) database, or for generating data sets that can be used for load testing an application.

Usage
-----
ruby lib/hirsute.rb filename

By convention, hirsute files end in .hrs, but you can pass any file you'd like to it.

Commands are interpreted in a top-down fashion, which means you must define an object type before you use it.

Templates
------------
* a/an('_type_') - defines a template for a type of object in the system. You can pass a block of Ruby code which will get executed. Usually this will include _has_ and _is\_stored\_in_. Once you define a template, you can use _type_ as a regular name (e.g., once you've called _a('user')_, you can use _user_ as a language element). 

<code><pre>
    a('user')
    an('elephant') {
        puts "Made an elephant"
    }
</pre></code>
    
* has _fields_ - within a template definition, defines the set of fields for that template and the generators that will create the data in a specific instance. See below for a list of generators. Note: The first field => generator pair must be on the same line as _has_

<code><pre>
    a('user') {
        has :user_id => 1,
            :is\_online => false
    }
</pre></code>

* transients - within a template definition, defines elements that can be generated per object but won't be stored

* is\_stored\_in _name_ - within a template definition, determines the storage destination (e.g., a database table)

<code><pre>
    a('user') {
        is\_stored\_in 'app\_users'
    }
</pre></code>

Generators
----------
These are the different data generators you can attach to any given field. Note that you can always specify a literal value as well that will always get used as the value for that field. Any time you use a generator, you can also pass it a block of code that will be called with the generated value. For instance, if you want to truncate a string that could be larger than the field it's going into, or add a separator between generated results.

* one_of (options,histogram) - choose a random item from a list of options. If a histogram is passed in, that is used to determine the probability of picking one option over another. If a histogram is not passed in, all options will be picked with equal probability. Note: Histogram must be the same length as options, and all the values must add up to 1.0

* counter (startingValue) - keep an incrementing counter so that each new object created from the template gets the next value. Useful for ids and for making unique emails or screen names

* combination (generators... ) - combines a variable amount of generators into one field. Results are concatenated together as strings

* subset (generators... ) - combines some subset (determined randomly) of the first items in the list

* read\_from\_file (filename,algorithm) - reads from a file to produce a value, wrapping around as needed. The default algorithm, :markov, skips ahead a random number of lines each time. :linear, the other supported algorithm, will read from the file in sequence. Note: the filename will be relative to the location of the .hrs file


Collections
-----------
Collections can only hold one type of object, but multiple collections can hold the same type of object. A collection supports certain Array methods, such as choice, length, and <<, and also mixes in Enumerable

* collection_of *objectType* - create an empty collection of the given object type. You might need to do this when creating mappings to other objects.

<code><pre>
    users = collection_of user
    users << user1
</pre></code>

* _template_ * _n_ - create a collection of n objects generated from the template definition.

<code><pre>
    a('user')     
    users = user * 5 # generates 5 users
</pre></code>

* _collection_ << _template_ - create a new object from the template recipe and append it to the collection.

<code><pre>
   a('user')
   users = user * 6
   users << user  
 </pre></code>
 
* _collection_ << _object_ - appends the given object to the given collection. Note: collections can only contain one type of object 
* foreach _objectType_ - find every collection containing that type of object, and iterate through each one in turn. Takes a block that gets each item in turn

<code><pre>
    a('user') {
        has :id => counter(1)
    }
    users1 = user * 2
    users2 = user * 1
    foreach user do |item|
       # called a total of 3 times, because all collections with users are included
    end
</pre></code>

* finish(_collection_,_storage_) - output the specified collection based on the given storage type. If no storage type is given, it will use whatever was defined by the storage command

* any _type_ - return a single random object of the given type (from any collection that contains that object type). Passing a block that returns a boolean will draw the random object only from ones that meet that criteria

<code><pre>
    a('user') {
        has :id => counter(1)
    }
    user_set_1 = user * 20
    user_set_2 = user * 30
    sample_user_1 = any user # user could be from either collection
    sample_user_2 = any user {|cur_user| cur_user.id < 20} # will only pick a random user from the first collection
</pre></code>

* every _type_ - return a collection of every element of that type (from any collection that contains objects of that type). Passing a block will result in a collection that only contains items where the block returns true

<code><pre>
    a('user') {
        has :id => counter(1)
    }
    users_1 = user * 3
    users_2 = user * 7
    every(user) {|cur_user| cur_user.id > 2 && cur_user.id < 5} # returns a subset of users that span the two collections
</pre></code>

<code><pre>
    a('user') {
        has :id => counter(1),
            :email => combination("apptest",counter(1),"@",one_of(['gmail','yahoo','mac','hotmail','aol']),".com")
    }
    find user {
        email.end\_with? 'gmail.com'
    } # returns a random user with a gmail.com address
</pre></code>

Miscellaneous
-------------
* storage _type_ - the default storage system to output to. Currently, only :mysql is supported



  