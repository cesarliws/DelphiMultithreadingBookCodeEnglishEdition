unit DelphiMultithreadingBook0906.MainForm;

interface

uses
  FMX.Controls, FMX.Controls.Presentation, FMX.Forms, FMX.Layouts, FMX.Memo, FMX.Memo.Types,
  FMX.ScrollBox, FMX.StdCtrls, FMX.Types, System.Classes, System.Threading,
  DelphiMultithreadingBook.Utils, DelphiMultithreadingBook0906.ApiDownloader;

type
  TMainForm = class(TForm)
    LogMemo: TMemo;
    Layout: TLayout;
    StartAPIDownloadButton: TButton;
    CancelDownloadsButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartAPIDownloadButtonClick(Sender: TObject);
    procedure CancelDownloadsButtonClick(Sender: TObject);
  private
    FDownloader: TApiDownloader;
    procedure SetButtonStates(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  System.SysUtils, System.Diagnostics, System.Generics.Collections;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // Ensures any ongoing operation is canceled
  if Assigned(FDownloader) then
    FDownloader.Cancel;
  UnregisterLogger;
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  if csDestroying in ComponentState then
    Exit;
  StartAPIDownloadButton.Enabled := RunningState = IsStopped;
  CancelDownloadsButton.Enabled := RunningState = IsRunning;
end;

procedure TMainForm.StartAPIDownloadButtonClick(Sender: TObject);
var
  UrlsToDownload: TArray<string>;
  Stopwatch: TStopwatch;
begin
  if Assigned(FDownloader) then
  begin
    LogWrite('Please wait for the previous downloads to finish.');
    Exit;
  end;

  LogWrite('> Starting parallel download of APIs...');
  SetButtonStates(IsRunning);

  UrlsToDownload := [
    // Financial APIs (JSON) - Fast
    'https://api.coinbase.com/v2/exchange-rates?currency=BTC',
    'https://economia.awesomeapi.com.br/json/last/USD-BRL',
    'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd',
    // Info/Fun APIs (JSON) - Fast
    'https://api.github.com/users/octocat',
    'https://catfact.ninja/fact',
    'https://official-joke-api.appspot.com/random_joke',
    // Text File (Larger) - Potentially slower
    'https://www.gutenberg.org/files/2701/2701-0.txt', // Moby Dick
    // URL to simulate failure
    'https://invalid-url-for-testing.fail'];

  Stopwatch := TStopwatch.StartNew;
  FDownloader := TApiDownloader.Create;
  FDownloader.DownloadBatchAsync(UrlsToDownload,
    // 'OnComplete' Callback - This code will run on the UI Thread
    procedure(const Results: TArray<TDownloadResult>)
    var
      ResultItem: TDownloadResult;
    begin
      LogWrite('--- Parallel Download Results ---');
      for ResultItem in Results do
      begin
        if Assigned(ResultItem.DownloadException) then
        begin
          LogWrite('[FAIL] %s: %s', [ResultItem.URL, ResultItem.DownloadException.Message]);
          // Free the exception that was captured with AcquireExceptionObject
          ResultItem.DownloadException.Free;
        end
        else
        begin
          LogWrite('[OK] %s: Completed (%d bytes)', [ResultItem.URL, Length(ResultItem.Content)]);
          LogWrite('- Response received (first 100 characters):');
          LogWrite('- "' + Copy(ResultItem.Content, 1, 100) + '..."');
        end;
      end;

      Stopwatch.Stop;
      LogWrite('Total time: %d ms.', [Stopwatch.ElapsedMilliseconds]);
      LogWrite('-----------------------------------');
      SetButtonStates(IsStopped);
      FDownloader.Free; // Free the downloader
      FDownloader := nil;
    end);

  LogWrite('Requests dispatched for %d URLs. UI remains responsive.', [Length(UrlsToDownload)]);
end;

procedure TMainForm.CancelDownloadsButtonClick(Sender: TObject);
begin
  if Assigned(FDownloader) then
  begin
    LogWrite('Requesting cancellation of downloads...');
    FDownloader.Cancel;
  end;
end;

end.
