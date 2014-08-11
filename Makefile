all:
	./hanamizuki.rb -o output
	cd output; for i in *.html; do \
	   iconv -f utf-8 -t sjis -o ../deploy/$${i} $${i}; done

deploy: all
	cp -r deploy/* /home/www/hanamizuki

clean:
	rm tmp_output.html
	rm output.html
