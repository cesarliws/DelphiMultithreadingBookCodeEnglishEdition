unit DelphiMultithreadingBook0501.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Winapi.Messages,
  DelphiMultithreadingBook0501.MessageWorkerThread;

type
  TMainForm = class(TForm)
    StartMessageThreadButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartMessageThreadButtonClick(Sender: TObject);
  private
    FMessageWorkerThread: TMessageWorkerThread;
    // Methods to receive and handle custom messages
    procedure HandleTaskDoneMessage(var Msg: TMessage); message WM_TASK_DONE;
    procedure HandleUpdateMemoMessage(var Msg: TMessage); message WM_UPDATE_MEMO;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  DelphiMultithreadingBook.Utils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  LogWrite('Click "Start Thread (PostMessage)".');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // Ensures the thread is terminated and freed when the form is closed
  if Assigned(FMessageWorkerThread) then
  begin
    // Signals the thread to terminate, if it checks Terminated
    FMessageWorkerThread.Terminate;
    // Waits for the thread to finish its execution
    FMessageWorkerThread.WaitFor;
    // Frees the thread object (FreeOnTerminate = False)
    FMessageWorkerThread.Free;
  end;
  UnregisterLogger;
end;

procedure TMainForm.HandleTaskDoneMessage(var Msg: TMessage);
begin
  // Ensures the thread still exists before interacting with it
  if not Assigned(FMessageWorkerThread) then
    Exit;
  // Message received in the Main Thread
  LogWrite('Thread task completed via PostMessage!');
  FMessageWorkerThread.WaitFor;
  // Optional: Free the thread if it is no longer needed
  FMessageWorkerThread.Free;
  FMessageWorkerThread := nil;
  StartMessageThreadButton.Enabled := True;
end;

procedure TMainForm.HandleUpdateMemoMessage(var Msg: TMessage);
var
  MessageData: PMessageData;
begin
  // 1. Receives the raw pointer from the message's WParam parameter.
  // 2. Typecasts it to PMessageData so Delphi understands the structure.
  MessageData := PMessageData(Msg.WParam);
  try
    // 3. Accesses the data safely.
    LogWrite(MessageData^.TextMessage);
  finally
    // 4. Frees the memory of the record that was allocated in the worker thread.
    Dispose(MessageData);
  end;
end;

procedure TMainForm.StartMessageThreadButtonClick(Sender: TObject);
begin
  if not Assigned(FMessageWorkerThread) then
  begin
    LogWrite('> Starting Thread with PostMessage...');
    // Creates the worker thread and passes the Form's Handle for sending messages
    FMessageWorkerThread := TMessageWorkerThread.Create(Handle);
    // Disables the button to prevent multiple instances
    StartMessageThreadButton.Enabled := False;
  end
  else
    LogWrite('Message Thread is already running.');
end;

end.
