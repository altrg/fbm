-module(fbm_handler).
-behaviour(cowboy_http_handler).

-include("fbm.hrl").

%% cowboy callbacks
-export([init/3, handle/2, terminate/3]).

%% ===================================================================
%% cowboy callbacks
%% ===================================================================
init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {ok, Req2} = handle_path(cowboy_req:path_info(Req)),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

%% ===================================================================
%% Internal functions
%% ===================================================================
handle_path({[<<"me">>], Req})->
    handle_token(cowboy_req:qs_val(<<"access_token">>, Req));
handle_path({_Path, Req}) ->
    %?D("Unknown path ~p", [Path]),
    %cowboy_req:reply(404, [], Req).
    cowboy_req:reply(200, [], <<"hello">>, Req).

handle_token({Token, Req}) when is_binary(Token) ->
    Body = <<"{\"id\":\"", Token/binary, "\"}">>,
    cowboy_req:reply(200, [], Body, Req);
handle_token({undefined, Req}) ->
    ?D("No token provided ~p", [element(1, cowboy_req:qs(Req))]),
    cowboy_req:reply(403, [], Req).
