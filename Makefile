.PHONY: clean post preview build serve 

clean:
	$(RM) -r _site/

post:
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest rake post

preview: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll s --future --force_polling

build: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll b

serve: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/minimal jekyll s --force_polling

