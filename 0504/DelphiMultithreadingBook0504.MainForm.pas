unit DelphiMultithreadingBook0504.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  DelphiMultithreadingBook.Utils;

type
  // Simple worker thread for our new example
  TWorkerThread = class(TThread)
  protected
    procedure Execute; override;
  end;

  TMainForm = class(TForm)
    StartWorkerButton: TButton;
    LogMemo: TMemo;
    LoadDataButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LoadDataButtonClick(Sender: TObject);
    procedure StartWorkerButtonClick(Sender: TObject);
  private
    FWorkerThread: TWorkerThread;
    procedure AfterFormShowAsync;
    procedure LoadDataFromDatabase;
    procedure FinalizeThread;
    procedure SetButtonStates(RunningState: TRunningState);
    procedure WorkerTerminated(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  Winapi.Windows, DelphiMultithreadingBook0504.AsyncHelpers;

{ TWorkerThread }

procedure TWorkerThread.Execute;
var
  i: Integer;
begin
  for i := 1 to 5 do
  begin
    if Terminated then Break;
    // The worker thread uses RunAsync to queue a UI update
    RunAsync(
      procedure
      begin
        LogWrite('Worker Thread: Progress %d of 5', [i]);
      end);
    Sleep(1000); // simulate work
  end;
end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
  FinalizeThread;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
 LogWrite('Form displayed. Scheduling data load...');
  // Example 1: Scheduling a task from the MainThread
  RunAsync(AfterFormShowAsync);
end;

procedure TMainForm.AfterFormShowAsync;
begin
  SetButtonStates(IsRunning);
  try
    LogWrite('Executing AfterFormShowAsync on the Main Thread...');
    Self.Repaint;
    // Now, inside this method, you can call your query
    LoadDataFromDatabase;
    StartWorkerButton.Enabled := True;
    StartWorkerButton.SetFocus;
  finally
    SetButtonStates(IsStopped);
  end;
end;

procedure TMainForm.LoadDataButtonClick(Sender: TObject);
begin
  LogWrite('> Button Clicked: Scheduling data load...');
  // Also demonstrates scheduling from a click event
  RunAsync(LoadDataFromDatabase);
end;

procedure TMainForm.StartWorkerButtonClick(Sender: TObject);
begin
  FinalizeThread;
  LogWrite('> Starting Worker Thread that will use the Dispatcher...');

  // Example 2: Receiving communication from a Worker Thread
  FWorkerThread := TWorkerThread.Create(True); // Create suspended
  FWorkerThread.OnTerminate := WorkerTerminated;
  FWorkerThread.FreeOnTerminate := False; // Manual management
  FWorkerThread.Start;
  SetButtonStates(IsRunning);
end;

procedure TMainForm.FinalizeThread;
begin
  if Assigned(FWorkerThread) then
  begin
    FWorkerThread.Terminate;
    FWorkerThread.WaitFor;
    FWorkerThread.Free;
    FWorkerThread := nil;
  end;
end;

procedure TMainForm.LoadDataFromDatabase;
begin
  LogWrite('LoadDataFromDatabase: Starting BLOCKING operation on the MainThread...');
  SetButtonStates(IsRunning);
  // DIDACTIC WARNING: This Sleep(3000) will freeze the UI.
  // It is here to demonstrate that the work scheduled by the
  // dispatcher still executes on the MainThread.
  Sleep(3000);
  LogWrite('LoadDataFromDatabase: Operation completed.');
  SetButtonStates(IsStopped);
end;

procedure TMainForm.WorkerTerminated(Sender: TObject);
begin
  if csDestroying in ComponentState then
    Exit;
  // OnTerminate already executes on the MainThread, so we can update the UI directly.
  LogWrite('Worker Thread: Processing finished');
  SetButtonStates(IsStopped);
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  if csDestroying in ComponentState then
    Exit;

  StartWorkerButton.Enabled := RunningState = IsStopped;

  if RunningState = IsRunning then
    Screen.Cursor := crHourGlass
  else
    Screen.Cursor := crDefault;
end;

end.
