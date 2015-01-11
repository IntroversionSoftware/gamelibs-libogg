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

uname_S ?= $(shell uname -s)

LIB    = libogg.a
AR    ?= ar
CC    ?= gcc
RANLIB?= ranlib
RM    ?= rm -f

prefix ?= /usr/local
libdir := $(prefix)/lib
includedir := $(prefix)/include

SOURCES = src/framing.c src/bitwise.c

OBJECTS := $(patsubst %.c,%.o,$(SOURCES))

CFLAGS ?= -O2
CFLAGS += -Iinclude

ifneq (,$(findstring CYGWIN,$(uname_S)))
CFLAGS += -D_WIN32
endif

.PHONY: install

all: $(LIB)

install:
	install -dm0755 $(DESTDIR)$(includedir)/ogg
	install -m0644 include/ogg/ogg.h $(DESTDIR)$(includedir)/ogg/ogg.h
	install -m0644 include/ogg/os_types.h $(DESTDIR)$(includedir)/ogg/os_types.h
	install -dm0755 $(DESTDIR)$(libdir)
	install -m0644 libogg.a $(DESTDIR)$(libdir)/libogg.a

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
