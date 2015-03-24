unit Curl.Easy;

interface

uses
  // System
  System.Classes, System.SysUtils,
  // cUrl
  Curl.Lib, Curl.Interfaces;

type
  TCurlVerifyHost = (
      CURL_VERIFYHOST_NONE,
      CURL_VERIFYHOST_EXISTENCE,
      CURL_VERIFYHOST_MATCH );

  ICurl = interface
    function GetHandle : TCurlHandle;
    property Handle : TCurlHandle read GetHandle;

    ///  Sets a cURL option.
    ///  SetXXX functions are simply wrappers for SetOpt.
    procedure SetOpt(aOption : TCurlOffOption; aData : TCurlOff);  overload;
    procedure SetOpt(aOption : TCurlOption; aData : pointer);  overload;
    procedure SetOpt(aOption : TCurlIntOption; aData : NativeUInt);  overload;
    procedure SetOpt(aOption : TCurlIntOption; aData : boolean);  overload;
    procedure SetOpt(aOption : TCurlStringOption; aData : PAnsiChar);  overload;
    procedure SetOpt(aOption : TCurlStringOption; aData : RawByteString);  overload;
    procedure SetOpt(aOption : TCurlStringOption; aData : UnicodeString);  overload;
    procedure SetOpt(aOption : TCurlSlistOption; aData : PCurlSList);  overload;
              deprecated 'Use SetXXX instead: SetCustomHeaders, SetResolveList, etc.';
    procedure SetOpt(aOption : TCurlPostOption; aData : PCurlHttpPost);  overload;
              deprecated 'Use SetForm or property Form instead.';

    ///  Sets a URL. Equivalent to SetOpt(CURLOPT_URL, aData).
    procedure SetUrl(aData : PAnsiChar);  overload;
    procedure SetUrl(aData : RawByteString);  overload;
    procedure SetUrl(aData : UnicodeString);  overload;

    ///  Sets a CA file for SSL
    procedure SetCaFile(aData : PAnsiChar);      overload;
    procedure SetCaFile(aData : RawByteString);  overload;
    procedure SetCaFile(aData : UnicodeString);  overload;

    ///  Sets a user-agent
    procedure SetUserAgent(aData : PAnsiChar);      overload;
    procedure SetUserAgent(aData : RawByteString);  overload;
    procedure SetUserAgent(aData : UnicodeString);  overload;

    ///  Sets an SSL version
    procedure SetSslVersion(aData : TCurlSslVersion);

    ///  Set verify option
    procedure SetSslVerifyHost(aData : TCurlVerifyHost);
    procedure SetSslVerifyPeer(aData : boolean);

    ///  Sets a receiver stream. Equivalent to twin SetOpt,
    ///  WRITEFUNCTION and WRITEDATA.
    ///  Does not destroy the stream, you should dispose of it manually!
    ///  If aData = nil: removes all custom receivers.
    procedure SetRecvStream(aData : TStream);

    ///  Sets a sender stream. Equivalent to twin SetOpt,
    ///  READFUNCTION and READDATA.
    ///  Does not destroy the stream, you should dispose of it manually!
    ///  If aData = nil: removes all custom senders.
    procedure SetSendStream(aData : TStream);

    ///  Sets a receiver stream. Equivalent to twin SetOpt,
    ///  HEADERFUNCTION and HEADERDATA.
    ///  Does not destroy the stream, you should dispose of it manually!
    ///  If aData = nil: removes all custom receivers.
    procedure SetHeaderStream(aData : TStream);

    ///  Sets whether cURL will follow redirections.
    procedure SetFollowLocation(aData : boolean);

    ///  Gets/sets form data
    procedure SetForm(aForm : ICurlForm);
    function GetForm : ICurlForm;

    ///  For all these options the object stores a reference to an ICurlSList
    ///  for itself.

    ///  This points to a linked list of headers. This
    ///  list is also used for RTSP.
    procedure SetCustomHeaders(v : ICurlSList);
    ///  send linked-list of post-transfer QUOTE commands
    procedure SetPostQuote(v : ICurlSList);
    ///  Provide a pointer to a curl_slist with variables to pass to the telnet
    ///  negotiations. The variables should be in the format <option=value>.
    ///  libcurl supports the options 'TTYPE', 'XDISPLOC' and 'NEW_ENV'.
    ///  See the TELNET standard for details.
    procedure SetTelnetOptions(v : ICurlSList);
    ///  send linked-list of pre-transfer QUOTE commands
    procedure SetPreQuote(v : ICurlSList);
    ///  Set aliases for HTTP 200 in the HTTP Response header
    procedure SetHttp200Aliases(v : ICurlSList);
    ///  set the SMTP mail receiver(s)
    procedure SetMailRcpt(v : ICurlSList);
    ///  send linked-list of name:port:address sets
    procedure SetResolveList(v : ICurlSList);
    ///  This points to a linked list of headers used for proxy requests only,
    ///  struct curl_slist kind
    procedure SetProxyHeader(v : ICurlSList);

    ///  Performs the action.
    ///  Actually does RaiseIf(PerformNe).
    procedure Perform;

    ///  Performs the action w/o throwing an error.
    ///  The user should process error codes for himself.
    function PerformNe : TCurlCode;

    ///  Does nothing if aCode is OK; otherwise localizes the error message
    ///  and throws an exception.
    ///  Sometimes you�d like to process some errors in place w/o bulky
    ///  try/except. Then you run PerformNe, manually process some errors,
    ///  and do RaiseIf for everything else.
    procedure RaiseIf(aCode : TCurlCode);

    ///  Returns some information.
    ///  GetXXX functions are wrappers for GetInfo.
    function GetInfo(aCode : TCurlLongInfo) : longint;  overload;
    function GetInfo(aInfo : TCurlStringInfo) : PAnsiChar;  overload;
    function GetInfo(aInfo : TCurlDoubleInfo) : double;  overload;
    function GetInfo(aInfo : TCurlSListInfo) : PCurlSList;  overload;

    ///  Returns response code. Equivalent to GetInfo(CURLINFO_RESPONSE_CODE).
    function GetResponseCode : longint;

    ///  Makes an exact copy, e.g. for multithreading.
    function Clone : ICurl;

    property Form : ICurlForm read GetForm write SetForm;
  end;

  TEasyCurlImpl = class (TInterfacedObject, ICurl)
  private
    type
      TSListEntry = record
        str : RawByteString;
        entry : TCurlSList;
      end;
      OaSListEntry = array of TSListEntry;
  private
    fHandle : TCurlHandle;
    fCustomHeaders, fPostQuote, fTelnetOptions, fPreQuote,
        fHttp200Aliases, fMailRcpt, fResolveList, fProxyHeader : ICurlSList;
    fForm :  ICurlForm;

    procedure SetSList(
            aOpt : TCurlSlistOption;
            var aOldValue : ICurlSList;
            aNewValue : ICurlSList);
  public
    constructor Create;  overload;
    constructor Create(aSource : TEasyCurlImpl);  overload;
    destructor Destroy;  override;
    function GetHandle : TCurlHandle;

    procedure RaiseIf(aCode : TCurlCode);  inline;

    procedure SetOpt(aOption : TCurlOffOption; aData : TCurlOff);  overload;
    procedure SetOpt(aOption : TCurlOption; aData : pointer);  overload;
    procedure SetOpt(aOption : TCurlIntOption; aData : NativeUInt);  overload;
    procedure SetOpt(aOption : TCurlIntOption; aData : boolean);  overload;
    procedure SetOpt(aOption : TCurlStringOption; aData : PAnsiChar);  overload;
    procedure SetOpt(aOption : TCurlStringOption; aData : RawByteString);  overload;
    procedure SetOpt(aOption : TCurlStringOption; aData : UnicodeString);  overload;
    procedure SetOpt(aOption : TCurlSlistOption; aData : PCurlSList);  overload;
    procedure SetOpt(aOption : TCurlPostOption; aData : PCurlHttpPost);  overload;

    procedure SetUrl(aData : PAnsiChar);      overload;   inline;
    procedure SetUrl(aData : RawByteString);  overload;   inline;
    procedure SetUrl(aData : UnicodeString);  overload;   inline;

    procedure SetCaFile(aData : PAnsiChar);      overload;   inline;
    procedure SetCaFile(aData : RawByteString);  overload;   inline;
    procedure SetCaFile(aData : UnicodeString);  overload;   inline;

    procedure SetUserAgent(aData : PAnsiChar);      overload;
    procedure SetUserAgent(aData : RawByteString);  overload;
    procedure SetUserAgent(aData : UnicodeString);  overload;

    procedure SetSslVersion(aData : TCurlSslVersion);  inline;

    procedure SetSslVerifyHost(aData : TCurlVerifyHost);
    procedure SetSslVerifyPeer(aData : boolean);

    procedure SetRecvStream(aData : TStream);
    procedure SetSendStream(aData : TStream);
    procedure SetHeaderStream(aData : TStream);

    procedure SetFollowLocation(aData : boolean);

    procedure SetForm(aForm : ICurlForm);
    function GetForm : ICurlForm;

    procedure SetCustomHeaders(v : ICurlSList);
    procedure SetPostQuote(v : ICurlSList);
    procedure SetTelnetOptions(v : ICurlSList);
    procedure SetPreQuote(v : ICurlSList);
    procedure SetHttp200Aliases(v : ICurlSList);
    procedure SetMailRcpt(v : ICurlSList);
    procedure SetResolveList(v : ICurlSList);
    procedure SetProxyHeader(v : ICurlSList);

    procedure Perform;
    function PerformNe : TCurlCode;

    function GetInfo(aInfo : TCurlLongInfo) : longint;  overload;
    function GetInfo(aInfo : TCurlStringInfo) : PAnsiChar;  overload;
    function GetInfo(aInfo : TCurlDoubleInfo) : double;  overload;
    function GetInfo(aInfo : TCurlSListInfo) : PCurlSList;  overload;

    function GetResponseCode : longint;

    ///  This is implementation of ICurl.Clone. If you dislike
    ///  reference-counting, use TEasyCurlImpl.Create(someCurl).
    function Clone : ICurl;

    class function StreamWrite(
            var Buffer;
            Size, NItems : NativeUInt;
            OutStream : pointer) : NativeUInt;  cdecl;  static;
    class function StreamRead(
            var Buffer;
            Size, NItems : NativeUInt;
            OutStream : pointer) : NativeUInt;  cdecl;  static;

    property Form : ICurlForm read GetForm write SetForm;
  end;

  ECurlError = class (ECurl)
  private
    fCode : TCurlCode;
  public
    constructor Create(aObject : TEasyCurlImpl; aCode : TCurlCode);
    property Code : TCurlCode read fCode;
  end;

  /// Converts a cURL error code into localized string.
  /// It does not rely on any localization engine and string storage technology,
  ///   whether it is Windows resource, text file or XML.
  /// The default version (CurlDefaultLocalize.ErrorMsg) just takes strings from
  ///   cURL DLL.
  EvCurlLocalizeError = function (
        aObject : TEasyCurlImpl; aCode : TCurlCode) : string of object;

  CurlDefaultLocalize = class
  public
    class function ErrorMsg(
        aObject : TEasyCurlImpl; aCode : TCurlCode) : string;
  end;

var
  CurlLocalizeError : EvCurlLocalizeError = CurlDefaultLocalize.ErrorMsg;

function CurlGet : ICurl;

implementation

///// Errors and error localization ////////////////////////////////////////////

class function CurlDefaultLocalize.ErrorMsg(
    aObject : TEasyCurlImpl; aCode : TCurlCode) : string;
begin
  Result := string(curl_easy_strerror(aCode));
end;


///// ECurl and descendents ////////////////////////////////////////////////////

constructor ECurlError.Create(aObject : TEasyCurlImpl; aCode : TCurlCode);
begin
  inherited Create(CurlLocalizeError(aObject, aCode));
  fCode := aCode;
end;


///// TEasyCurlImpl ////////////////////////////////////////////////////////////

constructor TEasyCurlImpl.Create;
begin
  inherited;
  fHandle := curl_easy_init;
  if fHandle = nil then
    raise ECurlInternal.Create('[TEasyCurlImpl.Create] Cannot create cURL object.');
end;

constructor TEasyCurlImpl.Create(aSource : TEasyCurlImpl);
begin
  inherited Create;
  fHandle := curl_easy_duphandle(aSource.fHandle);
  if fHandle = nil then
    raise ECurlInternal.Create('[TEasyCurlImpl.Create(TEasyCurlImpl)] Cannot clone cURL object.');
end;

destructor TEasyCurlImpl.Destroy;
begin
  curl_easy_cleanup(fHandle);
  inherited;
end;

procedure TEasyCurlImpl.RaiseIf(aCode : TCurlCode);
begin
  if aCode <> CURLE_OK then
    raise ECurlError.Create(Self, aCode);
end;


function TEasyCurlImpl.GetHandle : TCurlHandle;
begin
  Result := fHandle;
end;

procedure TEasyCurlImpl.Perform;
begin
  RaiseIf(curl_easy_perform(fHandle));
end;

function TEasyCurlImpl.PerformNe : TCurlCode;
begin
  Result := curl_easy_perform(fHandle);
end;

function TEasyCurlImpl.GetInfo(aInfo : TCurlLongInfo) : longint;
begin
  RaiseIf(curl_easy_getinfo(fHandle, aInfo, Result));
end;

function TEasyCurlImpl.GetInfo(aInfo : TCurlStringInfo) : PAnsiChar;
begin
  RaiseIf(curl_easy_getinfo(fHandle, aInfo, Result));
end;

function TEasyCurlImpl.GetInfo(aInfo : TCurlDoubleInfo) : double;
begin
  RaiseIf(curl_easy_getinfo(fHandle, aInfo, Result));
end;

function TEasyCurlImpl.GetInfo(aInfo : TCurlSListInfo) : PCurlSList;
begin
  RaiseIf(curl_easy_getinfo(fHandle, aInfo, Result));
end;

procedure TEasyCurlImpl.SetOpt(aOption : TCurlOffOption; aData : TCurlOff);
begin
  RaiseIf(curl_easy_setopt(fHandle, aOption, aData));
end;

procedure TEasyCurlImpl.SetOpt(aOption : TCurlStringOption; aData : PAnsiChar);
begin
  RaiseIf(curl_easy_setopt(fHandle, aOption, aData));
end;

procedure TEasyCurlImpl.SetOpt(aOption : TCurlOption; aData : pointer);
begin
  RaiseIf(curl_easy_setopt(fHandle, aOption, aData));
end;

procedure TEasyCurlImpl.SetOpt(aOption : TCurlIntOption; aData : NativeUInt);
begin
  RaiseIf(curl_easy_setopt(fHandle, aOption, aData));
end;

procedure TEasyCurlImpl.SetOpt(aOption : TCurlIntOption; aData : boolean);
begin
  RaiseIf(curl_easy_setopt(fHandle, aOption, aData));
end;

procedure TEasyCurlImpl.SetOpt(aOption : TCurlStringOption; aData : RawByteString);
begin
  RaiseIf(curl_easy_setopt(fHandle, aOption, PAnsiChar(aData)));
end;

procedure TEasyCurlImpl.SetOpt(aOption : TCurlStringOption; aData : UnicodeString);
begin
  RaiseIf(curl_easy_setopt(fHandle, aOption, PAnsiChar(UTF8Encode(aData))));
end;

procedure TEasyCurlImpl.SetOpt(aOption : TCurlSlistOption; aData : PCurlSList);
begin
  RaiseIf(curl_easy_setopt(fHandle, aOption, aData));
end;

procedure TEasyCurlImpl.SetOpt(aOption : TCurlPostOption; aData : PCurlHttpPost);
begin
  RaiseIf(curl_easy_setopt(fHandle, aOption, aData));
end;


function TEasyCurlImpl.Clone : ICurl;
begin
  Result := TEasyCurlImpl.Create(Self);
end;

procedure TEasyCurlImpl.SetUrl(aData : PAnsiChar);
begin
  SetOpt(CURLOPT_URL, aData);
end;

procedure TEasyCurlImpl.SetUrl(aData : RawByteString);
begin
  SetOpt(CURLOPT_URL, aData);
end;

procedure TEasyCurlImpl.SetUrl(aData : UnicodeString);
begin
  SetOpt(CURLOPT_URL, aData);
end;

procedure TEasyCurlImpl.SetCaFile(aData : PAnsiChar);
begin
  SetOpt(CURLOPT_CAINFO, aData);
end;

procedure TEasyCurlImpl.SetCaFile(aData : RawByteString);
begin
  SetOpt(CURLOPT_CAINFO, aData);
end;

procedure TEasyCurlImpl.SetCaFile(aData : UnicodeString);
begin
  SetOpt(CURLOPT_CAINFO, aData);
end;

procedure TEasyCurlImpl.SetSslVersion(aData : TCurlSslVersion);
begin
  SetOpt(CURLOPT_SSLVERSION, ord(aData));
end;

procedure TEasyCurlImpl.SetUserAgent(aData : PAnsiChar);
begin
  SetOpt(CURLOPT_USERAGENT, aData);
end;

procedure TEasyCurlImpl.SetUserAgent(aData : RawByteString);
begin
  SetOpt(CURLOPT_USERAGENT, PAnsiChar(aData));
end;

procedure TEasyCurlImpl.SetUserAgent(aData : UnicodeString);
begin
  SetOpt(CURLOPT_USERAGENT, PAnsiChar(UTF8Encode(aData)));
end;

class function TEasyCurlImpl.StreamWrite(
        var Buffer;
        Size, NItems : NativeUInt;
        OutStream : pointer) : NativeUInt;  cdecl;
begin
  Result := TStream(OutStream).Write(Buffer, Size * NItems);
end;


class function TEasyCurlImpl.StreamRead(
        var Buffer;
        Size, NItems : NativeUInt;
        OutStream : pointer) : NativeUInt;  cdecl;
begin
  Result := TStream(OutStream).Read(Buffer, Size * NItems);
end;


procedure TEasyCurlImpl.SetRecvStream(aData : TStream);
begin
  SetOpt(CURLOPT_WRITEDATA, aData);
  if aData = nil
    then SetOpt(CURLOPT_WRITEFUNCTION, nil)
    else SetOpt(CURLOPT_WRITEFUNCTION, @StreamWrite);
end;


procedure TEasyCurlImpl.SetSendStream(aData : TStream);
begin
  SetOpt(CURLOPT_READDATA, aData);
  // Don�t set NULL to read function, as the function may be needed by form
  SetOpt(CURLOPT_READFUNCTION, @StreamRead);
end;

procedure TEasyCurlImpl.SetHeaderStream(aData : TStream);
begin
  SetOpt(CURLOPT_HEADERDATA, aData);
  if aData = nil
    then SetOpt(CURLOPT_HEADERFUNCTION, nil)
    else SetOpt(CURLOPT_HEADERFUNCTION, @StreamWrite);
end;

function TEasyCurlImpl.GetResponseCode : longint;
begin
  Result := GetInfo(CURLINFO_RESPONSE_CODE);
end;

procedure TEasyCurlImpl.SetSList(
        aOpt : TCurlSlistOption;
        var aOldValue : ICurlSList;
        aNewValue : ICurlSList);
var
  rawVal : PCurlSList;
begin
  // New value = nil � do not dereference
  if aNewValue = nil
    then rawVal := nil
    else rawVal := aNewValue.RawValue;

  // Raw value = nil � do not store
  if rawVal = nil
    then aOldValue := nil
    else aOldValue := aNewValue;

  SetOpt(aOpt, rawVal);
end;

procedure TEasyCurlImpl.SetCustomHeaders(v : ICurlSList);
begin
  SetSList(CURLOPT_HTTPHEADER, fCustomHeaders, v);
end;

procedure TEasyCurlImpl.SetPostQuote(v : ICurlSList);
begin
  SetSList(CURLOPT_POSTQUOTE, fPostQuote, v);
end;

procedure TEasyCurlImpl.SetTelnetOptions(v : ICurlSList);
begin
  SetSList(CURLOPT_TELNETOPTIONS, fTelnetOptions, v);
end;

procedure TEasyCurlImpl.SetPreQuote(v : ICurlSList);
begin
  SetSList(CURLOPT_PREQUOTE, fPreQuote, v);
end;

procedure TEasyCurlImpl.SetHttp200Aliases(v : ICurlSList);
begin
  SetSList(CURLOPT_HTTP200ALIASES, fHttp200Aliases, v);
end;

procedure TEasyCurlImpl.SetMailRcpt(v : ICurlSList);
begin
  SetSList(CURLOPT_MAIL_RCPT, fMailRcpt, v);
end;

procedure TEasyCurlImpl.SetResolveList(v : ICurlSList);
begin
  SetSList(CURLOPT_RESOLVE, fResolveList, v);
end;

procedure TEasyCurlImpl.SetProxyHeader(v : ICurlSList);
begin
  SetSList(CURLOPT_PROXYHEADER, fProxyHeader, v);
end;

procedure TEasyCurlImpl.SetFollowLocation(aData : boolean);
begin
  SetOpt(CURLOPT_FOLLOWLOCATION, aData);
end;


procedure TEasyCurlImpl.SetSslVerifyHost(aData : TCurlVerifyHost);
begin
  SetOpt(CURLOPT_SSL_VERIFYHOST, ord(aData));
end;


procedure TEasyCurlImpl.SetSslVerifyPeer(aData : boolean);
begin
  SetOpt(CURLOPT_SSL_VERIFYPEER, aData);
end;

procedure TEasyCurlImpl.SetForm(aForm : ICurlForm);
begin
  if aForm <> nil then begin
    SetOpt(CURLOPT_HTTPPOST, aForm.RawValue);
    if aForm.DoesUseStream
      then SetOpt(CURLOPT_READFUNCTION, @StreamRead);
  end else begin
    SetOpt(CURLOPT_HTTPPOST, nil);
  end;
  fForm := aForm;
end;

function TEasyCurlImpl.GetForm : ICurlForm;
begin
  Result := fForm;
end;

///// Standalone functions /////////////////////////////////////////////////////

function CurlGet : ICurl;
begin
  Result := TEasyCurlImpl.Create;
end;

initialization
  curl_global_init(CURL_GLOBAL_DEFAULT);
finalization
  curl_global_cleanup;
end.
