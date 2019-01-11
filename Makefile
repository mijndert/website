.PHONY: clean post preview build serve push invalidate

clean:
	$(RM) -r _site/

post:
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest rake post

preview: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll s --future

build: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll b

serve: clean
	docker run -p 4000:4000 --rm --volume="$(CURDIR):/srv/jekyll" -it jekyll/jekyll:latest jekyll s

push: clean build
	aws s3 sync --delete _site/ s3://mijndertstuij.nl/ && curl -s http://www.google.com/ping?sitemap=https://mijndertstuij.nl/sitemap.xml >/dev/null

invalidate:
	aws cloudfront create-invalidation --distribution-id E2UZTDTT76WG3V --paths "/*"
