unit DelphiMultithreadingBook0305.Shared;

interface

uses
  System.Classes,
  System.Generics.Collections, // TQueue<string>
  System.SyncObjs,             // TCriticalSection, TEvent
  DelphiMultithreadingBook.Utils;

type
  TBaseThread = class(TThread)
  private
    FLogWriteCallback: TLogWriteCallback;
  protected
    procedure CallbackLogWrite(const Text: string); overload;
    procedure CallbackLogWrite(const Text: string; const Args: array of const); overload;
  public
    constructor Create(CreateSuspended: Boolean;
      CallbackLogWrite: TLogWriteCallback); reintroduce; virtual;
  end;

// Resources for the Producer-Consumer example
var
  MessageQueue: TQueue<string>;           // Shared message queue
  QueueCriticalSection: TCriticalSection; // To protect queue access
  NewItemsEvent: TEvent;                  // Event to signal new items in the queue

implementation

uses
  System.SysUtils; // Format

{ TBaseThread }

constructor TBaseThread.Create(CreateSuspended: Boolean; CallbackLogWrite: TLogWriteCallback);
begin
  inherited Create(CreateSuspended);
  FLogWriteCallback := CallbackLogWrite;
end;

procedure TBaseThread.CallbackLogWrite(const Text: string);
begin
  DebugLogWrite(Text);
  // Send log to the UI if the callback was provided
  if Assigned(FLogWriteCallback) then
  begin
    // We use TThread.Queue to update the UI without blocking the processing
    TThread.Queue(nil,
      procedure
      begin
        FLogWriteCallback(Text);
      end);
  end;
end;

procedure TBaseThread.CallbackLogWrite(const Text: string; const Args: array of const);
begin
  CallbackLogWrite(Format(Text, Args));
end;

initialization
  // Initialize Producer-Consumer resources
  MessageQueue := TQueue<string>.Create;
  QueueCriticalSection := TCriticalSection.Create;
  // Create the event
  NewItemsEvent := TEvent.Create(
    nil,    // EventAttributes = nil
    False,  // ManualReset = False (AutoReset)
    False,  // InitialState = False (Non-Signaled)
    '',     // Name = ''
    False); // UseCOMWait = False

finalization
  NewItemsEvent.Free; // Free the Event
  MessageQueue.Free; // Free the Queue
  QueueCriticalSection.Free;

end.
