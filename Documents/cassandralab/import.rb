require 'fastercsv'
require 'cql'

movie, year, title, rating, genres, actors = Array.new
description = Array.new
genres_and_ratings = Array.new

client = Cql::Client.connect(hosts: ['54.185.30.189'])
client.use('group2')

client.execute("CREATE TABLE movie_desc (title varchar PRIMARY KEY, description varchar);")
client.execute("CREATE TABLE popularity (fake_field int, filmed_in int, name varchar, PRIMARY KEY (fake_field, filmed_in, name));")
client.execute("CREATE TABLE ratings (genre varchar, rating float, title varchar, PRIMARY KEY (genre, rating, title));")
client.execute("CREATE TABLE actors (name varchar PRIMARY KEY, filmed_in int);")


File.open("/home/qui/Documents/cassandralab/movies_dump2.tsv") do |f|
    f.each_line do |tsv|
      if (tsv[0..3] == "2006" or tsv[0..3] == "2007" or tsv[0..3] == "2008" or tsv[0..3] == "2009" or tsv[0..3] == "2010")
      year, title, rating, genres, actors = tsv.force_encoding("iso-8859-1").split("\t")
      movie = tsv.force_encoding("iso-8859-1").split("\r")
      
      year = year.split("\r")
      rating = rating.split("\r")
      actors = actors.strip.split("|")
      genres = genres.strip.split("|")
      title = title.split("\r")

      #POPULATE movie_desc 

      description = "TITLE: \"%s\"; YEAR: %s; RATING : %s; GENRES: %s; ACTORS: %s" %[title, year, rating, genres.join("|"), actors.join("|")]
      
      client.execute("INSERT INTO movie_desc (title, description) VALUES ('%s', '%s')") %[title, description]

      #POPULATE actors and popularity

      countactor = Hash.new(0)

      actors.each do |i|
      countactor[i] += 1
      end
      
      countactor.each do |j, i|
      client.execute("INSERT INTO actors (name, filmed_in) VALUES ('%s', %d)") %[j, i]
      client.execute("INSERT INTO popularity (fake_field, name, filmed_in) VALUES (1, '%s', %d)") %[1, j, i] 
      end

      #POPULATE genre2rating

      genres.each do |g|
      client.execute("INSERT INTO ratings (genre, rating, title) VALUES ('%s', %.3f, '%s')") %[g, rating.map{|r| r.to_f}, title]
      end
      

      end
     
    end
end














