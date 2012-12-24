Hirsute: The Manual
===================

Hirsute is a Ruby DSL for defining rules that can be used to construct fake data sets. You can use these fake data sets for examples in an application, testing code against a "normal" (versus dev) database, or for generating data sets that can be used for load testing an application.

Usage
-----
ruby lib/hirsute.rb filename

By convention, hirsute files end in .hrs, but you can pass any file you'd like to it.

The Language
------------
* storage _type_ - the storage system to output to. Currently, only :mysql is supported
* a/an('_type_') - defines a template for a type of object in the system. You can pass a block of Ruby code which will get executed

<code><pre>
    a('user')
    an('elephant') {
        puts "Made an elephant"
    }
</pre></code>
    
* has _fields_ - within a template definition, defines the set of fields for that template and the generators that specify them. See below for a list of generators. Note: The first field => generator pair must be on the same line as has

<code><pre>
    a('user') {
        has :user_id => 1,
            :is_online => false
    }
</pre></code>

* transients - within a template definition, defines elements that can be generated per object but won't be stored

* is\_stored\_in _name_ - within a template definition, determines the storage destination (e.g., a database table)
* _template_ * _n_ - create a collection of n objects generated from the template definition.
* _collection_ << _template_ - create a new object from the template recipe and append it to the collection. Note: collections can only contain one type of object
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

* collection_of *objectType* - create an empty collection of the given object type

<code><pre>
    users = collection_of user
    users << user1
</pre></code>

Generators
----------
These are the different data generators you can attach to any given field. Note that you can always specify a literal value as well that will get used as the value for that field. Any time you define a generator, you can also pass it a block of code that will be called with the generated value. For instance, if you want to truncate a string that could be larger than the field it's going into, or add a separator between generated results.

* one_of (options,histogram) - choose a random item from a list of options. If a histogram is passed in, that is used to determine the probability of picking one option over another. Note: Histogram must be the same length as options, and all the values must add up to 1.0

* counter (startingValue) - keep an incrementing counter so that each new object created from the template gets the next value. Useful for ids and for making unique emails or screen names

* combination (generators... ) - combines a variable amount of generators into one field. Results are concatenated together as strings

* subset (generators... ) - combines some subset (determined randomly) of the first items in the list

* read\_from\_file (filename,algorithm) - reads from a file to produce a value, wrapping around as needed. The default algorithm, :markov, skips ahead a random number of lines each time. :linear, the other supported algorithm, will read from the file in sequence. Note: the filename will be relative to the location of the .hrs file




  