unit DelphiMultithreadingBook0301.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    StartThreadsWithCriticalSectionButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartThreadsWithCriticalSectionButtonClick(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.SyncObjs, System.SysUtils, DelphiMultithreadingBook0301.SharedData,
  DelphiMultithreadingBook0301.WorkerThread, DelphiMultithreadingBook.Utils;

{$R *.dfm}

const
  NUM_THREADS = 5;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started. Click the buttons to start the threads.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
end;

procedure TMainForm.StartThreadsWithCriticalSectionButtonClick(
  Sender: TObject);
var
  i: Integer;
begin
  LogWrite('> Starting 5 threads. Wait for the execution to finish in the LogMemo...');
  // Clear the shared list before starting
  SharedStringListCriticalSection.Enter;
  try
    SharedStringList.Clear;
  finally
    SharedStringListCriticalSection.Leave;
  end;
  // Create and start 5 threads that will access the SharedStringList
  for i := 1 to NUM_THREADS do
    TWorkerThread.Create(i, 20);
  // The anonymous thread below acts as a "reporter" that will display the final result.
  TThread.CreateAnonymousThread(
    procedure
    begin
      // This Sleep(2000) has a specific didactic purpose: it pauses this reporter thread
      // to give the worker threads enough time to start and begin competing for access to
      // the SharedStringList.

      // WARNING: Sleep is NOT a safe way to guarantee the COMPLETION of
      // threads. It only creates a time window for concurrency to occur
      // in this example. The robust way to wait for the completion of
      // multiple tasks will be seen in future topics,
      // with TCountdownEvent (3.7) and TTask.WaitForAll (6.4).
      Sleep(2000);

      TThread.Queue(nil,
        procedure
        var
          s: string;
        begin
          LogWrite('');
          LogWrite('----- Start of SharedStringList Log -----');
          // Protects access to the list for reading
          SharedStringListCriticalSection.Enter;
          try
            for s in SharedStringList do
            begin
              LogWrite(s);
            end;
            LogWrite('Total items in list: %d', [SharedStringList.Count]);
          finally
            SharedStringListCriticalSection.Leave;
          end;
          LogWrite('----------------------------------------');
        end);
    end).Start;
end;

end.
