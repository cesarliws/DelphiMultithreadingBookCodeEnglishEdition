unit DelphiMultithreadingBook0503.AsyncDownloader;

interface

uses
  System.Classes;

type
  TProgressEvent = procedure(const Sender: TObject; Progress: Integer) of object;
  TCompletionEvent = procedure(const Sender: TObject; Succeeded: Boolean;
    const Text: string) of object;

  TAsyncDownloader = class
  private
    FDestroying: Boolean;
    FOnProgress: TProgressEvent;
    FOnCompletion: TCompletionEvent;
    // Reference to the anonymous thread
    FWorkerThread: TThread;
    function GetIsBusy: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure DownloadFile(const Url: string);
    procedure Cancel;
    procedure FinalizeWorker;
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
    property OnCompletion: TCompletionEvent read FOnCompletion write FOnCompletion;
    property IsBusy: Boolean read GetIsBusy;
  end;

  THttpClient = class
  public
    class function Get(const Url: string): string; static;
  end;

implementation

uses
  System.SysUtils, DelphiMultithreadingBook.Utils;

{ TAsyncDownloader }

constructor TAsyncDownloader.Create;
begin
  inherited Create;
  FWorkerThread := nil;
end;

destructor TAsyncDownloader.Destroy;
begin
  // We use FDestroying here because this object is not a TComponent
  // to check for "csDestroying in ComponentState".
  FDestroying := True;
  FinalizeWorker;
  inherited;
end;

function TAsyncDownloader.GetIsBusy: Boolean;
begin
  // The "busy" check remains the same
  Result := Assigned(FWorkerThread) and (not FWorkerThread.Finished);
end;
procedure TAsyncDownloader.DownloadFile(const Url: string);
var
  CurrentUrl: string;
begin
  if IsBusy then
  begin
    raise Exception.Create('Downloader is already busy.');
  end;

  FinalizeWorker;
   // Copy to a local variable for use in the closure
  CurrentUrl := Url;
  FWorkerThread := TThread.CreateAnonymousThread(
    // Anonymous method that will be executed in the thread
    procedure
    var
      i: Integer;
      Cancelled: Boolean;
    begin
      DebugLogWrite('Downloader: Starting download of "%s"...', [CurrentUrl]);
      try
        Cancelled := False;
        // Simulates download progress
        for i := 0 to 99 do
        begin
          // Checks if the thread has been requested to terminate
          // or if cancellation was requested
          if TThread.CheckTerminated then
          begin
            Cancelled := True;
            DebugLogWrite('Downloader: Canceled or Terminated.');
            Break;
          end;
          // TODO : Implement Download with the real THttpClient class
          THttpClient.Get(Format('%s?part=%d', [CurrentUrl, i]));
          // Report progress via callback (on the main thread)
          TThread.Queue(nil,
            procedure
            begin
              // 'Self' here is the TAsyncDownloader
              if Assigned(Self.FOnProgress) then
                Self.FOnProgress(Self, i);
            end);
        end;
        // Notify completion (success or cancellation)
        if Assigned(Self.FOnCompletion) and not FDestroying then
        begin
          TThread.Queue(nil,
            procedure
            begin
              // The 'Cancelled' flag is necessary here because inside a Queue,
              // TThread.CurrentThread refers to the MainThread,
              // and no longer to our worker thread.
              if Cancelled then
                Self.FOnCompletion(Self, False, 'Download canceled.')
              else
                Self.FOnCompletion(Self, True, Format('Download of %s completed successfully!',
                  [CurrentUrl]));
            end);
        end;
      except
        on E: Exception do
        begin
          DebugLogWrite('Downloader: Unexpected error: %s', [E.Message]);
          TThread.Queue(nil,
            procedure
            begin
              if Assigned(Self.FOnCompletion) then
                Self.FOnCompletion(Self, False, Format('Error in download: %s', [E.Message]));
            end);
        end;
      end;
      DebugLogWrite('Downloader: Download thread finished.');
    end);
  // Manual management (FreeOnTerminate = False) to ensure that
  // we can safely call WaitFor in the TAsyncDownloader destructor.
  FWorkerThread.FreeOnTerminate := False;
  // Start the thread
  FWorkerThread.Start;
end;

procedure TAsyncDownloader.Cancel;
begin
  if Assigned(FWorkerThread) then
  begin
    FWorkerThread.Terminate;
  end;
end;

procedure TAsyncDownloader.FinalizeWorker;
begin
  if Assigned(FWorkerThread) then
  begin
    FWorkerThread.Terminate;
    FWorkerThread.WaitFor;
    FWorkerThread.Free;
  end;
end;

{ THttpClient }

class function THttpClient.Get(const Url: string): string;
begin
  // Simulates download time
  Sleep(50 + Random(250));
  Result := Format('[200] - OK: %s', [Url]);
end;

end.
