:- use_module(library(http/http_open)).
:- use_module(library(filesex)).
:- use_module(library(archive)).

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
