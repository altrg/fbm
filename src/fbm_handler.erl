-module(fbm_handler).
-behaviour(cowboy_http_handler).

%% cowboy callbacks
-export([init/3, handle/2, terminate/3]).

%% ===================================================================
%% cowboy callbacks
%% ===================================================================
init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {ok, Req2} = cowboy_req:reply(200, [], <<"Hello world!">>, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

%% ===================================================================
%% Internal functions
%% ===================================================================
