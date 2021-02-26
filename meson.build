project('libogg', 'c', version: '1.3.4')

compiler = meson.get_compiler('c')
link_deps = []

incdirs = ['include']

sources = [ 'src/framing.c', 'src/bitwise.c' ]

incdirs = include_directories(incdirs)

lib = static_library(
    'ogg',
    sources,
    include_directories: incdirs,
    dependencies: link_deps,
)

libogg_dep = declare_dependency(
    include_directories: incdirs,
    dependencies: link_deps,
    link_with: lib,
    version: meson.project_version()
)

meson.override_dependency('ogg', libogg_dep)

# vim: set ts=4 sts=4 sw=4 et:
