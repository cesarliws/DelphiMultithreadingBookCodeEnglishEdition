unit DelphiMultithreadingBook0204.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartAnonymousMethodButton: TButton;
    StartAnonymousThreadButton: TButton;
    StopAnonymousThreadButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartAnonymousMethodButtonClick(Sender: TObject);
    procedure StartAnonymousThreadButtonClick(Sender: TObject);
    procedure StopAnonymousThreadButtonClick(Sender: TObject);
  private
    FAnonymousThread: TThread;
    procedure AnonymousThreadTerminated(Sender: TObject);
    procedure SetButtonStates(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils, Vcl.Dialogs;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FAnonymousThread) then
  begin
    // Unassign the event to prevent it from firing during form destruction
    FAnonymousThread.OnTerminate := nil;
    // Just signal the thread to terminate.
    FAnonymousThread.Terminate;
  end;
  UnregisterLogger;
end;

procedure TMainForm.StartAnonymousMethodButtonClick(Sender: TObject);
var
  // TProc is a type for procedures without parameters
  MyAction: TProc;
begin
  MyAction := procedure
    begin
      ShowMessage('Hello from the Anonymous Method!');
    end;
  // Execute the anonymous method
  MyAction;
end;

procedure TMainForm.StartAnonymousThreadButtonClick(Sender: TObject);
var
  // Example of a captured local variable
  Progress: Integer;
begin
  LogWrite('> Starting Anonymous Thread!');
  SetButtonStates(IsRunning);
  // Create and start the anonymous thread
  FAnonymousThread := TThread.CreateAnonymousThread(
    // This is the Anonymous Method that will be executed on the thread
    procedure
    var
      i: Integer;
      FinishedByUser: Boolean;
    begin
      DebugLogWrite('Anonymous Thread: Starting work...');
      FinishedByUser := False;
      // We use a shorter loop for demonstration purposes
      for i := 1 to 5 do
      begin
        if TThread.CheckTerminated then
        begin
          FinishedByUser := True;
          Break;
        end;
        // Update a local variable that will be captured by the Anonymous Method
        Progress := i;
        // Accessing the UI safely via Queue
        TThread.Queue(nil,
          procedure
          begin
            LogWrite('Anonymous Thread: Progress %d of 5', [Progress]);
          end);
        // 1-second pause
        Sleep(1000);
      end;
      // Final message, also via Queue
      TThread.Queue(nil,
        procedure
        begin
          if not FinishedByUser then
            LogWrite('Anonymous Thread: Completed!')
          else
            LogWrite('Anonymous Thread: Terminated prematurely!');
        end);
      DebugLogWrite('Anonymous Thread: End of work.');
    end);

  FAnonymousThread.OnTerminate := AnonymousThreadTerminated;
  // CreateAnonymousThread creates a Suspended Thread with
  // CreateSuspended = True, so we have to start the thread with .Start
  FAnonymousThread.Start;
end;

procedure TMainForm.AnonymousThreadTerminated(Sender: TObject);
begin
  FAnonymousThread := nil;
  SetButtonStates(IsStopped);
end;

procedure TMainForm.StopAnonymousThreadButtonClick(Sender: TObject);
begin
  if Assigned(FAnonymousThread) then
  begin
    FAnonymousThread.Terminate;
  end;
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  StartAnonymousThreadButton.Enabled := RunningState = IsStopped;
  StopAnonymousThreadButton.Enabled := RunningState = IsRunning;
end;

end.
