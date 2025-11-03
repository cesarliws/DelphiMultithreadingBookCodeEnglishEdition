unit DelphiMultithreadingBook0302.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls;

type
  // To avoid collision with Vcl.Forms.TMonitor
  TMonitor = System.TMonitor;

  TMainForm = class(TForm)
    StartThreadsWithMonitorButton: TButton;
    LogMemo: TMemo;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StartThreadsWithMonitorButtonClick(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils, DelphiMultithreadingBook0302.SharedData,
  DelphiMultithreadingBook0302.WorkerThread, DelphiMultithreadingBook.Utils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started. Click the buttons to start the threads.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
end;

procedure TMainForm.StartThreadsWithMonitorButtonClick(Sender: TObject);
var
  i: Integer;
begin
  LogWrite('> Starting 5 Threads with TMonitor...');
  // Clear the list protected by the TMonitor
  // Protects access to the list for clearing
  TMonitor.Enter(SharedStringList);
  try
    SharedStringList.Clear;
  finally
    TMonitor.Exit(SharedStringList);
  end;

  // Creates and starts 5 threads that will access the SharedStringList
  for i := 1 to 5 do
  begin
    // Creates 5 threads, each adding 20 items
    TWorkerThread.Create(i, 20);
  end;

  // Adds a thread to show the final result of the list after a delay
  TThread.CreateAnonymousThread(
    procedure
    begin
      // The following Sleep has a didactic purpose: it pauses this "reporter"
      // thread to give enough time for the worker threads (TWorkerThread)
      // to execute and for resource contention to occur.
      // In a real application, the correct way to wait for the completion
      // of multiple tasks would be to use synchronization primitives like
      // TCountdownEvent (Topic 3.7) and `TTask.WaitForAll` (**Topic 6.4**).
      Sleep(2000);
      TThread.Queue(nil,
        procedure
        var
          s: string;
        begin
          LogWrite('');
          LogWrite('--- Final content of SharedStringList (TMonitor) ---');
          // Protects access to the list for reading
          TMonitor.Enter(SharedStringList);
          try
            for s in SharedStringList do
            begin
              LogWrite(s);
            end;
            LogWrite('Total items in list: %d', [SharedStringList.Count]);
          finally
            TMonitor.Exit(SharedStringList);
          end;
          LogWrite('----------------------------------------');
        end
      );
    end
  ).Start;
end;

end.
