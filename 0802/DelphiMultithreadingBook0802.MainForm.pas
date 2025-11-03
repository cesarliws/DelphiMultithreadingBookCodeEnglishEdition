unit DelphiMultithreadingBook0802.MainForm;

interface

uses
  System.Classes, System.Threading, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0802.Worker, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartNoSyncButton: TButton;
    StartCriticalSectionButton: TButton;
    StartThreadVarButton: TButton;
    LogMemo: TMemo;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartNoSyncButtonClick(Sender: TObject);
    procedure StartCriticalSectionButtonClick(Sender: TObject);
    procedure StartThreadVarButtonClick(Sender: TObject);
  private
    // Field to control the currently running test task
    FCurrentTestTask: ITask;
    procedure RunTestAsync(Mode: TExecutionMode; const Title: string);
    procedure SetButtonStates(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.Diagnostics, System.SysUtils, DelphiMultithreadingBook0802.SharedData;

const
  NUM_THREADS = 10;
  INCREMENTS_PER_THREAD = 1000000;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Assigned(FCurrentTestTask);
  if not CanClose then
  begin
    LogWrite('* Please wait for the Task to finish before closing this window!');
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
end;

procedure TMainForm.StartCriticalSectionButtonClick(Sender: TObject);
begin
  RunTestAsync(emCriticalSection, 'Starting Test with TCriticalSection');
end;

procedure TMainForm.StartNoSyncButtonClick(Sender: TObject);
begin
  RunTestAsync(emNoSync, 'Starting Test WITHOUT Synchronization (Expected to Fail)');
end;

procedure TMainForm.StartThreadVarButtonClick(Sender: TObject);
begin
  RunTestAsync(emThreadVar, 'Starting Test with threadvar (Optimized)');
end;

procedure TMainForm.RunTestAsync(Mode: TExecutionMode; const Title: string);
begin
  if Assigned(FCurrentTestTask) then
  begin
    LogWrite('!!! A test is already running. Please wait. !!!');
    Exit;
  end;
  LogWrite('--- ' + Title + ' ---');
  SetButtonStates(IsRunning);
  // Reset the counters
  GlobalCounter := 0;
  FinalGlobalCounter := 0;
  // Run the test in a Task (see Chapter 6) to avoid blocking the UI
  FCurrentTestTask := TTask.Run(
    procedure
    var
      i: Integer;
      ExpectedResult: Int64;
      Stopwatch: TStopwatch;
      Threads: TArray<TWorker>;
      FinalValue: Int64;
      ModeResult: TExecutionMode;
    begin
      Stopwatch := TStopwatch.StartNew;
      SetLength(Threads, NUM_THREADS);
      try
        // Create and start the threads
        for i := 0 to High(Threads) do
        begin
          Threads[i] := TWorker.Create(Mode, INCREMENTS_PER_THREAD);
          Threads[i].Start;
        end;

        // Wait for all to finish (this happens in the PPL thread, not the UI thread)
        for i := 0 to High(Threads) do
          Threads[i].WaitFor;

      finally
        // Free the TThread objects
        for i := 0 to High(Threads) do
          Threads[i].Free;
      end;

      Stopwatch.Stop;

      // Prepare the results to send to the UI
      ExpectedResult := NUM_THREADS * INCREMENTS_PER_THREAD;
      ModeResult := Mode;
      if Mode = emThreadVar then
        FinalValue := FinalGlobalCounter
      else
        FinalValue := GlobalCounter;

      // Send the final result to the UI safely
      TThread.Queue(nil,
        procedure
        begin
          // Protection in case the form is closed while the task is running
          if csDestroying in ComponentState then
            Exit;

          if ModeResult = emThreadVar then
          begin
            LogWrite('Completed. Final value: %d (Expected: %d)', [FinalValue, ExpectedResult]);
            if FinalValue <> ExpectedResult then
              LogWrite('>>> A LOGIC ERROR OCCURRED! <<<')
            else
              LogWrite('>>> Correct result! <<<');
          end
          else
          begin
            LogWrite('Completed. Final value: %d (Expected: %d)', [FinalValue, ExpectedResult]);
            if FinalValue <> ExpectedResult then
              LogWrite('>>> A RACE CONDITION OCCURRED! <<<')
            else
              LogWrite('>>> Correct result! <<<');
          end;
          LogWrite('Execution time: %d ms%s', [Stopwatch.ElapsedMilliseconds, sLineBreak]);
          // Clear the task reference and re-enable the buttons
          FCurrentTestTask := nil;
          SetButtonStates(IsStopped);
        end);
    end);
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  StartNoSyncButton.Enabled := RunningState = IsStopped;
  StartCriticalSectionButton.Enabled := RunningState = IsStopped;
  StartThreadVarButton.Enabled := RunningState = IsStopped;
  Repaint;
end;

end.
