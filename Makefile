all: stage

stage: parse
	mkdir -p /home/www/hanamizuki/stage
	rm -f /home/www/hanamizuki/stage/*.html
	cp -r deploy/* /home/www/hanamizuki/stage
	cp -r icon/* /home/www/hanamizuki/stage

deploy: parse
	mkdir -p /home/www/hanamizuki
	rm -f /home/www/hanamizuki/*.html
	cp -r deploy/* /home/www/hanamizuki
	cp -r icon/* /home/www/hanamizuki

parse:
	mkdir -p output
	mkdir -p deploy
	./hanamizuki.rb -o output
	cd output; for i in *.html; do \
	   iconv -f utf-8 -t sjis -o ../deploy/$${i} $${i}; done

test:
	./test.rb | iconv -f utf-8 -t sjis -o ${HOME}/html/pre/index.html

clean:
	rm output/*.html
	rm deploy/*.html
