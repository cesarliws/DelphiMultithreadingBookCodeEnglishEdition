unit DelphiMultithreadingBook0605.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, System.Threading,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartTaskButton: TButton;
    CancelTaskButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure StartTaskButtonClick(Sender: TObject);
    procedure CancelTaskButtonClick(Sender: TObject);
  private
    // Reference to the running task
    FCurrentTask: ITask;
    FFinalSumValue: Integer;
    procedure SetButtonStates(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils, System.TypInfo;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Assigned(FCurrentTask);
  if not CanClose then
  begin
    LogWrite('* Wait for the Task to finish before closing this Window!');
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
end;

procedure TMainForm.StartTaskButtonClick(Sender: TObject);
begin
  // Checks if there is an active and unfinished task
  if Assigned(FCurrentTask) and (FCurrentTask.Status = TTaskStatus.Running) then
  begin
    LogWrite('A task is already running.');
    Exit;
  end;

  LogWrite('> Starting long-running (cancelable) task, please wait...');
  SetButtonStates(IsRunning);
  FFinalSumValue := 0;

  FCurrentTask := TTask.Run(
    // Task body
    procedure
    var
      i, Sum: Integer;
    begin
      DebugLogWrite('PPL Task: Starting heavy calculation...');
      try
        // Very long loop
        for i := 1 to 200000000 do
        begin
          // Checks if cancellation has been requested. If yes, raises EOperationCancelled.
          TTask.CurrentTask.CheckCanceled;
          // Simulates calculation work
          Inc(Sum);
          // Optional: Sleep(1) to allow context switches and more frequent cancellation testing
          // Sleep(1);
        end;

        DebugLogWrite('PPL Task: Work completed.');
      except
        // Captures the specific PPL cancellation exception
        on E: EOperationCancelled do
        begin
          DebugLogWrite('PPL Task: Cancellation exception (EOperationCancelled) captured.');
          // Specific cleanup actions for cancellation can go here
        end;
        // Captures aggregate exceptions (if there are failing child tasks)
        on E: EAggregateException do
        begin
          DebugLogWrite('PPL Task: Aggregate error: %s', [E.ToString]);
        end;
        // Captures other unexpected exceptions
        on E: Exception do
        begin
          DebugLogWrite('PPL Task: Unexpected error: %s', [E.Message]);
        end;
      end;

      // Updates the UI after task completion
      TThread.Queue(nil,
        procedure
        begin
          if (csDestroying in ComponentState) then
            Exit;
          FFinalSumValue := Sum;
          LogWrite('Task finished. Sum = %d. Status: %s', [FFinalSumValue,
            GetEnumName(TypeInfo(TTaskStatus), Integer(FCurrentTask.Status))]);
          SetButtonStates(IsStopped);
          FCurrentTask := nil;
        end);
    end);
end;

procedure TMainForm.CancelTaskButtonClick(Sender: TObject);
begin
  // Checks if the task is active
  if Assigned(FCurrentTask) and (FCurrentTask.Status = TTaskStatus.Running) then
  begin
    LogWrite('PPL: Requesting task cancellation...');
    // Signals the cancellation to the task
    FCurrentTask.Cancel;
  end
  else
    LogWrite('PPL: No active task to cancel.');
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  StartTaskButton.Enabled := RunningState = IsStopped;
  CancelTaskButton.Enabled := RunningState = IsRunning;
end;

end.
