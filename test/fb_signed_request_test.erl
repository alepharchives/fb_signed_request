-module(fb_signed_request_test).

-compile(export_all).

% Include etest's assertion macros.
-include_lib("etest/include/etest.hrl").

-define(FB_SECRET, "897z956a2z7zzzzz5783z458zz3z7556").
-define(VALID_REQ, "Z9Xn16Pdo5ac9YWDh5HD70aujhsZ9eCoyPMcpd2aaiM.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTExMTExMTExMTExMTF8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTExMTExMTExMS4xLTExMTExMTExMTExMTExMXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImFnZSI6eyJtaW4iOjIxfSwiY291bnRyeSI6ImRlIiwibG9jYWxlIjoiZW5fVVMifSwidXNlcl9pZCI6IjExMTExMTExMTExMTExMSJ9").
-define(INVALID_REQ_FORMAT, "Z9Xn16Pdo5ac9YWDh5HD70aujhsZ9eCoyPMcpd2aaiM2eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTExMTExMTExMTExMTF8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTExMTExMTExMS4xLTExMTExMTExMTExMTExMXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImFnZSI6eyJtaW4iOjIxfSwiY291bnRyeSI6ImRlIiwibG9jYWxlIjoiZW5fVVMifSwidXNlcl9pZCI6IjExMTExMTExMTExMTExMSJ9").
-define(INVALID_REQ_PAYLOAD, "Z9Xn16Pdo5ac9YWDh5HD70aujhsZ9eCoyPMcpd2aaiM.*yJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTExMTExMTExMTExMTF8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTExMTExMTExMS4xLTExMTExMTExMTExMTExMXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImFnZSI6eyJtaW4iOjIxfSwiY291bnRyeSI6ImRlIiwibG9jYWxlIjoiZW5fVVMifSwidXNlcl9pZCI6IjExMTExMTExMTExMTExMSJ9").
-define(INVALID_REQ_SIGNATURE, "umfudisP7mKhsi9nZboBg15yMZKhfQAARL9UoZtSE.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDg5ODg4MDAsImlzc3VlZF9hdCI6MTMwODk4NTAxOCwib2F1dGhfdG9rZW4iOiIxMTExMTExMTExMTExMTF8Mi5BUUJBdHRSbExWbndxTlBaLjM2MDAuMTExMTExMTExMS4xLTExMTExMTExMTExMTExMXxUNDl3M0Jxb1pVZWd5cHJ1NTFHcmE3MGhFRDgiLCJ1c2VyIjp7ImNvdW50cnkiOiJkZSIsImxvY2FsZSI6ImVuX1VTIiwiYWdlIjp7Im1pbiI6MjF9fSwidXNlcl9pZCI6IjExMTExMTExMTExMTExMSJ9").
-define(INVALID_REQ_ALGORITHM, "r9V9QJKT6_Zu0nvgzdKBF3mPUjttpuc6sXVBSsQbINg.eyJhbGdvcml0aG0iOiJ1bmtub3duIiwiZXhwaXJlcyI6MTMwODk4ODgwMCwiaXNzdWVkX2F0IjoxMzA4OTg1MDE4LCJvYXV0aF90b2tlbiI6IjExMTExMTExMTExMTExMXwyLkFRQkF0dFJsTFZud3FOUFouMzYwMC4xMTExMTExMTExLjEtMTExMTExMTExMTExMTExfFQ0OXczQnFvWlVlZ3lwcnU1MUdyYTcwaEVEOCIsInVzZXIiOnsiYWdlIjp7Im1pbiI6MjF9LCJjb3VudHJ5IjoiZGUiLCJsb2NhbGUiOiJlbl9VUyJ9LCJ1c2VyX2lkIjoiMTExMTExMTExMTExMTExIn0").
-define(EXPECTED_VALID_DATA, <<"{\"algorithm\":\"HMAC-SHA256\",\"expires\":1308988800,\"issued_at\":1308985018,\"oauth_token\":\"111111111111111|2.AQBAttRlLVnwqNPZ.3600.1111111111.1-111111111111111|T49w3BqoZUegypru51Gra70hED8\",\"user\":{\"age\":{\"min\":21},\"country\":\"de\",\"locale\":\"en_US\"},\"user_id\":\"111111111111111\"}">>).


test_parsing_a_valid_request() ->
    Result = fb_signed_request:parse(?VALID_REQ, ?FB_SECRET),
    ?assert_equal({ok, ?EXPECTED_VALID_DATA}, Result).


test_parsing_a_request_with_invalid_format() ->
    Result = fb_signed_request:parse(?INVALID_REQ_FORMAT, ?FB_SECRET),
    ?assert_equal({error, invalid_format}, Result).


test_parsing_a_request_with_invalid_payload() ->
    Result = fb_signed_request:parse(?INVALID_REQ_PAYLOAD, ?FB_SECRET),
    ?assert_equal({error, invalid_payload}, Result).


test_parsing_a_request_with_invalid_signature() ->
    Result = fb_signed_request:parse(?INVALID_REQ_SIGNATURE, ?FB_SECRET),
    ?assert_equal({error, invalid_signature}, Result).


test_parsing_a_invalid_request_algorithm() ->
    Result = fb_signed_request:parse(?INVALID_REQ_ALGORITHM, ?FB_SECRET),
    ?assert_equal({error, unsupported_algorithm}, Result).


test_generating_a_invalid_request() ->
    SignedRequest = fb_signed_request:generate(?INVALID_REQ_ALGORITHM, ?FB_SECRET),
    Result = fb_signed_request:parse(SignedRequest, "c2b7476a4b7078bcd816da55bb8fe22d"),
    ?assert_equal({error, unsupported_algorithm}, Result).


test_generating_and_parsing_and_validating_a_request() ->
    SignedRequest       = fb_signed_request:generate(?EXPECTED_VALID_DATA, ?FB_SECRET),
    ?assert_equal(?VALID_REQ, SignedRequest),
    {ok, ParsedRequest} = fb_signed_request:parse(SignedRequest, ?FB_SECRET),
    ?assert_equal(ParsedRequest, ?EXPECTED_VALID_DATA).


test_generate_signed_request_as_binary() ->
    SignedRequest = fb_signed_request:generate(
        ?EXPECTED_VALID_DATA, ?FB_SECRET, [{return, binary}]
    ),

    ?assert_equal(erlang:list_to_binary(?VALID_REQ), SignedRequest).
