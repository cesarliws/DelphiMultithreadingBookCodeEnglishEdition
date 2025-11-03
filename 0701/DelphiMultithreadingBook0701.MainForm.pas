unit DelphiMultithreadingBook0701.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0701.SimpleThreadPool, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartThreadPoolButton: TButton;
    StopThreadPoolButton: TButton;
    QueueTaskThreadPoolButton: TButton;
    LogMemo: TMemo;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StartThreadPoolButtonClick(Sender: TObject);
    procedure StopThreadPoolButtonClick(Sender: TObject);
    procedure QueueTaskThreadPoolButtonClick(Sender: TObject);
  private
    // Our Thread Pool instance
    FThreadPool: TSimpleThreadPool;
    procedure SetButtonStates(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils;

const
  // For Delphi Unicode versions
  SendingToQueue = #$2192;     // right arrow
  TaskScheduled = #$25CF;      // filled circle
  TaskCompleted = #$2713;      // check mark
  AllTasksCompleted = #$2705;  // heavy check mark

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  SetButtonStates(IsStopped);
  LogMemo.ScrollBars := ssVertical;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
  if Assigned(FThreadPool) then
  begin
    // The pool destructor will take care of the Shutdown
    FThreadPool.Free;
    FThreadPool := nil;
  end;
end;

procedure TMainForm.StartThreadPoolButtonClick(Sender: TObject);
begin
  if not Assigned(FThreadPool) then
  begin
    LogWrite('Creating Thread Pool...');
    // Creates a pool with 3 worker threads
    FThreadPool := TSimpleThreadPool.Create(3);
    LogWrite('Thread Pool created. Queuing tasks...');
    LogWrite('Click "QueueTaskThreadPoolButton" several times to see the tasks being executed.');
    SetButtonStates(IsRunning);
    QueueTaskThreadPoolButton.SetFocus;
  end
  else
    LogMemo.Lines.Add('Thread Pool is already active.');
end;

procedure TMainForm.StopThreadPoolButtonClick(Sender: TObject);
begin
  if Assigned(FThreadPool) then
  begin
    LogWrite('> Requesting Thread Pool Shutdown...');
    // Frees the pool object
    FThreadPool.Free;
    FThreadPool := nil;
    LogWrite('Thread Pool shutdown.');
    SetButtonStates(IsStopped);
    StartThreadPoolButton.SetFocus;
  end;
end;

procedure TMainForm.QueueTaskThreadPoolButtonClick(Sender: TObject);
var
  TaskId: Integer;
begin
  if not Assigned(FThreadPool) then
    Exit;
  QueueTaskThreadPoolButton.Enabled := False;
  try
    LogWrite(SendingToQueue + ' Sending Task for queuing in the Thread Pool...');
    TaskId := FThreadPool.QueueTask(
      // This is the task that will be executed by a pool worker
      procedure
      begin
        DebugLogWrite('Task %d (Worker %d): Starting processing...',
          [TaskId, TThread.CurrentThread.ThreadID]);
        // Simulates variable work
        Sleep(500 + Random(2000));
        TThread.Queue(nil,
          procedure
          begin
            LogWrite(TaskCompleted + ' Task %d: Processing completed.', [TaskId]);
            if FThreadPool.ActiveTaskCount = 0 then
            begin
              LogWrite(AllTasksCompleted + ' All tasks processed.');
            end;
          end);
        DebugLogWrite('Task %d (Worker %d): Processing completed.',
          [TaskId, TThread.CurrentThread.ThreadID]);
      end);
    LogWrite(TaskScheduled + ' Task %d added to the Thread Pool.', [TaskId]);
  finally
    QueueTaskThreadPoolButton.Enabled := True;
  end;
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  if csDestroying in ComponentState then
    Exit;
  StartThreadPoolButton.Enabled := RunningState = IsStopped;
  StopThreadPoolButton.Enabled := RunningState = IsRunning;
  QueueTaskThreadPoolButton.Enabled := RunningState = IsRunning;
end;

end.
