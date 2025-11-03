unit DelphiMultithreadingBook0203.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    LogMemo: TMemo;
    StartWithoutSyncButton: TButton;
    StartWithSyncButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartWithoutSyncButtonClick(Sender: TObject);
    procedure StartWithSyncButtonClick(Sender: TObject);
  private
    FOrchestratorThread: TThread;
    procedure FinalizeThread;
    procedure RunTest(UseLocking: Boolean);
    procedure SetButtonStates(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.Diagnostics, System.SysUtils,
  DelphiMultithreadingBook0203.SharedData,
  DelphiMultithreadingBook0203.WorkerThread;

{$R *.dfm}

type
  // Definition of the Orchestrator Thread
  TTestOrchestratorThread = class(TThread)
  private
    FUseLocking: Boolean;
  public
    constructor Create(UseLocking: Boolean);
    procedure Execute; override;
  end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FinalizeThread;
  UnregisterLogger;
end;

procedure TMainForm.FinalizeThread;
begin
  if Assigned(FOrchestratorThread) then
  begin
    FOrchestratorThread.Terminate;
    FOrchestratorThread.WaitFor;
    FOrchestratorThread.Free;
    FOrchestratorThread := nil;
  end;
end;

procedure TMainForm.RunTest(UseLocking: Boolean);
begin
  FinalizeThread;
  SetButtonStates(IsRunning);
  GlobalCounter := 0;
  if UseLocking then
    LogWrite('--- Starting Test WITH Synchronization ---')
  else
    LogWrite('--- Starting Test WITHOUT Synchronization (Expected to Fail) ---');
  // Creates and starts the orchestrator thread
  FOrchestratorThread := TTestOrchestratorThread.Create(UseLocking);
end;

procedure TMainForm.StartWithSyncButtonClick(Sender: TObject);
begin
  RunTest(True);
end;

procedure TMainForm.StartWithoutSyncButtonClick(Sender: TObject);
begin
  RunTest(False);
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  StartWithSyncButton.Enabled := RunningState = IsStopped;
  StartWithoutSyncButton.Enabled := RunningState = IsStopped;
  Repaint;
end;

{ TTestOrchestratorThread }

constructor TTestOrchestratorThread.Create(UseLocking: Boolean);
begin
  // Starts immediately
  inherited Create(False);
  FreeOnTerminate := False;
  FUseLocking := UseLocking;
end;

procedure TTestOrchestratorThread.Execute;
const
  NUM_THREADS = 10;
  INCREMENTS_PER_THREAD = 100000;
var
  i: Integer;
  Stopwatch: TStopwatch;
  Threads: TArray<TWorkerThread>;
begin
  Stopwatch := TStopwatch.StartNew;
  SetLength(Threads, NUM_THREADS);
  try
    // Creates and starts all worker threads
    for i := 0 to High(Threads) do
    begin
      if Terminated then Exit;
      Threads[i] := TWorkerThread.Create(FUseLocking, INCREMENTS_PER_THREAD);
      Threads[i].Start;
    end;
    // Waits for all threads to finish
    for i := 0 to High(Threads) do
    begin
      // Allows the orchestrator itself to be canceled
      if Terminated then
        Exit;
      Threads[i].WaitFor;
    end;
  finally
    // Ensures the worker threads are freed
    for i := 0 to High(Threads) do
      Threads[i].Free;
  end;
  Stopwatch.Stop;
  // Sends the final result to the UI safely
  TThread.Queue(nil,
    procedure
    var
      ExpectedResult: Integer;
    begin
      ExpectedResult := NUM_THREADS * INCREMENTS_PER_THREAD;
      LogWrite('Completed. Final value: %d (Expected: %d)', [GlobalCounter, ExpectedResult]);

      if GlobalCounter <> ExpectedResult then
        LogWrite('>>> A RACE CONDITION OCCURRED! <<<')
      else
        LogWrite('>>> Correct result! <<<');

      LogWrite('Execution time: %s ms', [Stopwatch.ElapsedMilliseconds.ToString]);
      MainForm.SetButtonStates(IsStopped);
    end);
end;

end.
