all: parse
	cp -r deploy/* /home/www/hanamizuki

parse:
	./hanamizuki.rb -o output
	cd output; for i in *.html; do \
	   iconv -f utf-8 -t sjis -o ../deploy/$${i} $${i}; done

clean:
	rm output/*.html
	rm deploy/*.html
