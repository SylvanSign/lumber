:- module(jack, [
    sync/0,
    use_remote_module/1,
    use_remote_module/2
  ]).

:- use_module(library(http/http_open)).
:- use_module(library(filesex)).
:- use_module(library(archive)).

% TODO Don't hardcode the atom_concat path thing, maybe read from some .pl file
% that's created at sync time that maps module names to their deps/ subdirectory?
use_remote_module(Module) :-
  atom_concat('deps/sample-prolog-library-main/prolog/', Module, QualifiedModule),
  use_module(QualifiedModule).

use_remote_module(Module, ImportList) :-
  atom_concat('deps/sample-prolog-library-main/prolog/', Module, QualifiedModule),
  use_module(QualifiedModule, ImportList).


sync :-
  setup_call_cleanup(
    open('package.pl', read, In),
    download_deps_from_package_pl(In),
    close(In)
  ).

download_deps_from_package_pl(In) :-
  findall(D, read_with_backtracking(In, dep(D)), Deps),
  (  exists_directory(deps)
  -> delete_directory_contents(deps)
  ;  true
  ),
  make_directory_path(deps),
  maplist(download_url_to_deps_directory, Deps).

read_with_backtracking(In, Term) :-
  repeat,
  read(In, ReadTerm),
  (  ReadTerm \= end_of_file
  -> ReadTerm = Term
  ;  !,
     fail
  ).

download_url_to_deps_directory(URL) :-
  setup_call_cleanup(
    http_open(URL, In, []),
    setup_call_cleanup(
      tmp_file_stream(binary, File, Out),
      copy_stream_data(In, Out),
    close(Out)
    ),
  close(In)
  ),
  archive_extract(File, deps, []),
  delete_file(File).
