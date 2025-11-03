unit DelphiMultithreadingBook0307.MainForm;

interface

uses
  System.Classes, System.SyncObjs, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartWorkersButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartWorkersButtonClick(Sender: TObject);
  private
    FOrchestrator: TThread;
    procedure RunTask(Countdown: TCountdownEvent; TaskNumber: Integer);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.Diagnostics, System.SysUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application Started.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
  if Assigned(FOrchestrator) then
  begin
    FOrchestrator.Terminate;
  end;
end;

procedure TMainForm.RunTask(Countdown: TCountdownEvent; TaskNumber: Integer);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      WorkTime: Integer;
    begin
      // Simulate work from 1 to 4 seconds
      WorkTime := Random(3000) + 1000;
      // Use the 'TaskNumber' variable that was captured from the outer scope
      LogWrite(Format('..Worker %d: starting %d ms of work.', [TaskNumber, WorkTime]));
      Sleep(WorkTime);
      LogWrite(Format('..Worker %d: finished.', [TaskNumber]));
      // Each worker, upon finishing, decrements the count
      Countdown.Signal;
    end
  ).Start;
end;

procedure TMainForm.StartWorkersButtonClick(Sender: TObject);
const
  WORKER_COUNT = 5;
var
  Countdown: TCountdownEvent;
  i: Integer;
  Stopwatch: TStopwatch;
begin
  LogMemo.Lines.Clear;
  LogWrite(Format('> Starting %d workers...', [WORKER_COUNT]));
  StartWorkersButton.Enabled := False;
  // 1. Initialize the event with the number of workers
  Countdown := TCountdownEvent.Create(WORKER_COUNT);
  Stopwatch := TStopwatch.StartNew;
  for i := 1 to WORKER_COUNT do
  begin
    RunTask(Countdown, i);
  end;
  LogWrite('All tasks have been fired off. UI remains responsive.');
  LogWrite('Waiting for all to complete...');
  // 3. CREATE AN ORCHESTRATOR TASK TO WAIT WITHOUT BLOCKING THE UI
  FOrchestrator := TThread.CreateAnonymousThread(
    procedure
    begin
      // 4. The orchestrator thread blocks here, not the main thread
      Countdown.WaitFor;
      Stopwatch.Stop;
      // 5. After completion, notify the UI safely
      TThread.Queue(nil,
        procedure
        begin
          LogWrite('------------------------------------');
          LogWrite(Format('ALL TASKS FINISHED in %d ms.', [Stopwatch.ElapsedMilliseconds]));
          StartWorkersButton.Enabled := True;
          Countdown.Free;
          FOrchestrator := nil;
        end);
    end);
  FOrchestrator.Start;
end;

end.
