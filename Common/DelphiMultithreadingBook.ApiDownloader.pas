unit DelphiMultithreadingBook.ApiDownloader;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils, System.Threading;

type
  TDownloadResult = record
    URL: string;
    Content: string;
    DownloadException: Exception;
  end;

  TDownloadResultArray = TArray<TDownloadResult>;
  TUrlArray = TArray<string>;
  TOnBatchDownloadComplete = reference to procedure(const Results: TDownloadResultArray);

  TApiDownloader = class
  private
    FCurrentTask: ITask;
  public
    // Download a single URL asynchronously
    function DownloadUrlAsync(const URL: string): IFuture<string>;
    // Download a batch of URLs
    procedure DownloadBatchAsync(const Urls: TUrlArray; OnComplete: TOnBatchDownloadComplete);
    // Download with pagination
    function DownloadAllPagesAsync(const InitialURL: string): IFuture<TStrings>;
    procedure Cancel;
  end;

implementation

uses
  System.Json, System.NetConsts, System.Net.HttpClient, System.Net.URLClient,
  DelphiMultithreadingBook.Utils;

{ TApiDownloader }

function TApiDownloader.DownloadUrlAsync(const URL: string): IFuture<string>;
begin
  // The TTask creation is encapsulated in this method.
  Result := TTask.Future<string>(
    function: string
    var
      HTTPClient: THTTPClient;
      Response: IHTTPResponse;
    begin
      HTTPClient := THTTPClient.Create;
      try
        DebugLogWrite('Downloader: Downloading URL: %s', [URL]);
        TTask.CurrentTask.CheckCanceled;
        Response := HTTPClient.Get(URL);

        if Response.StatusCode = 200 then
          Result := Response.ContentAsString
        else
          raise Exception.CreateFmt('Failed to download "%s": Status %d',
            [URL, Response.StatusCode]);
      finally
        HTTPClient.Free;
      end;
    end);
end;

procedure TApiDownloader.DownloadBatchAsync(const Urls: TUrlArray;
  OnComplete: TOnBatchDownloadComplete);
begin
  FCurrentTask := TTask.Run(
    procedure
    var
      DownloadTasks: TArray<IFuture<string>>;
      i: Integer;
      Results: TDownloadResultArray;
    begin
      // Step 1: Fire off a task for each URL
      SetLength(DownloadTasks, Length(Urls));
      for i := 0 to High(Urls) do
      begin
        DownloadTasks[i] := DownloadUrlAsync(Urls[i]);
      end;

      // Step 2: Collect the results
      SetLength(Results, Length(DownloadTasks));
      for i := 0 to High(DownloadTasks) do
      begin
        Results[i].URL := Urls[i];
        try
          Results[i].Content := DownloadTasks[i].Value;
          Results[i].DownloadException := nil;
        except
          on E: Exception do
          begin
            Results[i].Content := '';
            Results[i].DownloadException := Exception(AcquireExceptionObject);
          end;
        end;
      end;

      // Step 3: Invoke the final callback on the UI thread
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(OnComplete) then
            OnComplete(Results);
        end);
    end);
end;

function TApiDownloader.DownloadAllPagesAsync(const InitialURL: string): IFuture<TStrings>;
begin
  Result := TTask.Future<TStrings>(
    function: TStrings
    var
      DataList: TStringList;
      HTTPClient: THTTPClient;
      JsonArray: TJSONArray;
      JsonObject, JsonInfo: TJSONObject;
      NextUrl: string;
      Response: IHTTPResponse;
    begin
      DataList := TStringList.Create;
      try
        HTTPClient := THTTPClient.Create;
        try
          HTTPClient.UserAgent := 'Delphi-Multithreading-Book-Example/1.0';
          NextUrl := InitialURL;

          while not NextUrl.IsEmpty do
          begin
            TTask.CurrentTask.CheckCanceled;
            // LogWrite is thread-safe: Used here for progress feedback.
            // Ideally, a notification or callback would be used.
            LogWrite('Fetching page: %s', [NextUrl]);

            Response := HTTPClient.Get(NextUrl);
            if Response.StatusCode <> 200 then
              raise Exception.CreateFmt('Request failed: Status %d - %s',
                [Response.StatusCode, Response.StatusText]);

            JsonObject := nil;
            try
              JsonObject := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
              if not Assigned(JsonObject) then Break;
              JsonArray := JsonObject.GetValue('results') as TJSONArray;
              if Assigned(JsonArray) then
                for var JsonValue in JsonArray do
                  if (JsonValue is TJSONObject) and
                    ((JsonValue as TJSONObject).TryGetValue('name', NextUrl)) then
                    DataList.Add(NextUrl);

              if (JsonObject.TryGetValue('info', JsonInfo)) then
              begin
                if JsonInfo.TryGetValue('next', NextUrl) then
                begin
                  if NextUrl = 'null' then
                    NextUrl := '';
                end
                else
                  NextUrl := '';
                JsonInfo := nil;
              end;
            finally
              JsonObject.Free;
            end;
          end;
        finally
          HTTPClient.Free;
        end;
        Result := DataList;
        DataList := nil;
      except
        DataList.Free;
        raise;
      end;
    end);
  FCurrentTask := Result;
end;

procedure TApiDownloader.Cancel;
begin
  if Assigned(FCurrentTask) then
    FCurrentTask.Cancel;
end;

end.
