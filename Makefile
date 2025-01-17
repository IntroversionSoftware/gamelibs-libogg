# -*- Makefile -*- for libogg

.SECONDEXPANSION:
.SUFFIXES:

ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
        QUIET          = @
        QUIET_CC       = @echo '   ' CC $<;
        QUIET_AR       = @echo '   ' AR $@;
        QUIET_RANLIB   = @echo '   ' RANLIB $@;
        QUIET_INSTALL  = @echo '   ' INSTALL $<;
        export V
endif
endif

uname_S ?= $(shell uname -s)

LIB    = libogg.a
AR    ?= ar
ARFLAGS ?= rc
CC    ?= gcc
RANLIB?= ranlib
RM    ?= rm -f

BUILD_DIR := build
BUILD_ID  ?= default-build-id
OBJ_DIR   := $(BUILD_DIR)/$(BUILD_ID)

ifeq (,$(BUILD_ID))
$(error BUILD_ID cannot be an empty string)
endif

prefix ?= /usr/local
libdir := $(prefix)/lib
includedir := $(prefix)/include

SOURCES = src/framing.c src/bitwise.c

OBJECTS := $(patsubst %.c,$(OBJ_DIR)/%.o,$(SOURCES))

HEADERS := include/ogg/ogg.h include/ogg/os_types.h
HEADERS_INST := $(patsubst include/%,$(includedir)/%,$(HEADERS))

CFLAGS ?= -O2
CFLAGS += -Iinclude

ifneq (,$(findstring CYGWIN,$(uname_S)))
CFLAGS += -D_WIN32
endif

.PHONY: install

all: $(OBJ_DIR)/$(LIB)

install: $(HEADERS_INST) $(libdir)/$(LIB)

$(includedir)/%.h: include/%.h
	-@mkdir -p $(dir $@)
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

$(libdir)/%.a: $(OBJ_DIR)/%.a
	-@if [ ! -d $(libdir)  ]; then mkdir -p $(libdir); fi
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

clean:
	$(RM) -r $(OBJ_DIR)

distclean:
	$(RM) -r $(BUILD_DIR)

$(OBJ_DIR)/$(LIB): $(OBJECTS) | $$(@D)/.
	$(QUIET_AR)$(AR) $(ARFLAGS) $@ $^
	$(QUIET_RANLIB)$(RANLIB) $@

$(OBJ_DIR)/%.o: %.c $(OBJ_DIR)/.cflags | $$(@D)/.
	$(QUIET_CC)$(CC) $(CFLAGS) -o $@ -c $<

.PRECIOUS: $(OBJ_DIR)/. $(OBJ_DIR)%/.

$(OBJ_DIR)/.:
	$(QUIET)mkdir -p $@

$(OBJ_DIR)%/.:
	$(QUIET)mkdir -p $@

TRACK_CFLAGS = $(subst ','\'',$(CC) $(CFLAGS))

$(OBJ_DIR)/.cflags: .force-cflags | $$(@D)/.
	@FLAGS='$(TRACK_CFLAGS)'; \
    if test x"$$FLAGS" != x"`cat $(OBJ_DIR)/.cflags 2>/dev/null`" ; then \
        echo "    * rebuilding libogg: new build flags or prefix"; \
        echo "$$FLAGS" > $(OBJ_DIR)/.cflags; \
    fi

.PHONY: .force-cflags
