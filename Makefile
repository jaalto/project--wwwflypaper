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

INSTALL_OBJS_BIN   = $(PL)
INSTALL_OBJS_TOBIN = $(PACKAGE)
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
WWWCGIDIR	= $(DESTDIR)/usr/lib/cgi-bin

DEBUG		= -g
CC		= gcc
GCCFLAGS	= -Wall
CFLAGS		= $(GCCFLAGS) $(DEBUG) -O2
OBJS		= $(PACKAGE).c


VERSION		= `date '+%Y.%m%d'`

BUILDDIR	= .build
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

TAR_FILE_WORLD_LS  = `ls -t1 $(BUILDDIR)/*.tar.gz | sort -r | head -1`

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
	perl -cw $(SRCS)

doc/man/$(PACKAGE).1: $(SRCS)
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

# Rule: sf-upload-release - [Maintenence] Sourceforge; Upload documentation
sf-upload-release:
	@echo "-- run command --"
	@echo $(FTP)			    \
		$(SOURCEFORGE_UPLOAD_HOST)  \
		$(SOURCEFORGE_UPLOAD_DIR)   \
		$(RELEASE_LS)

# Rule: release-list - [maintenance] List content of release.
release-list:
	$(TAR) -ztvf $(TAR_FILE_WORLD_LS)

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
	$(INSTALL_BIN)    $(PL) $(BINDIR)/$(INSTALL_OBJS_TOBIN)

# Rule: install-bin - Install to MANDIR1
install-man:
	$(INSTALL_BIN) -d $(MANDIR1)
	$(INSTALL_DATA) $(INSTALL_OBJS_MAN1) $(MANDIR1)

# Rule: install-doc - Install to DOCDIR1
install-doc:
	$(INSTALL_BIN) -d $(DOCDIR)
	(cd doc && tar $(TAR_OPT_NO) -cf - . | (cd  $(DOCDIR) && tar -xf -))

# Rule: install-www - Install to WWWCGIDIR
install-www:
	test -d $(WWWCGIDIR)
	$(INSTALL_BIN) $(INSTALL_OBJS_BIN) $(WWWCGIDIR)

# Rule: install - Run all install targets
install: doc install-bin install-man

# End of file
