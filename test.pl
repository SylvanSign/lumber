:- use_module(jack).
:- use_remote_module(foo, [bar/0]).

go :-
  foo:bar.
