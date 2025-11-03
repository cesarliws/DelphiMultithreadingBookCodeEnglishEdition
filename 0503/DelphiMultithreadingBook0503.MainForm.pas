unit DelphiMultithreadingBook0503.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0503.AsyncDownloader, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartAsyncDownloadButton: TButton;
    CancelDownloadButton: TButton;
    LogMemo: TMemo;
    procedure CancelDownloadButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartAsyncDownloadButtonClick(Sender: TObject);
  private
    // Instance of our downloader
    FDownloader: TAsyncDownloader;
    procedure DownloaderProgress(const Sender: TObject; Progress: Integer);
    procedure DownloaderComplete(const Sender: TObject; Succeeded: Boolean; const Text: string);
    procedure FinalizeDownloader;
    procedure SetButtonsState(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.UITypes;

procedure TMainForm.CancelDownloadButtonClick(Sender: TObject);
begin
  if Assigned(FDownloader) then
  begin
    FDownloader.Cancel;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  LogWrite('Click the button to start the Asynchronous Download.');
  FDownloader := TAsyncDownloader.Create;
  FDownloader.OnProgress := DownloaderProgress;
  FDownloader.OnCompletion := DownloaderComplete;
  LogMemo.ScrollBars := TScrollStyle.ssVertical;
  SetButtonsState(IsStopped);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FinalizeDownloader;
  UnregisterLogger;
end;

procedure TMainForm.StartAsyncDownloadButtonClick(Sender: TObject);
begin
  if not FDownloader.IsBusy then
  begin
    LogWrite('> Starting download...');
    // Disable while busy
    SetButtonsState(IsRunning);
    // Example URL, which can be changed as needed.
    FDownloader.DownloadFile('http://example.com/bigfile.zip');
  end
  else
  begin
    LogWrite('Downloader is already busy. Please wait or restart the application.');
  end;
end;

procedure TMainForm.SetButtonsState(RunningState: TRunningState);
begin
  if csDestroying in ComponentState then
    Exit;
  StartAsyncDownloadButton.Enabled := RunningState = IsStopped;
  CancelDownloadButton.Enabled := RunningState = IsRunning;
end;

procedure TMainForm.DownloaderProgress(const Sender: TObject; Progress: Integer);
begin
  LogWrite('Download: %d%% complete.', [Progress]);
end;

procedure TMainForm.DownloaderComplete(const Sender: TObject; Succeeded:
  Boolean; const Text: string);
begin
  LogWrite(Text);
  SetButtonsState(IsStopped);
end;

procedure TMainForm.FinalizeDownloader;
begin
  if Assigned(FDownloader) then
  begin
    FDownloader.Free;
    FDownloader := nil;
  end;
end;

end.
