all: parse

deploy: parse
	rm -rf /home/www/hanamizuki/*
	cp -r deploy/* /home/www/hanamizuki
	cp -r icon/* /home/www/hanamizuki

parse:
	./hanamizuki.rb -o output
	cd output; for i in *.html; do \
	   iconv -f utf-8 -t sjis -o ../deploy/$${i} $${i}; done

test:
	./test.rb | iconv -f utf-8 -t sjis -o ${HOME}/html/pre/index.html

clean:
	rm output/*.html
	rm deploy/*.html
