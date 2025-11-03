unit DelphiMultithreadingBook0602.MainForm;

interface

uses
  System.Classes, System.Threading, Vcl.Forms, Vcl.StdCtrls, Vcl.Controls,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartTaskButton: TButton;
    CalculateTaskButton: TButton;
    ForceExceptionCheckBox: TCheckBox;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure StartTaskButtonClick(Sender: TObject);
    procedure CalculateTaskButtonClick(Sender: TObject);
  private
    FFutureRunning: Boolean;
    FTaskRunning: Boolean;
    procedure SetButtonStates(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (not FTaskRunning) and (not FFutureRunning);

  if FTaskRunning then
    LogWrite('*** Wait for the Task (TTask) to finish before closing this window...');

  if FFutureRunning then
    LogWrite('*** Wait for the Calculation (IFuture) to finish before closing this window...');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
end;

procedure TMainForm.StartTaskButtonClick(Sender: TObject);
begin
  LogWrite('> Starting TTask task...');
  FTaskRunning := True;
  SetButtonStates(IsRunning);

  TTask.Run(
    procedure
    var
      i: Integer;
    begin
      try
        DebugLogWrite('TTask: Starting heavy work...');
        for i := 1 to 5 do
        begin
          if TTask.CurrentTask.Status = TTaskStatus.Canceled then
          begin
            DebugLogWrite('TTask: Task cooperatively canceled.');
            Break;
          end;
          DebugLogWrite('TTask: Executing step %d...', [i]);
          Sleep(1000);
        end;
        DebugLogWrite('TTask: Work completed.');
      finally
        TThread.Queue(nil,
          procedure
          begin
            if not (csDestroying in ComponentState) then
            begin
              LogWrite('TTask task completed and UI updated!');
              SetButtonStates(IsStopped);
            end;
            FTaskRunning := False;
          end);
      end;
    end);
  LogMemo.Lines.Add('TTask task launched! UI remains responsive.');
end;

procedure TMainForm.CalculateTaskButtonClick(Sender: TObject);
var
  CalcFuture: IFuture<Integer>;
  ForceException: Boolean;
begin
  LogWrite('> Starting calculation task (IFuture)...');
  ForceException := ForceExceptionCheckBox.Checked;
  SetButtonStates(IsRunning);
  FFutureRunning := True;

  CalcFuture := TTask.Future<Integer>(
    function: Integer
    var
      i, index, Sum: Integer;
    begin
      Sum := 0;
      index := 0;
      DebugLogWrite('IFuture Task: Starting heavy calculation...');
      try
        // Simulates heavy calculation
        for i := 1 to 100000000 do
        begin
          Inc(Sum);
          // Checks for cancellation more efficiently
          TTask.CurrentTask.CheckCanceled;
          if ForceException and (Random(100) = 0) then
          begin
            index := i;
            raise Exception.Create('Simulated error during calculation!');
          end;
        end;
        // Assigns the final result
        Result := Sum;
        DebugLogWrite('IFuture Task: Calculation completed.');
      except
        on E: Exception do
        begin
          DebugLogWrite(
            'IFuture Task: Exception caught in task: %s after %d iterations.',
            [E.Message, index]);
          // Re-raise for the IFuture
          raise;
        end;
      end;
    end);

  // Task that waits for the Future's result and updates the UI
  TTask.Run(
    procedure
    var
      ResultFromFuture: Integer;
      ExceptionObject: TObject;
    begin
      // Waits for completion and handles possible exceptions
      try
        // This will raise the exception if the task failed
        ResultFromFuture := CalcFuture.Value;
        // it's important to remove the reference, otherwise there might be a memory leak
        CalcFuture := nil;
        TThread.Queue(nil,
          procedure
          begin
            LogWrite('Calculation result (IFuture): %d', [ResultFromFuture]);
            SetButtonStates(IsStopped);
            FFutureRunning := False;
          end);
      except
        on E: Exception do
        begin
          // Captures the exception for display on the main thread
          ExceptionObject := AcquireExceptionObject;
          // it's important to remove the reference, otherwise there might be a memory leak
          CalcFuture := nil;
          TThread.Queue(nil,
            procedure
            begin
              LogWrite('Calculation (IFuture) failed: %s',
                [(ExceptionObject as Exception).ToString]);
              CalculateTaskButton.Enabled := True;
              ForceExceptionCheckBox.Enabled := True;
              // Exception captured with AcquireExceptionObject must be destroyed
              ExceptionObject.Free;
              FFutureRunning := False;
            end);
        end;
      end;
    end);
  LogWrite('Calculation task launched! UI remains responsive. Waiting for result...');
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  StartTaskButton.Enabled := RunningState = IsStopped;
  CalculateTaskButton.Enabled := RunningState = IsStopped;
  ForceExceptionCheckBox.Enabled := RunningState = IsStopped;
end;

end.
