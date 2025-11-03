unit DelphiMultithreadingBook0304.MainForm;

interface

uses
  System.Classes,  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    StartThreadsWithSemaphoreButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartThreadsWithSemaphoreButtonClick(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  DelphiMultithreadingBook0304.SharedData,
  DelphiMultithreadingBook0304.WorkerThread,
  DelphiMultithreadingBook.Utils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started. Click the buttons to start the threads.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
end;

procedure TMainForm.StartThreadsWithSemaphoreButtonClick(Sender: TObject);
var
  i: Integer;
begin
  LogWrite('> Starting 10 Threads with Semaphore (limit 3 simultaneous)...');
  // Create 10 threads, all will try to acquire a permit from the semaphore
  for i := 1 to 10 do
  begin
    // Create worker thread
    TWorkerThread.Create(i, LogWrite);
  end;
  LogWrite('Check the Delphi Messages window for the Semaphore effects.');
  LogWrite('Only 3 threads should process simultaneously.');
end;

end.
