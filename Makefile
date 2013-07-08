# -*- Makefile -*- for libogg

ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
        QUIET_CC       = @echo '   ' CC $@;
        QUIET_AR       = @echo '   ' AR $@;
        QUIET_RANLIB   = @echo '   ' RANLIB $@;
        QUIET_INSTALL  = @echo '   ' INSTALL $<;
        export V
endif
endif

LIB    = libogg.a
AR    ?= ar
CC    ?= gcc
RANLIB?= ranlib
RM    ?= rm -f

prefix ?= /usr/local
destdir ?=
libdir := $(prefix)/lib
includedir := $(prefix)/include

HEADERS = include/ogg/ogg.h include/ogg/os_types.h
SOURCES = src/framing.c src/bitwise.c

HEADERS_INST := $(patsubst include/%,$(destdir)$(includedir)/%,$(HEADERS))
OBJECTS := $(patsubst %.c,%.o,$(SOURCES))

CFLAGS ?= -O2
CFLAGS += -Iinclude

.PHONY: install

all: $(LIB)

$(destdir)$(includedir)/%.h: include/ogg/%.h
	@mkdir -p $(destdir)$(includedir)/$(shell dirname $(patsubst include/%,%,$<))
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

$(destdir)$(libdir)/%.a: %.a
	-@mkdir -p $(destdir)$(libdir)
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

install: $(HEADERS_INST) $(destdir)$(libdir)/$(LIB)

clean:
	$(RM) $(OBJECTS) $(LIB) .cflags

distclean: clean

$(LIB): $(OBJECTS)
	$(QUIET_AR)$(AR) rcu $@ $^
	$(QUIET_RANLIB)$(RANLIB) $@

%.o: %.c .cflags
	$(QUIET_CC)$(CC) $(CFLAGS) -o $@ -c $<

TRACK_CFLAGS = $(subst ','\'',$(CC) $(CFLAGS))

.cflags: .force-cflags
	@FLAGS='$(TRACK_CFLAGS)'; \
    if test x"$$FLAGS" != x"`cat .cflags 2>/dev/null`" ; then \
        echo "    * rebuilding libogg: new build flags or prefix"; \
        echo "$$FLAGS" > .cflags; \
    fi

.PHONY: .force-cflags
