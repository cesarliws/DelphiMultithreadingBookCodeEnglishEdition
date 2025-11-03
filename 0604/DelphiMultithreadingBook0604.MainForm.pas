unit DelphiMultithreadingBook0604.MainForm;

interface

uses
  System.Classes, System.Threading, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    WaitForAllButton: TButton;
    WaitForAnyButton: TButton;
    ParallelJoinButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure WaitForAllButtonClick(Sender: TObject);
    procedure WaitForAnyButtonClick(Sender: TObject);
    procedure ParallelJoinButtonClick(Sender: TObject);
  private
    FOrchestrator: ITask;
    procedure SetButtonsState(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.Diagnostics, System.SyncObjs, System.SysUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  Height := 160;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Assigned(FOrchestrator);
  if not CanClose then
  begin
    LogWrite('* Wait for the Task to finish before closing this Window!')
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
end;

procedure TMainForm.WaitForAllButtonClick(Sender: TObject);
var
  Stopwatch: TStopwatch;
  Tasks: array of ITask;
  TotalValue: Integer;
begin
  LogWrite('--- TTask.WaitForAll Test ---');
  SetButtonsState(IsRunning);
  Stopwatch := TStopwatch.StartNew;
  TotalValue := 0;
  // Create two tasks that simulate work and modify a shared variable
  SetLength(Tasks, 2);
  Tasks[0] := TTask.Run(
    procedure
    begin
      DebugLogWrite('Task 1: Starting (3 seconds)...');
      // 3 seconds
      Sleep(3000);
      // Add value (simulated, see Topic 7.2)
      TInterlocked.Add(TotalValue, 3000);
      DebugLogWrite('Task 1: Completed.');
    end);

  Tasks[1] := TTask.Run(
    procedure
    begin
      DebugLogWrite('Task 2: Starting (5 seconds)...');
      // 5 seconds
      Sleep(5000);
      // Add value (simulated, see Topic 7.2)
      TInterlocked.Add(TotalValue, 5000);
      DebugLogWrite('Task 2: Completed.');
    end);

  FOrchestrator := TTask.Run(
    procedure
    var
      ExceptionMessage: string;
    begin
      try
        // Wait for all tasks to finish without blocking the UI
        TTask.WaitForAll(Tasks);
        Stopwatch.Stop;
        // The result is queued for the UI
        TThread.Queue(nil,
          procedure
          begin
            LogWrite('WaitForAll completed in %d ms. Total value: %d.',
              [Stopwatch.ElapsedMilliseconds, TotalValue]);
            SetButtonsState(IsStopped);
          end);
      except
        on E: Exception do
        begin
          Stopwatch.Stop;
          ExceptionMessage := E.ToString;
          TThread.Queue(nil,
            procedure
            begin
              LogWrite('WaitForAll failed: %s', [ExceptionMessage]);
              SetButtonsState(IsStopped);
            end);
        end;
      end;
      SetLength(Tasks, 0);
      FOrchestrator := nil;
    end);
  LogWrite('Tasks launched. The UI remains responsive while waiting...');
end;

procedure TMainForm.WaitForAnyButtonClick(Sender: TObject);

  function CreateTask(TaskIndex: Integer): ITask;
  begin
    Result := TTask.Run(
      procedure
      begin
        LogWrite('Task %d: Starting...', [TaskIndex]);
        // Random duration (0.5s to 1.5s)
        Sleep(Random(1000) + 500);
        // Simulate failure in Task 1 (50% chance)
        if (TaskIndex = 1) and (Random(2) = 0) then
        begin
          LogWrite('Task %d: Raising simulated exception!', [TaskIndex]);
          raise Exception.CreateFmt('Simulated error in Task %d', [TaskIndex]);
        end;
        LogWrite('Task %d: Completed.', [TaskIndex]);
      end);
  end;
var
  CompletedIndex: Integer;
  i: Integer;
  Stopwatch: TStopwatch;
  Tasks: array of ITask;
begin
  LogWrite('--- TTask.WaitForAny Test ---');
  SetButtonsState(IsRunning);
  Stopwatch := TStopwatch.StartNew;

  SetLength(Tasks, 3);
  for i := 0 to High(Tasks) do
  begin
    // The ITask is created in a function to ensure that the anonymous method of each task
    // captures the correct value (0, 1, 2), instead of all of them seeing the final value of 'i'
    Tasks[i] := CreateTask(i);
  end;

  FOrchestrator := TTask.Run(
    procedure
    var
      ExceptionMessage: string;
    begin
      // Wait for any task to finish
      try
        // Waits for any task without blocking the UI
        CompletedIndex := TTask.WaitForAny(Tasks);
        Stopwatch.Stop;

        TThread.Queue(nil,
          procedure
          begin
            if CompletedIndex <> -1 then
              LogWrite('WaitForAny: Task %d completed in %d ms.',
                [CompletedIndex, Stopwatch.ElapsedMilliseconds])
            else
              LogWrite('WaitForAny: No task completed within the timeout in %d ms.',
                [Stopwatch.ElapsedMilliseconds]);
          end);
      except
        on E: Exception do
        begin
          Stopwatch.Stop;
          ExceptionMessage := E.ToString;
          TThread.Queue(nil,
            procedure
            begin
              LogWrite('WaitForAny failed in %d ms: %s',
                [Stopwatch.ElapsedMilliseconds, ExceptionMessage]);
            end);
        end;
      end;

      try
        // Wait for all remaining tasks to ensure cleanup
        TTask.WaitForAll(Tasks);
      except on
        E: Exception do
        begin
          ExceptionMessage := E.ToString;

          TThread.Queue(nil,
            procedure
            begin
              LogWrite('WaitForAny failed in %d ms: %s',
                [Stopwatch.ElapsedMilliseconds, ExceptionMessage]);
            end);
        end;
      end;

      TThread.Queue(nil,
        procedure
        begin
          SetButtonsState(IsStopped);
        end);
      SetLength(Tasks, 0);
      FOrchestrator := nil;
    end);
  LogWrite('Tasks launched. The UI remains responsive while waiting...');
end;

procedure TMainForm.ParallelJoinButtonClick(Sender: TObject);
var
  JoinTask: ITask;
  Stopwatch: TStopwatch;
begin
  LogWrite('--- TParallel.Join Test ---');
  SetButtonsState(IsRunning);
  Stopwatch := TStopwatch.StartNew;
  // Creates and starts a task that groups three procedures in parallel
  JoinTask := TParallel.Join([
    // Procedure 1
    procedure
    begin
      DebugLogWrite('Join Task 1: Starting (2 seconds)...');
      Sleep(2000);
      DebugLogWrite('Join Task 1: Completed.');
    end,
    // Procedure 2
    procedure
    begin
      DebugLogWrite('Join Task 2: Starting (4 seconds)...');
      Sleep(4000);
      DebugLogWrite('Join Task 2: Completed.');
    end,
    // Procedure 3
    procedure
    begin
      DebugLogWrite('Join Task 3: Starting (1 second)...');
      Sleep(1000);
      DebugLogWrite('Join Task 3: Completed.');
    end
  ]);

  FOrchestrator := TTask.Run(
    procedure
    var
      ExceptionMessage: string;
    begin
      // Waits for the completion of the JoinTask
      // (which only finishes when all internal procedures have finished)
      try
        // Blocks this worker thread until all join tasks have finished
        JoinTask.Wait;
        Stopwatch.Stop;

        TThread.Queue(nil,
          procedure
          begin
            LogWrite('TParallel.Join completed in %d ms. (Expected: ~4000ms)',
              [Stopwatch.ElapsedMilliseconds]);
          end);
      except
        on E: EAggregateException do
        begin
          Stopwatch.Stop;
          ExceptionMessage := E.ToString;
          TThread.Queue(nil,
            procedure
            begin
              LogWrite('TParallel.Join failed with aggregate exception in %d ms: %s',
                [Stopwatch.ElapsedMilliseconds, ExceptionMessage]);
            end);
        end;
      end;

      TThread.Queue(nil,
        procedure
        begin
          SetButtonsState(IsStopped);
        end);
      JoinTask := nil;
      FOrchestrator := nil;
    end);
  // The main thread can do other things here.
  LogWrite('TParallel.Join launched!');
end;

procedure TMainForm.SetButtonsState(RunningState: TRunningState);
begin
  if csDestroying in ComponentState then
    Exit;

  WaitForAllButton.Enabled := RunningState = IsStopped;
  WaitForAnyButton.Enabled := RunningState = IsStopped;
  ParallelJoinButton.Enabled := RunningState = IsStopped;
end;

end.
