
PROJECT = nario

SRCS = $(wildcard *.hs) $(wildcard Actor/*.hs)
OBJDIR = obj

all:	$(PROJECT).exe

run:
	$(PROJECT).exe

$(PROJECT).exe:	$(OBJDIR) $(SRCS)
	ghc -o $(PROJECT) --make -O -odir $(OBJDIR) -hidir $(OBJDIR) $(SRCS)

clean:
	rm -rf $(OBJDIR)
	rm -f *.manifest
	rm -f *.exe
	rm -f *.hi-boot *.o-boot

doc:
	haddock -h -o man -l C:\\ghc\\haddock-2.0.0.0 -B c:\\ghc\\ghc-6.8.2 *.hs

$(OBJDIR):
	mkdir $(OBJDIR)

imgs:
	runghc -itool tool/listup-imgs.hs data/img > Images.hs

count:
	@echo $(SRCS) | xargs -n1 echo | wc | gawk '{print $$1 " files";}'
	@cat $(SRCS) | wc | gawk '{print $$1 " lines";}'
