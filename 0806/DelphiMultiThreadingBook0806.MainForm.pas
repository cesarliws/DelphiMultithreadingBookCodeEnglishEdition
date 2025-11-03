unit DelphiMultithreadingBook0806.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    StartCodeSiteThreadButton: TButton;
    LogMemo: TMemo;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StartCodeSiteThreadButtonClick(Sender: TObject);
  private
    procedure WorkerThreadTerminate(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  DelphiMultithreadingBook0806.LoggingThread, DelphiMultithreadingBook.Utils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  LogWrite('Start the CodeSite Live Viewer from the menu:');
  LogWrite('> Tools > CodeSite > CodeSite Live Viewer.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
end;

procedure TMainForm.StartCodeSiteThreadButtonClick(Sender: TObject);
var
  WorkerThread: TLoggingThread;
begin
  LogWrite('> Starting 3 Threads with CodeSite Logging...');

  // Create and start 3 threads, associating the handler with each.
  // Since FreeOnTerminate is True, they will free themselves.
  WorkerThread := TLoggingThread.Create;
  WorkerThread.OnTerminate := WorkerThreadTerminate;
  WorkerThread.Start;

  WorkerThread := TLoggingThread.Create;
  WorkerThread.OnTerminate := WorkerThreadTerminate;
  WorkerThread.Start;

  WorkerThread := TLoggingThread.Create;
  WorkerThread.OnTerminate := WorkerThreadTerminate;
  WorkerThread.Start;
end;

procedure TMainForm.WorkerThreadTerminate(Sender: TObject);
begin
  // This event executes in the main thread (UI Thread)
  TThread.Queue(nil,
    procedure
    begin
      LogWrite('Thread %d finished. Check the CodeSite Viewer.', [TThread(Sender).ThreadID]);
    end);
end;

end.
