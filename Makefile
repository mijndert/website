.PHONY: clean post preview build serve push invalidate

clean:
	$(RM) -r _site/

essay:
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest rake essay

external:
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest rake external

howto:
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest rake howto

preview: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll s --future

build: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll b

serve: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll s

