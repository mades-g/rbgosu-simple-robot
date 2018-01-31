Robot Game
=============

Reuse WINDOW: since it can only be one instance of Window

# Dependencies for both C++ and Ruby
sudo apt-get install build-essential libsdl2-dev libsdl2-ttf-dev libpango1.0-dev \
                     libgl1-mesa-dev libopenal-dev libsndfile-dev libmpg123-dev \
                     libgmp-dev

# To install Ruby itself - if you are using rvm or rbenv, please skip this step
sudo apt-get install ruby-dev

# If you are using a Ruby version manager (i.e. rvm or rbenv)
gem install gosu
# If you are using system Ruby, you will need "sudo" to install Ruby libraries (gems)
sudo gem install gosu

To run this project go to (cd) bin then > ruby rbgame

# TODO:
 - Move robot on command

# DOC >C
http://www.rubydoc.info/github/gosu/gosu/Gosu