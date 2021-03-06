﻿program Https;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Curl.Lib in '..\..\..\Src\Curl.Lib.pas',
  Curl.Easy in '..\..\..\Src\Curl.Easy.pas',
  Curl.Interfaces in '..\..\..\Src\Curl.Interfaces.pas';

var
  curl : ICurl;
begin
  try
    curl := CurlGet;
    curl.SetUrl('https://ukr.net');
    curl.SetFollowLocation(true);
    curl.SetCaFile('cacert.pem');
    // Unicode is also supported!
    //curl.SetCaFile('α×β.pem');

    // Perform the request, res will get the return code
    curl.Perform;

    // Check for errors
    Writeln(Format('HTTP response code: %d', [ curl.GetResponseCode ] ));
  except
    on e : Exception do
      writeln('cURL failed: ', e.Message);
  end;

  Readln;
end.
