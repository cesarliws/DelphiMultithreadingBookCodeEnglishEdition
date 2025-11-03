unit DelphiMultithreadingBook0505.MainForm;

interface

uses
  System.Classes, System.Messaging, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0505.WorkerThread;

type
  TMainForm = class(TForm)
    LogMemo: TMemo;
    StartThreadButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartThreadButtonClick(Sender: TObject);
  private
    FWorkerThread: TWorkerThread;
    // Handler method to receive progress messages
    procedure HandleProgressMessage(const Sender: TObject; const M: TMessage);
    procedure FinalizeWorkerThread;
    procedure WorkerThreadTerminated(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  DelphiMultithreadingBook.Utils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started. Subscribing to TMessageManager...');
  // Subscribes to the TMessageManager to receive TProgressMessage type messages
  // The subscription can occur here in FormCreate (Main Thread)
  TMessageManager.DefaultManager.SubscribeToMessage(TProgressMessage, HandleProgressMessage);
  LogWrite('Subscribed to TMessageManager for progress messages.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // It's important to unsubscribe from messages when destroying the form
  TMessageManager.DefaultManager.Unsubscribe(TProgressMessage, HandleProgressMessage);
  FinalizeWorkerThread;
  UnregisterLogger;
end;

procedure TMainForm.StartThreadButtonClick(Sender: TObject);
begin
  // Ensures any previous execution is finalized
  FinalizeWorkerThread;
  LogWrite('> Starting Worker Thread to publish messages...');
  FWorkerThread := TWorkerThread.Create;
  FWorkerThread.OnTerminate := WorkerThreadTerminated;
  FWorkerThread.Start;
  StartThreadButton.Enabled := False;
end;

procedure TMainForm.HandleProgressMessage(const Sender: TObject; const M: TMessage);
var
  ProgressMsg: TProgressMessage;
begin
  // This handler is executed on the thread that subscribed (in this case, the Main Thread)
  if M is TProgressMessage then
  begin
    ProgressMsg := M as TProgressMessage;
    LogWrite('Message received: %s', [ProgressMsg.MessageText]);
    // We can update the UI directly here because this handler is called on the Main Thread
  end;
end;

procedure TMainForm.WorkerThreadTerminated(Sender: TObject);
begin
  LogWrite('Worker Thread finished.');
  StartThreadButton.Enabled := True;
end;

procedure TMainForm.FinalizeWorkerThread;
begin
  if Assigned(FWorkerThread) then
  begin
    FWorkerThread.Terminate;
    FWorkerThread.WaitFor;
    FWorkerThread.Free;
    FWorkerThread := nil;
  end;
end;

end.
