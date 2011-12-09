#
#   Copyright information
#
#	Copyright (C) 2005-2012 Jari Aalto
#
#   License
#
#	This program is free software; you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation; either version 2 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#	GNU General Public License for more details at
#	<http://www.gnu.org/licenses/>.

ifneq (,)
This makefile requires GNU Make.
endif

DESTDIR		=
prefix		= /usr
exec_prefix	= $(prefix)/local
man_prefix	= $(prefix)/local
cgi_prefix      = $(prefix)/lib/cgi-bin

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

INSTALL_OBJS_BIN   = bin/$(PL)
INSTALL_OBJS_MAN1  = doc/man/*.1
INSTALL_OBJS_SHARE =

# Tar exclude patterns
TAR_OPT_NO	= --exclude='.build'	 \
		  --exclude='.sinst'	 \
		  --exclude='.inst'	 \
		  --exclude='tmp'	 \
		  --exclude='*.bak'	 \
		  --exclude='*.log'	 \
		  --exclude='*[~\#]'	 \
		  --exclude='.\#*'	 \
		  --exclude='CVS'	 \
		  --exclude='RCS'	 \
		  --exclude='.svn'	 \
		  --exclude='.bzr'	 \
		  --exclude='debian'	 \
		  --exclude='*.tar*'	 \
		  --exclude='*.gz'

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
WWWCGIDIR	= $(DESTDIR)$(cgi_prefix)

DEBUG		= -g
CC		= gcc
GCCFLAGS	= -Wall
CFLAGS		= $(GCCFLAGS) $(DEBUG) -O2
OBJS		= $(PACKAGE).c


VERSION		= `date '+%Y.%m%d'`

BUILDDIR	= .build
DEBDIR		= .build/deb

PACKAGEVER	= $(PACKAGE)-$(VERSION)
RELEASEDIR	= $(BUILDDIR)/$(PACKAGEVER)
RELEASE_FILE	= $(PACKAGEVER).tar.gz
RELEASE_FILE_PATH = $(BUILDDIR)/$(RELEASE_FILE)
RELEASE_LS  	= \
  `ls -t1 $(BUILDDIR)/*tar* | sort -r | head -1`

FTP             	  = ncftpput
SOURCEFORGE_UPLOAD_HOST   = upload.sourceforge.net
SOURCEFORGE_UPLOAD_DIR	  = /incoming

SOURCEFORGE_DIR		  = /home/groups/w/ww/wwwflypaper
SOURCEFORGE_SHELL	  = shell.sourceforge.net
SOURCEFORGE_USER	  = $(USER)
SOURCEFORGE_LOGIN	  = $(SOURCEFORGE_USER)@$(SOURCEFORGE_SHELL)
SOURCEFORGE_SSH_DIR	  = $(SOURCEFORGE_LOGIN):$(SOURCEFORGE_DIR)

TAR_FILE_WORLD_LS  = `ls -t1 $(BUILDDIR)/*-*.tar.gz | sort -r | head -1`

# 1. Delete path
# 2. Convert "-" into "_"
# 3. Convert "tar" into "orig.tar"
# wwwflypaper-2006.0610.tar.gz => wwwflypaper_2006.0610.orig.tar.gz

TAR_FILE_DEB_ORIG = `ls -t1 $(BUILDDIR)/*-*.tar.gz | sort -r | head -1 | sed -e "s,.*/,, ; s,-,_, ; s,tar,orig.tar," `

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
check:
	perl -cw $(INSTALL_OBJS_BIN)

doc/man/$(PACKAGE).1: $(INSTALL_OBJS_BIN)
	make docs

$(DOCS):
	$(INSTALL_BIN) -d $@

# Rule: docs - Generate or update documentation (force)
docs: $(DOCS) $(MANS)

# Rule: doc - Generate or update documentation (if needed)
doc: $(DOCS) doc/man/$(PACKAGE).1

# Rule: release - [maintenance] Make a release
release:
	@$(INSTALL_BIN) -d $(RELEASEDIR)
	@rm -rf $(RELEASEDIR)/*
	@tar $(TAR_OPT_NO) -zcf - . | ( cd $(RELEASEDIR); tar -zxf - )
	@cd $(BUILDDIR) &&						    \
	$(TAR) $(TAR_OPT_NO) -zcf $(RELEASE_FILE) $(PACKAGEVER)
	@echo $(RELEASE_FILE_PATH)
	@tar -ztvf $(RELEASE_FILE_PATH)

# Rule: release-list - [maintenance] List content of release.
list-release:
	$(TAR) -ztvf $(TAR_FILE_WORLD_LS)

# Rule: release-deb - [maintenance] Make Debian *.deb release
release-deb:
	#  Note that target RELEASE must have been prior running RELEASE-DEB
	$(INSTALL_BIN) -d $(DEBDIR)
	rm -rf $(DEBDIR)/*
	tar -C $(DEBDIR) -zxvf $(TAR_FILE_WORLD_LS)
	cp $(TAR_FILE_WORLD_LS) $(DEBDIR)/$(TAR_FILE_DEB_ORIG)
	cp -r debian/ $(DEBDIR)/*/
	$(MAKE) -C $(DEBDIR)/*/ -f debian/debian.mk deb

# Rule: lintian - [maintenance] Check content of Debian package.
lintian:
	cd $(DEBDIR); \
	lintian $$(ls -1t | egrep '.*changes' | head -1) 2>&1 | tee pkg-lintian.log

# Rule: release-list - [maintenance] List content of Debian release.
list-deb:
	dpkg --info $(DEBDIR)/*deb
	dpkg --contents $(DEBDIR)/*deb

# Rule: sf-upload-release - [Maintenence] Sourceforge; Upload documentation
sf-upload-release:
	@echo "-- run command --"
	@echo $(FTP)			    \
		$(SOURCEFORGE_UPLOAD_HOST)  \
		$(SOURCEFORGE_UPLOAD_DIR)   \
		$(RELEASE_LS)

# Rule: clean - Remove temporary files
clean:
	-find . -type f | egrep '[#~]|DEADJOE|\.(o|exe|stackdump)|core) | \
	xargs -r rm -f

distclean: clean

install-etc:
	$(INSTALL_BIN) -d $(ETCDIR)
	$(INSTALL_BIN)	  $(INSTALL_OBJS_ETC) $(ETCDIR)

# Rule: install-bin - Install to BINDIR
install-bin:
	$(INSTALL_BIN) -d $(BINDIR)
	$(INSTALL_BIN)    $(INSTALL_OBJS_BIN) $(BINDIR)/$(PACKAGE)

# Rule: install-www - Install to WWWCGIDIR
install-www:
	$(INSTALL_BIN) -d $(WWWCGIDIR)
	$(INSTALL_BIN) $(INSTALL_OBJS_BIN) $(WWWCGIDIR)/$(PACKAGE)

# Rule: install-man - Install to MANDIR1
install-man:
	$(INSTALL_BIN) -d $(MANDIR1)
	$(INSTALL_DATA) $(INSTALL_OBJS_MAN1) $(MANDIR1)

# Rule: install-doc - Install to DOCDIR
install-doc:
	$(INSTALL_BIN) -d $(DOCDIR)
	(cd doc && tar $(TAR_OPT_NO) -cf - . | (cd  $(DOCDIR) && tar -xf -))

# Rule: install - Run all install targets
install: doc install-bin install-man

# End of file
