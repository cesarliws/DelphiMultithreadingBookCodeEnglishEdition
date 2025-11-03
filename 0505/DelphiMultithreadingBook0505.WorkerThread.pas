unit DelphiMultithreadingBook0505.WorkerThread;

interface

uses
  System.Classes, System.Messaging;

type
  // Defines the type of message we want to send
  TProgressMessage = class(TMessage)
  public
    MessageText: string;
    Progress: Integer;
    constructor Create(Progress: Integer; const Msg: string);
  end;

  TWorkerThread = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create;
  end;

implementation

uses
  System.SysUtils;

{ TProgressMessage }

constructor TProgressMessage.Create(Progress: Integer; const Msg: string);
begin
  inherited Create;
  Self.Progress := Progress;
  Self.MessageText := Msg;
end;

{ TWorkerThread }

constructor TWorkerThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := False;
end;

procedure TWorkerThread.Execute;
var
  i: Integer;
  ProgressMsg: TProgressMessage;
begin
  // Simulates background work
  for i := 1 to 10 do
  begin
    if Terminated then
      Break;
    // Creates the message with the data
    ProgressMsg := TProgressMessage.Create(i * 10, Format('Progress: %d%% complete', [i * 10]));
    // Publishes the message - The TMessageManager will route this message to subscribers.
    TMessageManager.DefaultManager.SendMessage(Self, ProgressMsg);
    // The ProgressMsg object will be freed by TMessageManager when processed.
    Sleep(500); // Simulates work
  end;
end;

end.
