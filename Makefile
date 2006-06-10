#!/usr/bin/make -f

ifneq (,)
This makefile requires GNU Make.
endif

DESTDIR		=
prefix		= /usr
exec_prefix	= $(prefix)
man_prefix	= $(prefix)/share

PACKAGE		= wwwflypaper
INSTALL		= /usr/bin/install
INSTALL_BIN	= $(INSTALL) -m 755
INSTALL_SUID    = $(INSTALL) -m 4755
INSTALL_DATA	= $(INSTALL) -m 644

INSTALL_OBJS_BIN   = $(PACKAGE)
INSTALL_OBJS_MAN1  = *.1 *.1x
INSTALL_OBJS_SHARE =

MAKEFILE	= Makefile
MANDIR1		= $(DESTDIR)$(man_prefix)/man/man1
MANDIR5		= $(DESTDIR)$(man_prefix)/man/man5
MANDIR8		= $(DESTDIR)$(man_prefix)/man/man8
BINDIR		= $(DESTDIR)$(exec_prefix)/bin
SBINDIR		= $(DESTDIR)$(exec_prefix)/sbin
ETCDIR		= $(DESTDIR)$/etc/$(PACKAGE)
SHAREDIR	= $(DESTDIR)$(prefix)/share/$(PACKAGE)
LIBDIR		= $(DESTDIR)$(prefix)/lib/$(PACKAGE)

DEBUG		= -g
CC		= gcc
GCCFLAGS	= -Wall
CFLAGS		= $(GCCFLAGS) $(DEBUG) -O2
OBJS		= $(PACKAGE).c

.PHONY: clean distclean install install-man install-bin

all:
	@echo Nothing to compile. See "make help"

all-compile: $(PACKAGE)

$(PACKAGE): $(OBJS)
	$(CC) -o $@ $<

# Rule: help - Print list of all make targets
help:
	@egrep -ie '# +Rule:' $(MAKEFILE) \
	    | sed -e 's/.*Rule://' | sort;


# Rule: clean - Remove temporary files
clean:
	-rm -f *[#~] *.\#* *.o *.exe core *.stackdump

distclean: clean

install-etc:
	$(INSTALL_BIN) -d $(ETCDIR)
	$(INSTALL_BIN)	  $(INSTALL_OBJS_ETC) $(ETCDIR)

# Rule: install-bin - Install to BINDIR
install-bin:
	$(INSTALL_BIN) -d $(BINDIR)
	$(INSTALL_BIN) -s $(INSTALL_OBJS_BIN) $(BINDIR)

# Rule: install-bin - Install to MANDIR1
install-man:
	$(INSTALL_BIN) -d $(MANDIR1)
	$(INSTALL_DATA) $(INSTALL_OBJS_MAN1) $(MANDIR1)

# Rule: install - Run all install targets
install: $(PACKAGE) install-bin install-man

# End of file
