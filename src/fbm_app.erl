-module(fbm_app).
-behaviour(application).

%% API
-export([start/0, get_config/2]).

%% Application callbacks
-export([start/2, stop/1]).

-define(APPS, [lager, crypto, ranch, cowboy]).

%% ===================================================================
%% API
%% ===================================================================
%% @doc Launcher for erl .. -s fbm_app ..
start() ->
    application:start(fbm, permanent).

%% @doc Get value or default from config
-spec get_config(atom(), term()) -> term().
get_config(Par, Default) ->
    case application:get_env(fbm, Par) of
        undefined -> Default;
        {ok, Val} -> Val
    end.

%% ===================================================================
%% Application callbacks
%% ===================================================================
start(_StartType, _StartArgs) ->
    [application:load(App) || App <- ?APPS],
    load_config(),
    [application:start(App) || App <- ?APPS],
    start_cowboy(),
    lager:info("Starting fbm"),
    fbm_sup:start_link().

stop(_State) ->
    ok.

%% ===================================================================
%% Internal functions
%% ===================================================================
%% @doc Init apps from config
load_config() ->
    {ok, [[CfgFile]]} = init:get_argument(cfg),
    {ok, Config} = file:consult(CfgFile),
    [[application:set_env(App, Key, Val) || {Key, Val} <- Cfg]
        || {App, Cfg} <- Config].

%% @doc Initialize webserver
start_cowboy() ->
    Root = {"/[...]", fbm_handler, []},
    Dispatch = cowboy_router:compile([{'_', [Root]}]),
    {ok, _} = cowboy:start_https(https, get_config(acceptors, 100),
                                [{port, get_config(port, 8443)},
                                 {max_connections, get_config(max_connections, 1024)},
                                 {certfile, "priv/ssl/cert.pem"},
                                 {keyfile, "priv/ssl/cert.key"}],
                                 [{env, [{dispatch, Dispatch}]}]).
