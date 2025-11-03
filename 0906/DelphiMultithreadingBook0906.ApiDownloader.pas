unit DelphiMultithreadingBook0906.ApiDownloader;

interface

uses
  System.Generics.Collections, System.SysUtils, System.Threading;

type
  TDownloadResult = record
    URL: string;
    Content: string;
    DownloadException: Exception;
  end;

  TOnBatchDownloadComplete = reference to procedure(const Results: TArray<TDownloadResult>);

  TUrlArray = TArray<string>;
  TDownloadResultArray = TArray<TDownloadResult>;

  TApiDownloader = class
  private
    FOrchestratorTask: ITask;
  public
    // Download a single URL asynchronously
    function DownloadUrlAsync(const URL: string): IFuture<string>;
    // Download a batch of URLs
    procedure DownloadBatchAsync(const Urls: TUrlArray; OnComplete: TOnBatchDownloadComplete);
    procedure Cancel;
  end;

implementation

uses
  System.Net.HttpClient, System.Classes, DelphiMultithreadingBook.Utils;

{ TApiDownloader }

procedure TApiDownloader.Cancel;
begin
  if Assigned(FOrchestratorTask) then
    FOrchestratorTask.Cancel;
end;

function TApiDownloader.DownloadUrlAsync(const URL: string): IFuture<string>;
begin
  // The creation of the TTask is encapsulated in this method.
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
          raise Exception.CreateFmt('Failed to download %s: Status %d', [URL,
            Response.StatusCode]);
      finally
        HTTPClient.Free;
      end;
    end);
end;

procedure TApiDownloader.DownloadBatchAsync(const Urls: TUrlArray;
  OnComplete: TOnBatchDownloadComplete);
begin
  FOrchestratorTask := TTask.Run(
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

end.
