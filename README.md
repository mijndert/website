This is the Git repository for the website that runs on http://mijndertstuij.nl.

Use the Makefile to build, serve, and push the website. Or run a Docker container manually:

Build:

```docker run -p 4000:4000 --rm --volume="$PWD:/srv/jekyll" -it jekyll/jekyll:latest jekyll b```

Server:

```docker run -p 4000:4000 --rm --volume="$PWD:/srv/jekyll" -it jekyll/jekyll:latest jekyll s```

