unit DelphiMultithreadingBook0305.ConsumerThread;

interface

uses
  System.Classes, DelphiMultithreadingBook0305.Shared, DelphiMultithreadingBook.Utils;

type
  TConsumerThread = class(TBaseThread)
  protected
    procedure Execute; override;
  public
    constructor Create(CallbackLogWrite: TLogWriteCallback); reintroduce;
  end;

implementation

uses
  System.SyncObjs;

{ TConsumerThread }

constructor TConsumerThread.Create(CallbackLogWrite: TLogWriteCallback);
begin
  inherited Create(False, CallbackLogWrite);
  // Changed to False for safe manual management with WaitFor
  FreeOnTerminate := False;
end;

procedure TConsumerThread.Execute;
var
  Message: string;
  ProcessedCount: Integer;
begin
  ProcessedCount := 0;
  CallbackLogWrite('Consumer: Starting message consumption...');
  while not Terminated do
  begin
    // Wait for the new items event. If the event is signaled, continue. If not, block until
    // SetEvent is called by the producer. A timeout is used to allow the thread to check
    // Terminated and avoid an eternal block. Wait for 500ms
    if NewItemsEvent.WaitFor(500) = TWaitResult.wrTimeout then
    begin
      // If it timed out, check if it should terminate and continue the loop
      if Terminated then Break;
      Continue;
    end;
    // If it reached here, the event was signaled (or was already signaled)
    // Protects queue access
    QueueCriticalSection.Enter;
    try
      // The event is auto-reset, so a single signal from the producer wakes us up.
      // Instead of processing just one item, we optimize by processing all
      // items the producer might have queued before we go back to waiting.
      while MessageQueue.Count > 0 do
      begin
        // Remove from the queue
        Message := MessageQueue.Dequeue;
        Inc(ProcessedCount);
        CallbackLogWrite('Consumer: Processing "%s" (Total processed: %d)',
          [Message, ProcessedCount]);
        // Simulate processing the message with a short pause
        Sleep(50 + Random(200));
      end;
    finally
      QueueCriticalSection.Leave;
    end;
    // Since NewItemsEvent was created as AutoReset, it has already been
    // automatically reset after the WaitFor.
    // If it were ManualReset, we would have to call NewItemsEvent.ResetEvent here.
  end;
  CallbackLogWrite('Consumer: Finished. Total processed: %d', [ProcessedCount]);
end;

end.
