:- use_module(library(http/http_open)).
:- use_module(library(filesex)).
:- use_module(library(archive)).

sync :-
  setup_call_cleanup(
    open('package.pl', read, In),
    (
      once(read_deps(In, Deps)),
      writeln(Deps)
    ),
    close(In)
  ).

read_deps(In, Deps) :-
  read(In, T),
  read_deps_(T, In, [], Deps).

read_deps_(end_of_file, _, Deps, Deps).
read_deps_(dep(D), In, SoFar, Deps) :-
  read(In, T),
  read_deps_(T, In, [D|SoFar], Deps).
read_deps_(_, In, SoFar, Deps) :-
  read(In, T),
  read_deps_(T, In, SoFar, Deps).

download(URL) :-
  setup_call_cleanup(
    http_open(URL, In, []),
    setup_call_cleanup(
      tmp_file_stream(binary, File, Out),
      copy_stream_data(In, Out),
    close(Out)
    ),
  close(In)
  ),
  make_directory_path(deps),
  archive_extract(File, deps, []),
  delete_file(File).
