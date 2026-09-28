DOCUMENTS ?= main.pdf

.PHONY : all clean cleanall

all : $(DOCUMENTS)

%.pdf : %.tex
	latexmk -use-make $<

clean :
	latexmk -c
	rmdir build/

cleanall : clean
	rm -f $(DOCUMENTS)

install: $(DOCUMENTS)
	install -Dt ${out} $^
