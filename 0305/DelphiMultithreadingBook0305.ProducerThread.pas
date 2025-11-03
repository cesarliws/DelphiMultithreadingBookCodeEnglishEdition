unit DelphiMultithreadingBook0305.ProducerThread;

interface

uses
  System.Classes, DelphiMultithreadingBook0305.Shared, DelphiMultithreadingBook.Utils;

type
  TProducerThread = class(TBaseThread)
  protected
    procedure Execute; override;
  public
    constructor Create(CallbackLogWrite: TLogWriteCallback); reintroduce;
  end;

implementation

uses
  System.SyncObjs, // Inline TCriticalSection.Enter/Leave
  System.SysUtils;

{ TProducerThread }

constructor TProducerThread.Create(CallbackLogWrite: TLogWriteCallback);
begin
  inherited Create(False, CallbackLogWrite);
  // FreeOnTerminate = False for safe manual management with WaitFor
  FreeOnTerminate := False;
end;

procedure TProducerThread.Execute;
var
  i: Integer;
  Message: string;
begin
  CallbackLogWrite('Producer: Starting message production...');
  // Produces 10 messages
  for i := 1 to 10 do
  begin
    if Terminated then Break;
    Message := Format('Message %d', [i]);
    // Protects queue access
    QueueCriticalSection.Enter;
    try
       // Adds message to the queue
      MessageQueue.Enqueue(Message);
      CallbackLogWrite('Producer: Added "%s" to the queue. (Size: %d)',
        [Message, MessageQueue.Count]);
    finally
      QueueCriticalSection.Leave;
    end;
    // Signals that there are new items in the queue
    NewItemsEvent.SetEvent;
    // Simulates production time (between 100ms and 600ms)
    Sleep(100 + Random(500));
  end;
  CallbackLogWrite('Producer: Production completed.');
  // Signals one last time to ensure the consumer processes everything
  NewItemsEvent.SetEvent;
end;

end.
