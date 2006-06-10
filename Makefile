#!/usr/bin/make -f

ifneq (,)
This makefile requires GNU Make.
endif

DESTDIR		=
prefix		= /usr
exec_prefix	= $(prefix)/local
man_prefix	= $(prefix)/local

PACKAGE		= wwwflypaper
PL		= $(PACKAGE).pl
DOCS		= doc/txt doc/html doc/man
SRCS		= bin/$(PL)
MANS		= $(SRCS:.pl=.1)
OBJS		= $(SRCS) Makefile README ChangeLog

INSTALL		= /usr/bin/install
INSTALL_BIN	= $(INSTALL) -m 755
INSTALL_SUID    = $(INSTALL) -m 4755
INSTALL_DATA	= $(INSTALL) -m 644

INSTALL_OBJS_BIN   = $(PACKAGE)
INSTALL_OBJS_MAN1  = doc/man/*.1
INSTALL_OBJS_SHARE =

# Tar exclude patterns
TAREX = \
  --exclude RCS  \
  --exclude CVS  \
  --exclude .svn \
  --exclude .bzr

MAKEFILE	= Makefile
MANDIR1		= $(DESTDIR)$(man_prefix)/man/man1
MANDIR5		= $(DESTDIR)$(man_prefix)/man/man5
MANDIR8		= $(DESTDIR)$(man_prefix)/man/man8
BINDIR		= $(DESTDIR)$(exec_prefix)/bin
SBINDIR		= $(DESTDIR)$(exec_prefix)/sbin
ETCDIR		= $(DESTDIR)$/etc/$(PACKAGE)
SHAREDIR	= $(DESTDIR)$(prefix)/share/$(PACKAGE)
LIBDIR		= $(DESTDIR)$(prefix)/lib/$(PACKAGE)
DOCDIR		= $(DESTDIR)$(prefix)/share/doc/$(PACKAGE)

DEBUG		= -g
CC		= gcc
GCCFLAGS	= -Wall
CFLAGS		= $(GCCFLAGS) $(DEBUG) -O2
OBJS		= $(PACKAGE).c

.PHONY: clean distclean install install-man install-bin

.SUFFIXES:
.SUFFIXES: .pl .1

.pl.1:
	perl $< --Help-man > doc/man/$(*F).1
	perl $< --Help-html > doc/html/$(*F).html
	perl $< --help > doc/txt/$(*F).txt
	-rm  -f *[~#] *.tmp

all:
	@echo Nothing to compile. See "make help"

# Rule: help - Print list of all make targets
help:
	@egrep -ie '# +Rule:' $(MAKEFILE) \
	    | sed -e 's/.*Rule://' | sort;

# Rule: check - Check that program does not have compilation errors
release-check:
	perl -cw $(SRCS)

doc/man/$(PACKAGE).1: $(SRCS)
	make docs

$(DOCS):
	$(INSTALL_BIN) -d $@

# Rule: docs - Generate or update documentation (force)
docs: $(DOCS) $(MANS)

# Rule: doc - Generate or update documentation (if needed)
doc: $(DOCS) doc/man/$(PACKAGE).1

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

# Rule: install-doc - Install to DOCDIR1
install-doc:
	$(INSTALL_BIN) -d $(DOCDIR)
	(cd doc && tar $(TAREX) -cf - . | (cd  $(DOCDIR) && tar -xf -))

# Rule: install - Run all install targets
install: doc install-bin install-man

# End of file
