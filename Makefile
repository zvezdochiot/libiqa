SRCDIR=./source
SRC= \
	$(SRCDIR)/convolve.c \
	$(SRCDIR)/decimate.c \
	$(SRCDIR)/math_utils.c \
	$(SRCDIR)/mse.c \
	$(SRCDIR)/psnr.c \
	$(SRCDIR)/ssim.c \
	$(SRCDIR)/ms_ssim.c

OBJ = $(SRC:.c=.o)

PNAME=iqa
CC = gcc
ARC = ar rcs
LN = @ln -fsv
RM = @rm -fv
RMDIR = @rm -frv
PLIB = lib$(PNAME)
VERSION_MAJOR = 1
VERSION_MINOR = 1
VERSION_RELEASE = 2
INCLUDES = -I./include
PREFIX = /usr/local
INCPREFIX = $(PREFIX)/include
LIBPREFIX = $(PREFIX)/lib
DOCPREFIX = $(PREFIX)/share/doc/$(PLIB)$(VERSION_MAJOR)
INSTALL = install

OUTDIR=./build
ifeq ($(DEBUG),1)
RELDIR=debug
CFLAGS=-g -Wall
else
RELDIR=release
CFLAGS=-O2 -Wall
endif

OUT = $(OUTDIR)/$(RELDIR)/$(PLIB)

.c.o:
	$(CC) $(INCLUDES) $(CFLAGS) -c $< -o $@

$(OUT).a: $(OBJ)
	mkdir -p $(OUTDIR)/$(RELDIR)
	$(ARC) $(OUT).a $(OBJ)
	$(CC) -shared -Wl,-soname,$(PLIB).so.$(VERSION_MAJOR) -o $(OUT).so.$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_RELEASE) $(OBJ)
	mv $(OBJ) $(OUTDIR)/$(RELDIR)

clean:
	$(RMDIR) $(OUTDIR)
	cd test; $(MAKE) clean;

.PHONY : test install
test:
	cd test; $(MAKE);

install:
	$(INSTALL) -d $(LIBPREFIX)
	$(INSTALL) -m 0644 $(OUT).a $(LIBPREFIX)/$(PLIB).a
	$(INSTALL) -m 0644 $(OUT).so.$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_RELEASE) $(LIBPREFIX)/$(PLIB).so.$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_RELEASE)
	$(LN) $(PLIB).so.$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_RELEASE) $(LIBPREFIX)/$(PLIB).so.$(VERSION_MAJOR)
	$(LN) $(PLIB).so.$(VERSION_MAJOR) $(LIBPREFIX)/$(PLIB).so
	$(INSTALL) -d $(INCPREFIX)
	$(INSTALL) -m 0644 include/iqa*.h $(INCPREFIX)
	$(INSTALL) -d $(LIBPREFIX)/pkgconfig
	$(INSTALL) -m 0644 $(PNAME).pc $(LIBPREFIX)/pkgconfig
	$(INSTALL) -d $(DOCPREFIX)
	$(INSTALL) -m 0644 CHANGELOG.txt LICENSE README.txt $(DOCPREFIX)

uninstall:
	$(RM) $(LIBPREFIX)/$(PLIB).a
	$(RM) $(LIBPREFIX)/$(PLIB).so.$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_RELEASE)
	$(RM) $(LIBPREFIX)/$(PLIB).so.$(VERSION_MAJOR)
	$(RM) $(LIBPREFIX)/$(PLIB).so
	$(RM) $(LIBPREFIX)/pkgconfig/$(PNAME).pc
	$(RM) $(INCPREFIX)/$(PNAME).h
	$(RMDIR) $(DOCPREFIX)

