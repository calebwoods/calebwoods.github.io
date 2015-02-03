---
layout: post
title: "Batch Resizing Images with Ruby"
date: "2015-02-01"
---

Working with image files is a common task in web development, and many great tools exist for advanced image manipulation.  However, often all I need to do with a set of images is resize them to be more web friendly.

### TL;DR

Here is the full [gist](https://gist.github.com/calebwoods/714731713935bd2b3625).

### Resizing in Ruby

I starting looking at how I could build a generalized script to handle batch resizing in Ruby, being my preferred language for scripting.

To handle the image manipulation I'll make use of the [RMagick](https://github.com/rmagick/rmagick) gem which wraps the [ImageMagick](http://www.imagemagick.org/) command line tool.

To install RMagick and ImageMagick via Homebrew and Rubygems use the following commands:

```bash
$ brew update && brew doctor
$ brew install imagemagick
$ gem install rmagick
```

### Ruby Executable

To make the script runnable without using the `ruby` command we'll create a file with a ruby [shebang](http://en.wikipedia.org/wiki/Shebang_%28Unix%29).

I've created mine in `~/.bin` which is added to my `$PATH` so the script can be executed from anywhere.  The file also needs to be executable using [chmod](http://ss64.com/bash/chmod.html).

```bash
$ echo "#!/usr/bin/ruby" > ~/.bin/resize.rb
$ chmod +x ~/.bin/resize.rb
$ echo 'export PATH="~/.bin:$PATH"' >> ~/.bash_profile
```

**Note**: If you use Rbenv to manage your ruby versions you'll need to update your script to use `#!/usr/bin/env ruby` for your shebang.  See the [Rbenv wiki](https://github.com/sstephenson/rbenv/wiki/ruby-local-exec#why-is-it-deprecated) for more info.

### Resizing

The logic for resizing an image is pretty straight forward.  We just need to open the image using RMagick and call the `resize_to_fit` command, which will scale the image to fit the width in pixels while maintaining current aspect ratio.

Because this is a dynamic script we will get the values for directory and width using [ARGV](http://blog.flatironschool.com/post/64043716616/a-short-explanation-of-argv).

```ruby
require 'RMagick'
require 'pathname'

@directory = Pathname(File.expand_path(ARGV[0]))
@size      = ARGV.fetch(1) { 1025 }

def resize_image(file)
  img = Magick::Image.read(file).first

  resized = img.resize_to_fit(@size)

  path = @directory.join('resized', File.basename(file))
  resized.write(path) do
    self.quality = 100
  end

  # free up RAM
  img.destroy!
  resized.destroy!
end
```

### Processing a Batch

Now that we have a method for resizing images we need a way to collect images for resizing and iterate over them.  We can use the [Dir.glob](http://www.ruby-doc.org/core-2.2.0/Dir.html#method-c-glob) method to get an Array of all the jpg, png, and gif images in the specified directory and then call `resize_image` for each.

```ruby
resize_dir = "#{@directory}/resized"
unless File.directory? resize_dir
  puts "Creating #{dir}/"
  Dir.mkdir resize_dir
end

files = Dir.glob "#{@directory}/*.{jpg,png,gif}"

puts "Resizing #{files.size} images..."

files.each do |file|
  puts "Resizing #{file}"
  resize_image(file)
end

puts "Finished resizing #{files.size} images"
```

### Using the Script

To use our new script we call it and pass a directory and image width.  Here we will create a batch of 150px thumbnails from the current directory.

```bash
$ cd ~/Desktop
$ resize.rb . 150
Resizing 2 images...
Resizing /Users/caleb/Desktop/avatar.jpg
Resizing /Users/caleb/Desktop/header.png
Finished resizing 2 images
```

### Customizing

Obviously this type of script could be used to do more than just resize images.  Just take a look at the [RMagick docs](http://www.imagemagick.org/RMagick/doc/) for ideas.
