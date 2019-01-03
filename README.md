# About

This is the Git repository for the website that runs on http://mijndertstuij.nl.

Build:

Use the Makefile to build, serve, and push the website. Or run a Docker container manually:

```docker run -p 4000:4000 --rm --volume="$PWD:/srv/jekyll" -it jekyll/jekyll:latest jekyll b```

Server:

```docker run -p 4000:4000 --rm --volume="$PWD:/srv/jekyll" -it jekyll/jekyll:latest jekyll s```

# License

All code is released under the [MIT](https://opensource.org/licenses/MIT) license.
