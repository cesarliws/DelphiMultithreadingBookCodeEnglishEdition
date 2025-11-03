unit DelphiMultithreadingBook0704.MainForm;

interface

uses
  System.Classes, System.SysUtils, System.Threading, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartDefaultPoolButton: TButton;
    StartCustomPoolButton: TButton;
    CancelButton: TButton;
    LogMemo: TMemo;
    StatsLabel: TLabel;
    StatsTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartDefaultPoolButtonClick(Sender: TObject);
    procedure StartCustomPoolButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure StatsTimerTimer(Sender: TObject);
  private
    FCurrentMonitoringPool: TThreadPool;
    FCustomPool: TThreadPool;
    FProcessingTask: ITask;
    procedure RunTest(Pool: TThreadPool; const Title: string);
    procedure SetButtonsEnabled(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.Diagnostics,
  System.SyncObjs;

const
  NUM_FILES = 50;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Run the tests more than once, the first time the pool will be created.');
  SetButtonsEnabled(IsStopped);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
  if Assigned(FProcessingTask) then
    FProcessingTask.Cancel;
  // The default pool is managed by the RTL. We only free ours.
  if Assigned(FCustomPool) then
    FCustomPool.Free;
end;

procedure TMainForm.StartCustomPoolButtonClick(Sender: TObject);
begin
  if not Assigned(FCustomPool) then
  begin
    LogWrite('Creating custom thread pool with 2 workers...');
    FCustomPool := TThreadPool.Create;
    FCustomPool.SetMinWorkerThreads(2);
    FCustomPool.SetMaxWorkerThreads(2);
  end;
  RunTest(FCustomPool, '> Starting test with Limited Pool (2 Threads)');
end;

procedure TMainForm.StartDefaultPoolButtonClick(Sender: TObject);
begin
  RunTest(TThreadPool.Default, '> Starting test with Default Pool');
end;

procedure TMainForm.CancelButtonClick(Sender: TObject);
begin
  if Assigned(FProcessingTask) then
  begin
    LogWrite('Requesting cancellation...');
    FProcessingTask.Cancel;
  end;
end;

procedure TMainForm.StatsTimerTimer(Sender: TObject);
var
  ActiveThreads: Integer;
  Stats: TThreadPoolStats;
begin
  if Assigned(FCurrentMonitoringPool) then
  begin
    Stats := TThreadPoolStats.Get(FCurrentMonitoringPool);
    ActiveThreads := Stats.WorkerThreadCount - Stats.IdleWorkerThreadCount;
    StatsLabel.Caption := Format(
      'Pool Stats | Active: %d | Idle: %d | Queued: %d | Total: %d', [
      ActiveThreads,
      Stats.IdleWorkerThreadCount,
      Stats.QueuedRequestCount,
      Stats.WorkerThreadCount]);
  end;
end;

procedure TMainForm.RunTest(Pool: TThreadPool; const Title: string);
var
  Stopwatch: TStopwatch;
  ProcessedCount: Integer;
begin
  if Assigned(FProcessingTask) then
    Exit;
  LogWrite(Title);
  SetButtonsEnabled(IsRunning);
  FCurrentMonitoringPool := Pool;
  StatsTimer.Enabled := True;
  Stopwatch := TStopwatch.StartNew;
  ProcessedCount := 0;

  FProcessingTask := TTask.Run(
    procedure
    begin
      try
        // Main work block
        TParallel.For(1, NUM_FILES,
          procedure(Index: Integer; State: TParallel.TLoopState)
          begin
            // Allows cancellation
            FProcessingTask.CheckCanceled;
            Sleep(100 + Random(200));
            TInterlocked.Increment(ProcessedCount);
          end);
      finally
        // This block will ALWAYS be executed, ensuring UI update.
        Stopwatch.Stop;
        TThread.Queue(nil,
          procedure
          begin
            // Checks the final task status to log the correct result
            if FProcessingTask.Status = TTaskStatus.Canceled then
              LogWrite('Canceled after processing %d files.', [ProcessedCount])
            else if FProcessingTask.Status = TTaskStatus.Exception then
              LogWrite('Task failed after %d ms.', [Stopwatch.ElapsedMilliseconds])
            else
              LogWrite('Completed! Processed %d files in %d ms.',
                [ProcessedCount, Stopwatch.ElapsedMilliseconds]);
            // Final UI cleanup
            SetButtonsEnabled(IsStopped);
            StatsTimer.Enabled := False;
            StatsLabel.Caption := 'Pool Statistics: -';
            FProcessingTask := nil;
          end);
      end;
    end, Pool);
end;

procedure TMainForm.SetButtonsEnabled(RunningState: TRunningState);
begin
  StartDefaultPoolButton.Enabled := RunningState = IsStopped;
  StartCustomPoolButton.Enabled := RunningState = IsStopped;
  CancelButton.Enabled := RunningState = IsRunning;
end;

end.