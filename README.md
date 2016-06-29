# Jif

## What is Jif?
**Jif** is a tool that allows you to search for animated gifs right from your terminal window. I created this because I was tired of leaving my terminal window in order to find gifs. Instead of opening a browser (or some other app) to search for gifs, I can just type in a quick command to **Jif** to get the gif I'm looking for. Since creating this tool, I've seen a 1000% increase in my productivity!

## Installation
**Jif** has two major dependencies (outside of ruby and ruby-gems).

1) You'll need to install imgcat...
```
brew tap eddieantonio/eddieantonio
brew install imgcat
```
2) you will need a version of iTerm2 with animated gif support. That means a version >= 2.9.20150512, but I would recommend that you just go ahead and install the [current beta release](https://www.iterm2.com/version3.html
) of iTerm2 3.0.

After you're sure you have both of those things... just clone, build, and install **Jif**!

```
git clone https://github.com/lonnieking/jif.git
cd jif
rake build jif
rake install jif
```

## Usage
To use jif, just open up iTerm2 and issue one of the following commands...

### Random gif
Retrieves a gif at random from giphy.

**Warning!** There is no guarantee that the result will be SFW!

```
jif random
```

### Gif Search
Retrieves the first gif in giphy search results for a given query.

```
jif search QUERY TERMS
```

![jif search](http://i.giphy.com/3oEjI7IQFEU43Zpu3C.gif)

You can also use multiple search terms to get something more specific.

![jif multiple term search](https://i.giphy.com/3oEjHB6bNAsM63XAk0.gif)

### More coming soon...
